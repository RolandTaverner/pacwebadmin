module model.proxy;

import model.errors.base;


class Proxy {
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
        m_hostAddress = hostAddress;
        m_description = description;
        m_builtIn = builtIn;
    }

    @safe long id() const pure
    {
        return m_id;
    }

    @safe const(string) hostAddress() const 
    {
        return m_hostAddress;
    }

    @safe const(string) description() const 
    {
        return m_description;
    }

    @safe bool builtIn() const 
    {
        return m_builtIn;
    }

private:
   long m_id;
   string m_hostAddress;
   string m_description;
   bool m_builtIn;
}


class ProxyNotFound : NotFoundBase!(Proxy)
{
    mixin finalEntityErrorCtors!("not found");
}
