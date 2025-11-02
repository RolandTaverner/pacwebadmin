module model.entities.proxy;

import model.entities.common;
import model.errors.base;


class Proxy 
{
    @safe this(in Proxy other) pure
    {
        m_id = other.m_id;
        m_hostAddress = other.m_hostAddress.dup;
        m_description = other.m_description.dup;
        m_builtIn = other.m_builtIn;        
    }

    @safe this(in long id, in string hostAddress, in string description, in bool builtIn) pure
    {
        m_id = id;
        m_hostAddress = hostAddress.dup;
        m_description = description.dup;
        m_builtIn = builtIn;
    }

    @safe const(string) hostAddress() const pure
    {
        return m_hostAddress;
    }

    @safe const(string) description() const pure
    {
        return m_description;
    }

    @safe bool builtIn() const pure
    {
        return m_builtIn;
    }

    mixin entityId!();

private:
    string m_hostAddress;
    string m_description;
    bool m_builtIn;
}


struct ProxyInput
{
    string hostAddress;
    string description;
    bool builtIn;
}


class ProxyNotFound : NotFoundBase!(Proxy)
{
    mixin finalEntityErrorCtors!("not found");
}
