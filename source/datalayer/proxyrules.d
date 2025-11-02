module datalayer.proxyrules;

import std.algorithm.iteration : map;
import std.array : array;
import std.json;

import datalayer.repository.repository;


class ProxyRulesValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in ProxyRulesValue v) pure
    {
        m_proxyId = v.m_proxyId;
        m_enabled = v.enabled;
        m_hostRuleIds = v.m_hostRuleIds.dup;        
    }

    @safe this(in long proxyId, in bool enabled, in long[] hostRuleIds) pure
    {
        m_proxyId = proxyId;
        m_enabled = enabled;
        m_hostRuleIds = hostRuleIds.dup;
    }

    @safe long proxyId() const pure
    {
        return m_proxyId;
    }

    @safe bool enabled() const pure
    {
        return m_enabled;
    }

    @safe const(long[]) hostRuleIds() const pure
    {
        return m_hostRuleIds;
    }

    JSONValue toJSON() const pure
    {
        return JSONValue([
                "proxyId": JSONValue(proxyId()),
                "enabled": JSONValue(enabled()),
                "hostRuleIds": JSONValue(hostRuleIds())
            ]);
    }

    unittest
    {
        ProxyRulesValue value = new ProxyRulesValue(1, true, [1,2,3]);
        const JSONValue v = value.toJSON();
        
        assert( v.object["proxyId"].integer == 1 );
        assert( v.object["enabled"].boolean == true );
        assert( v.object["hostRuleIds"].array.length == 3 );
    }

    void fromJSON(in JSONValue v)
    {
        m_proxyId = v.object["proxyId"].integer;
        m_enabled = v.object["enabled"].boolean;
        m_hostRuleIds = array(v.object["hostRuleIds"].array.map!( jv => jv.integer));
    }

    unittest
    {
        JSONValue v = JSONValue.emptyObject;
        v.object["proxyId"] = JSONValue(1);
        v.object["enabled"] = JSONValue(true);
        v.object["hostRuleIds"] = JSONValue([1,2,3]);

        ProxyRulesValue value = new ProxyRulesValue();
        value.fromJSON(v);
        
        assert( value.proxyId() == 1 );
        assert( value.enabled() == true );
        assert( value.hostRuleIds().length == 3 );
    }

protected:
    long m_proxyId;
    bool m_enabled;
    long[] m_hostRuleIds;
}

class ProxyRulesRepository : RepositoryBase!(Key, ProxyRulesValue)
{
}

unittest
{
    ProxyRulesRepository r = new ProxyRulesRepository();
    r.create(new ProxyRulesValue());
}
