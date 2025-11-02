module datalayer.proxy;

import std.json;

import datalayer.repository.repository;

class ProxyValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in ProxyValue v) pure
    {
        m_hostAddress = v.m_hostAddress.dup;
        m_description = v.m_description.dup;
        m_builtIn = v.m_builtIn;        
    }

    @safe this(in string hostAddress, in string description, in bool builtIn) pure
    {
        m_hostAddress = hostAddress;
        m_description = description;
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

    JSONValue toJSON() const
    {
        return JSONValue([
                "hostAddress": JSONValue(hostAddress()),
                "description": JSONValue(description()),
                "builtIn": JSONValue(builtIn())
            ]);
    }

    unittest
    {
        ProxyValue value = new ProxyValue("example.com:8080", "test", false);
        const JSONValue v = value.toJSON();
        
        assert( v.object["hostAddress"].str == "example.com:8080" );
        assert( v.object["description"].str == "test" );
        assert( v.object["builtIn"].boolean == false );
    }

    void fromJSON(in JSONValue v)
    {
        m_hostAddress = v.object["hostAddress"].str;
        m_description = v.object["description"].str;
        m_builtIn = v.object["builtIn"].boolean;
    }

    unittest
    {
        JSONValue v = JSONValue.emptyObject;
        v.object["hostAddress"] = JSONValue("example.com:8080");
        v.object["description"] = JSONValue("test");
        v.object["builtIn"] = JSONValue(false);

        ProxyValue value = new ProxyValue();
        value.fromJSON(v);
        
        assert( value.hostAddress() == "example.com:8080" );
        assert( value.description() == "test" );
        assert( value.builtIn() == false );
    }

protected:
    string m_hostAddress;
    string m_description;
    bool m_builtIn;
}


class ProxyRepository : RepositoryBase!(Key, ProxyValue)
{
}

unittest
{
    ProxyRepository r = new ProxyRepository();
    r.create(new ProxyValue());
}
