module model.entities.pac;

import model.entities.common;
import model.entities.proxyrules;
import model.errors.base;


class PAC
{
    @safe this(in PAC other) pure
    {
        m_id = other.m_id;
        m_name = other.m_name.dup;
        m_description = other.m_description.dup;

        foreach (pr; other.m_proxyRules)
        {
            m_proxyRules ~= new ProxyRules(pr);
        }

        m_serve = other.m_serve;
        m_servePath = other.m_servePath.dup;
        m_saveToFS = other.m_saveToFS;
        m_saveToFSPath = other.m_saveToFSPath.dup;
    }

    @safe this(in long id, in string name, in string description, in ProxyRules[] proxyRules, 
        bool serve, string servePath, bool saveToFS, string saveToFSPath) pure
    {
        m_id = id;
        m_name = name;
        m_description = description;
        
        foreach (pr; proxyRules)
        {
            m_proxyRules ~= new ProxyRules(pr);
        }
        
        m_serve = serve;
        m_servePath = servePath.dup;
        m_saveToFS = saveToFS;
        m_saveToFSPath = saveToFSPath.dup;
    }

    // @safe const(Proxy) proxy() const pure
    // {
    //     return m_proxy;
    // }

    // @safe bool enabled() const pure
    // {
    //     return m_enabled;
    // }

    // @safe const(string) name() const pure
    // {
    //     return m_name;
    // }

    // @safe const(HostRule[]) hostRules() const pure
    // {
    //     return m_hostRules;
    // }

    mixin entityId!();

private:
    string m_name;
    string m_description;
    ProxyRules[] m_proxyRules;
    bool m_serve;
    string m_servePath;
    bool m_saveToFS;
    string m_saveToFSPath;
}


struct PACInput
{
    string m_name;
    string m_description;
    long[] m_proxyRulesIds;
    bool m_serve;
    string m_servePath;
    bool m_saveToFS;
    string m_saveToFSPath;
}


class PACNotFound : NotFoundBase!(PAC)
{
    mixin finalEntityErrorCtors!("not found");
}
