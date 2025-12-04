module model.pacbuilder;

import std.array : appender, Appender, replace;
import std.conv;
import std.string : toLower;

import model.model;

import model.entities.condition : Condition, ConditionType;
import model.entities.pac : PAC, ProxyRulePriority;
import model.entities.proxy : Proxy, ProxyType;
import model.entities.proxyrule : ProxyRule;

class PACBuilder
{
    this(Model model)
    {
        m_model = model;
    }

    string build(long id)
    {
        auto pacModel = m_model.pacById(id);
        auto app = appender!string();
        addHeader(app, pacModel);
        addProxies(app, pacModel);
        app.put("\n\n");

        app.put(commentLine("This function gets called every time a url is submitted"));
        app.put("function FindProxyForURL(url, host) {\n");
        app.put("    var host_lc = host.toLowerCase();\n\n");

        foreach (ref const ProxyRulePriority prp; pacModel.proxyRules())
        {
            auto pr = prp.proxyRule();
            if (!pr.enabled())
            {
                continue;
            }

            addProxyRule(app, pr);
            app.put("\n\n");
        }

        app.put("    return " ~ proxyVarName(pacModel.fallbackProxy()) ~ ";\n");
        app.put("}\n");

        return app.data;
    }

protected:

    void addHeader(scope ref Appender!string app, scope ref const PAC pacModel) const pure
    {
        app.put(commentLine(pacModel.name()));
        app.put(commentText(pacModel.description()));
        app.put("\n");
    }

    void addProxies(scope ref Appender!string app, scope ref const PAC pacModel) const
    {
        auto fallbackProxy = pacModel.fallbackProxy();

        bool[long] proxyIDs;
        foreach (ref const ProxyRulePriority pr; pacModel.proxyRules())
        {
            auto proxy = pr.proxyRule().proxy();
            if (proxy.id() in proxyIDs)
            {
                continue;
            }

            proxyIDs[proxy.id()] = true;

            if (proxy.id() == fallbackProxy.id())
            {
                app.put(commentLine("Used as proxy if no rules matched"));
            }
            addProxyVar(app, proxy);
            app.put("\n");
        }

        if (fallbackProxy.id() !in proxyIDs)
        {
            app.put(commentLine("Used as proxy if no rules matched"));
            addProxyVar(app, fallbackProxy);
        }
    }

    void addProxyVar(scope ref Appender!string app, scope ref const Proxy p) const
    {
        app.put(commentText(p.description()));
        if (p.type() != ProxyType.DIRECT)
        {
            app.put("var " ~ proxyVarName(p) ~ " = \"" ~ p.type() ~ " " ~ p.address() ~ "\";\n");
        }
        else
        {
            app.put("var " ~ proxyVarName(p) ~ " = \"" ~ p.type() ~ "\";\n");
        }
    }

    string proxyVarName(in Proxy p) const pure @safe
    {
        return "proxy" ~ to!string(p.id());
    }

    void addProxyRule(scope ref Appender!string app, scope ref const ProxyRule pr) const
    {
        app.put("    " ~ commentText(pr.name()));

        app.put("    if (");

        bool isFirst = true;
        foreach (c; pr.conditions())
        {
            if (!isFirst)
            {
                app.put("\n        || ");
            }
            addConditionExpression(app, c);
            isFirst = false;
        }

        app.put(") return " ~ proxyVarName(pr.proxy()) ~ ";");
    }

    void addConditionExpression(scope ref Appender!string app, scope ref const Condition c) const
    {
        auto expressionLC = c.expression().toLower();

        switch (c.type())
        {
        case ConditionType.hostDomainOnly:
            app.put("(host_lc == \"" ~ expressionLC ~ "\")");
            break;
        case ConditionType.hostDomainSubdomain:
            app.put("/^(?:.*\\.)?" ~ expressionLC.replace(".", "\\.") ~ "$/.test(host_lc)");
            break;
        case ConditionType.hostSubdomainOnly:
            app.put("/^.*\\." ~ expressionLC.replace(".", "\\.") ~ "$/.test(host_lc)");
            break;
        case ConditionType.urlShexpMatch:
            app.put("shExpMatch(url, \"" ~ c.expression() ~ "\")");
            break;
        case ConditionType.urlRegexpMatch:
            app.put("/" ~ c.expression() ~ "/.test(url)");
            break;
        default:
            app.put("false /* ERROR: unknown condition type " ~ c.type()
                    ~ ", condition id=" ~ to!(string)(c.id()) ~ " */");
        }
    }

private:
    Model m_model;
}

string commentLine(scope const(string) line) pure @safe
{
    return "// " ~ line ~ "\n";
}

unittest
{
    assert(commentLine("a b c") == "// a b c\n");
}

string commentText(scope const(string) text) pure @safe
{
    import std.array : array, replace, split;
    import std.algorithm.iteration : each, filter;

    auto app = appender!string();

    text.replace("\r\n", "\n")
        .split("\n")
        .filter!(line => line.length != 0)
        .each!(line => app.put(commentLine(line)));

    return app.data;
}

unittest
{
    assert(commentText("a b c") == "// a b c\n");
    assert(commentText("abc\nxyz") == "// abc\n// xyz\n");
}
