module model.entities.pac;

import std.datetime.systime : SysTime;
import std.exception : enforce;
import std.string;
import std.typecons : Nullable;

import model.entities.common;
import model.entities.proxy;
import model.entities.proxyrule;
import model.errors.base;


class ProxyRulePriority
{
    this(in ProxyRulePriority other) pure @safe
    {
        m_proxyRule = new ProxyRule(other.proxyRule());
        m_priority = other.priority();
    }

    this(in ProxyRule proxyRule, in long priority) pure @safe
    {
        m_proxyRule = new ProxyRule(proxyRule);
        m_priority = priority;
    }

    @safe const(ProxyRule) proxyRule() const pure
    {
        return m_proxyRule;
    }

    @safe long priority() const pure
    {
        return m_priority;
    }

private:    
    ProxyRule m_proxyRule;
    long m_priority;
}

class PAC
{
    @safe this(in PAC other) pure
    {
        m_id = other.m_id;
        m_name = other.m_name;
        m_description = other.m_description;

        foreach (pr; other.m_proxyRules)
        {
            m_proxyRules ~= new ProxyRulePriority(pr);
        }

        m_serve = other.m_serve;
        m_servePath = other.m_servePath;
        m_saveToFS = other.m_saveToFS;
        m_saveToFSPath = other.m_saveToFSPath;
        m_fallbackProxy = new Proxy(other.m_fallbackProxy);
        m_updatedAt = other.m_updatedAt;
    }

    @safe this(in long id,
        in string name,
        in string description,
        in ProxyRulePriority[] proxyRules,
        in bool serve,
        in string servePath,
        in bool saveToFS,
        in string saveToFSPath,
        in Proxy fallbackProxy,
        in SysTime updatedAt) pure
    {
        m_id = id;
        m_name = name;
        m_description = description;

        foreach (pr; proxyRules)
        {
            m_proxyRules ~= new ProxyRulePriority(pr);
        }

        m_serve = serve;
        m_servePath = servePath;
        m_saveToFS = saveToFS;
        m_saveToFSPath = saveToFSPath;
        m_fallbackProxy = new Proxy(fallbackProxy);
        m_updatedAt = updatedAt;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

    @safe const(string) description() const pure
    {
        return m_description;
    }

    @safe const(ProxyRulePriority[]) proxyRules() const pure
    {
        return m_proxyRules;
    }

    @safe bool serve() const pure
    {
        return m_serve;
    }

    @safe const(string) servePath() const pure
    {
        return m_servePath;
    }

    @safe bool saveToFS() const pure
    {
        return m_saveToFS;
    }

    @safe const(string) saveToFSPath() const pure
    {
        return m_saveToFSPath;
    }

    @safe const(Proxy) fallbackProxy() const pure
    {
        return m_fallbackProxy;
    }

    @safe SysTime updatedAt() const pure
    {
        return m_updatedAt;
    }

    mixin entityId!();

private:
    string m_name;
    string m_description;
    ProxyRulePriority[] m_proxyRules;
    bool m_serve;
    string m_servePath;
    bool m_saveToFS;
    string m_saveToFSPath;
    Proxy m_fallbackProxy;
    SysTime m_updatedAt;
}

struct PACInput
{
    Nullable!string name;
    Nullable!string description;
    Nullable!(long[long]) proxyRules;
    Nullable!bool serve;
    Nullable!string servePath;
    Nullable!bool saveToFS;
    Nullable!string saveToFSPath;
    Nullable!long fallbackProxyId;

    @safe void validate(bool update) const pure
    {
        if (!update)
        {
            enforce!bool(!name.isNull, new ConstraintError("name can't be null"));
            enforce!bool(name.get.strip().length != 0, new ConstraintError("name can't be empty"));

            enforce!bool(!serve.isNull, new ConstraintError("serve can't be null"));
    
            if (serve.get)
            {
                enforce!bool(!servePath.isNull, new ConstraintError("servePath can't be null"));
                enforce!bool(servePath.get.strip().length != 0, new ConstraintError("servePath can't be empty"));
            }

            enforce!bool(!saveToFS.isNull, new ConstraintError("saveToFS can't be null"));
    
            if (saveToFS.get)
            {
                enforce!bool(!saveToFSPath.isNull, new ConstraintError("saveToFSPath can't be null"));
                enforce!bool(saveToFSPath.get.strip().length != 0, new ConstraintError("saveToFSPath can't be empty"));
            }

            enforce!bool(!fallbackProxyId.isNull, new ConstraintError("fallbackProxyId can't be null"));
        } 
        else
        {
            enforce!bool(name.isNull || name.get.strip().length != 0, new ConstraintError("name can't be empty"));
            
            if (!serve.isNull && serve.get() && !servePath.isNull)
            {
                enforce!bool(servePath.get.strip().length != 0, new ConstraintError("servePath can't be empty"));
            }
            if (!saveToFS.isNull && saveToFS.get() && !saveToFSPath.isNull)
            {
                enforce!bool(saveToFSPath.get.strip().length != 0, new ConstraintError("saveToFSPath can't be empty"));
            }
        }
    }
}

class PACNotFound : NotFoundBase!(PAC)
{
    mixin finalEntityErrorCtors!("not found");
}
