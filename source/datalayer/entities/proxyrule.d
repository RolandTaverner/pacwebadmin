module datalayer.entities.proxyrule;

import std.algorithm.iteration : map;
import std.array : array;
import std.json;

import datalayer.repository.repository;

class ProxyRuleValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in ProxyRuleValue v) pure
    {
        m_proxyId = v.m_proxyId;
        m_enabled = v.enabled;
        m_name = v.m_name;
        m_conditionIds = v.m_conditionIds.dup;
    }

    @safe this(in long proxyId, in bool enabled, in string name, in long[] conditionIds) pure
    {
        m_proxyId = proxyId;
        m_enabled = enabled;
        m_name = name;
        m_conditionIds = conditionIds.dup;
    }

    @safe long proxyId() const pure
    {
        return m_proxyId;
    }

    @safe bool enabled() const pure
    {
        return m_enabled;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

    @safe const(long[]) conditionIds() const pure
    {
        return m_conditionIds;
    }

    @safe override JSONValue toJSON() const
    {
        return JSONValue([
            "proxyId": JSONValue(proxyId()),
            "enabled": JSONValue(enabled()),
            "name": JSONValue(name()),
            "conditionIds": JSONValue(conditionIds())
        ]);
    }

    unittest
    {
        ProxyRuleValue value = new ProxyRuleValue(1, true, "name", [1, 2, 3]);
        const JSONValue v = value.toJSON();

        assert(v.object["proxyId"].integer == 1);
        assert(v.object["enabled"].boolean == true);
        assert(v.object["name"].str == "name");
        assert(v.object["conditionIds"].array.length == 3);
    }

    override void fromJSON(in JSONValue v)
    {
        m_proxyId = v.object["proxyId"].integer;
        m_enabled = v.object["enabled"].boolean;
        m_name = v.object["name"].str;
        m_conditionIds = array(v.object["conditionIds"].array.map!(jv => jv.integer));
    }

    unittest
    {
        JSONValue v = JSONValue.emptyObject;
        v.object["proxyId"] = JSONValue(1);
        v.object["enabled"] = JSONValue(true);
        v.object["name"] = JSONValue("name");
        v.object["conditionIds"] = JSONValue([1, 2, 3]);

        ProxyRuleValue value = new ProxyRuleValue();
        value.fromJSON(v);

        assert(value.proxyId() == 1);
        assert(value.enabled() == true);
        assert(value.name() == "name");
        assert(value.conditionIds().length == 3);
    }

protected:
    long m_proxyId;
    bool m_enabled;
    string m_name;
    long[] m_conditionIds;
}

alias ProxyRule = DataObject!(Key, ProxyRuleValue);

alias IProxyRuleListener = IListener!(ProxyRule);

class ProxyRuleRepository : RepositoryBase!(Key, ProxyRuleValue)
{
    this(IProxyRuleListener listener)
    {
        super(listener);
    }
}
