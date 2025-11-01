module datalayer.pac;

import std.algorithm.iteration : map;
import std.array : array;
import std.json;

import datalayer.repository.repository;


class PACValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in PACValue v) pure
    {
        m_name = v.m_name.dup;
        m_description = v.m_description.dup;
    }

    @safe this(in string name, in string description, in long[] proxyRuleIds) pure
    {
        m_name = name;
        m_description = description;
        m_proxyRuleIds = proxyRuleIds.dup;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

    @safe const(string) description() const pure
    {
        return m_description;
    }

    @safe const(long[]) proxyRuleIds() const pure
    {
        return m_proxyRuleIds;
    }

    JSONValue toJSON() const
    {
        return JSONValue([
                "name": JSONValue(name()),
                "description": JSONValue(description()),
                "proxyRuleIds": JSONValue(proxyRuleIds())
            ]);
    }

    unittest
    {
        PACValue value = new PACValue("name", "description", [1,2,3]);
        const JSONValue v = value.toJSON();
        
        assert( v.object["name"].str == "name" );
        assert( v.object["description"].str == "description" );
        assert( v.object["proxyRuleIds"].array.length == 3 );
    }

    void fromJSON(in JSONValue v)
    {
        m_name = v.object["name"].str;
        m_description = v.object["description"].str;
        m_proxyRuleIds = array(v.object["proxyRuleIds"].array.map!( jv => jv.integer));
    }

    unittest
    {
        JSONValue v = JSONValue.emptyObject;
        v.object["name"] = JSONValue("name");
        v.object["description"] = JSONValue("description");
        v.object["proxyRuleIds"] = JSONValue([1,2,3]);

        PACValue value = new PACValue();
        value.fromJSON(v);
        
        assert( value.name() == "name" );
        assert( value.description() == "description" );
        assert( value.proxyRuleIds().length == 3 );
    }

protected:
   string m_name;
   string m_description;
   long[] m_proxyRuleIds;
}


class PACRepository : RepositoryBase!(Key, PACValue)
{
}

unittest
{
    PACRepository r = new PACRepository();
    r.create(new PACValue());
}
