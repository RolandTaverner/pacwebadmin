module model.entities.proxyrules;

import model.entities.common;
import model.entities.hostrule;
import model.entities.proxy;
import model.errors.base;


class ProxyRules
{
    @safe this(in long id, in Proxy proxy, in bool enabled, in HostRule[] hostRules) pure
    {
        m_id = id;
        m_proxy = new Proxy(proxy);
        m_enabled = enabled;

        foreach (hr; hostRules)
        {
            m_hostRules ~= new HostRule(hr);
        }
    }

    @safe this(in ProxyRules other) pure
    {
        m_id = other.m_id;
        m_proxy = new Proxy(other.m_proxy);
        m_enabled = other.m_enabled;

        foreach (hr; other.m_hostRules)
        {
            m_hostRules ~= new HostRule(hr);
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

    @safe const(HostRule[]) hostRules() const pure
    {
        return m_hostRules;
    }

    mixin entityId!();

private:
    Proxy m_proxy;
    bool m_enabled;
    HostRule[] m_hostRules;
}


struct ProxyRulesInput
{
    long proxyId;
    bool enabled;
    long[] hostRuleIds;
}


class ProxyRulesNotFound : NotFoundBase!(ProxyRules)
{
    mixin finalEntityErrorCtors!("not found");
}
