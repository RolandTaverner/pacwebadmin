module datalayer.hostrule;

import std.json;

import datalayer.repository.repository;


class HostRuleValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in HostRuleValue v) pure
    {
        m_hostTemplate = v.m_hostTemplate.dup;
        m_strict = v.m_strict;
        m_categoryId = v.m_categoryId;
    }

    @safe this(in string hostTemplate, in bool strict, in long categoryId) pure
    {
        m_hostTemplate = hostTemplate;
        m_strict = strict;
        m_categoryId = categoryId;
    }

    @safe const(string) hostTemplate() const pure
    {
        return m_hostTemplate;
    }

    @safe bool strict() const pure
    {
        return m_strict;
    }

    @safe long categoryId() const pure
    {
        return m_categoryId;
    }

    JSONValue toJSON() const
    {
        return JSONValue([
            "hostTemplate": JSONValue(m_hostTemplate),
            "strict": JSONValue(m_strict),
            "categoryId": JSONValue(m_categoryId),
         ]);
    }

    unittest
    {
        HostRuleValue value = new HostRuleValue("example.com", true, 1);
        const JSONValue v = value.toJSON();
        
        assert( v.object["hostTemplate"].str == "example.com" );
        assert( v.object["strict"].boolean == true );
        assert( v.object["categoryId"].integer == 1 );
    }

    void fromJSON(in JSONValue v)
    {
        m_hostTemplate = v.object["hostTemplate"].str;
        m_strict = v.object["strict"].boolean;
        m_categoryId = v.object["categoryId"].integer;
    }

    unittest
    {
        JSONValue v = JSONValue.emptyObject;
        v.object["hostTemplate"] = JSONValue("example.com");
        v.object["strict"] = JSONValue(true);
        v.object["categoryId"] = JSONValue(1L);

        HostRuleValue value = new HostRuleValue();
        value.fromJSON(v);
        
        assert( value.hostTemplate() == "example.com" );
        assert( value.strict() == true );
        assert( value.categoryId() == 1L );
    }

protected:
    string m_hostTemplate;
    bool m_strict;
    long m_categoryId;
}


class HostRuleRepository : RepositoryBase!(Key, HostRuleValue)
{
}

unittest
{
    HostRuleRepository r = new HostRuleRepository();
    r.create(new HostRuleValue());
}
