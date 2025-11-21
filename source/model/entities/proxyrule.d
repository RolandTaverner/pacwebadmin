module model.entities.proxyrule;

import std.exception : enforce;
import std.string;
import std.typecons : Nullable;

import model.entities.common;
import model.entities.condition;
import model.entities.proxy;
import model.errors.base;

class ProxyRule
{
    @safe this(in long id, in Proxy proxy, in bool enabled, in string name, in Condition[] conditions) pure
    {
        m_id = id;
        m_proxy = new Proxy(proxy);
        m_enabled = enabled;
        m_name = name;

        foreach (c; conditions)
        {
            m_conditions ~= new Condition(c);
        }
    }

    @safe this(in ProxyRule other) pure
    {
        m_id = other.m_id;
        m_proxy = new Proxy(other.m_proxy);
        m_enabled = other.m_enabled;
        m_name = other.m_name;

        foreach (hr; other.m_conditions)
        {
            m_conditions ~= new Condition(hr);
        }
    }

    @safe const(Proxy) proxy() const pure
    {
        return m_proxy;
    }

    @safe bool enabled() const pure
    {
        return m_enabled;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

    @safe const(Condition[]) conditions() const pure
    {
        return m_conditions;
    }

    mixin entityId!();

private:
    Proxy m_proxy;
    bool m_enabled;
    string m_name;
    Condition[] m_conditions;
}

struct ProxyRuleInput
{
    Nullable!long proxyId;
    Nullable!bool enabled;
    string name;
    long[] conditionIds;

    @safe void validate(bool update) const pure
    {
        enforce!bool(update || name.strip().length != 0, new ConstraintError("name can't be empty"));

        if (!update)
        {
            enforce!bool(!proxyId.isNull, new ConstraintError("name can't be empty"));
            enforce!bool(!enabled.isNull, new ConstraintError("name can't be empty"));
        }
    }    
}

class ProxyRuleNotFound : NotFoundBase!(ProxyRule)
{
    mixin finalEntityErrorCtors!("not found");
}
