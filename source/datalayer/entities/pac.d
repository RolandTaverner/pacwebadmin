module datalayer.entities.pac;

import std.algorithm.iteration : map;
import std.array : array;
import std.json;
import std.typecons : tuple, Tuple;

import datalayer.repository.repository;

struct ProxyRulePriority
{
    this(long proxyRuleId, long priority)
    {
        this.proxyRuleId = proxyRuleId;
        this.priority = priority;
    }

    long proxyRuleId;
    long priority;
}

class PACValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in PACValue v) pure
    {
        m_name = v.m_name;
        m_description = v.m_description;
        m_proxyRules = v.m_proxyRules.dup;
        m_serve = v.m_serve;
        m_servePath = v.m_servePath;
        m_saveToFS = v.m_saveToFS;
        m_saveToFSPath = v.m_saveToFSPath;
    }

    @safe this(in string name,
        in string description,
        in ProxyRulePriority[] proxyRules,
        in bool serve,
        in string servePath,
        in bool saveToFS,
        in string saveToFSPath) pure
    {
        m_name = name;
        m_description = description;
        m_proxyRules = proxyRules.dup;
        m_serve = serve;
        m_servePath = servePath;
        m_saveToFS = saveToFS;
        m_saveToFSPath = saveToFSPath;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

    @safe const(string) description() const pure
    {
        return m_description;
    }

    @safe const(ProxyRulePriority[]) proxyRules() const pure
    {
        return m_proxyRules;
    }

    @safe bool serve() const pure
    {
        return m_serve;
    }

    @safe const(string) servePath() const pure
    {
        return m_servePath;
    }

    @safe bool saveToFS() const pure
    {
        return m_saveToFS;
    }

    @safe const(string) saveToFSPath() const pure
    {
        return m_saveToFSPath;
    }

    @safe override JSONValue toJSON() const pure
    {
        return JSONValue([
            "name": JSONValue(name()),
            "description": JSONValue(description()),
            "proxyRules": JSONValue(m_proxyRules
                    .map!(i => JSONValue([
                            "id": JSONValue(i.proxyRuleId),
                            "priority": JSONValue(i.priority)
                        ])).array),
            "serve": JSONValue(serve()),
            "servePath": JSONValue(servePath()),
            "saveToFS": JSONValue(saveToFS()),
            "saveToFSPath": JSONValue(saveToFSPath()),
        ]);
    }

    unittest
    {
        PACValue value = new PACValue("name",
            "description",
            [
                ProxyRulePriority(1, 1),
                ProxyRulePriority(2, 2),
                ProxyRulePriority(3, 3)
            ],
            true,
            "serve",
            true,
            "save");
        const JSONValue v = value.toJSON();

        assert(v.object["name"].str == "name");
        assert(v.object["description"].str == "description");
        assert(v.object["proxyRules"].array.length == 3);
        assert(v.object["serve"].boolean == true);
        assert(v.object["servePath"].str == "serve");
        assert(v.object["saveToFS"].boolean == true);
        assert(v.object["saveToFSPath"].str == "save");
    }

    override void fromJSON(in JSONValue v)
    {
        m_name = v.object["name"].str;
        m_description = v.object["description"].str;
        m_proxyRules = v.object["proxyRules"]
            .array
            .map!(jv => ProxyRulePriority(jv.object["id"].integer, jv.object["priority"].integer))
            .array;
        m_serve = v.object["serve"].boolean;
        m_servePath = v.object["servePath"].str;
        m_saveToFS = v.object["saveToFS"].boolean;
        m_saveToFSPath = v.object["saveToFSPath"].str;
    }

    unittest
    {
        JSONValue v = JSONValue.emptyObject;
        v.object["name"] = JSONValue("name");
        v.object["description"] = JSONValue("description");
        v.object["proxyRules"] = JSONValue([
            JSONValue(["id": JSONValue(1), "priority": JSONValue(1)]),
            JSONValue(["id": JSONValue(2), "priority": JSONValue(2)]),
            JSONValue(["id": JSONValue(3), "priority": JSONValue(3)]),
        ]);
        v.object["serve"] = JSONValue(true);
        v.object["servePath"] = JSONValue("serve");
        v.object["saveToFS"] = JSONValue(true);
        v.object["saveToFSPath"] = JSONValue("save");

        PACValue value = new PACValue();
        value.fromJSON(v);

        assert(value.name() == "name");
        assert(value.description() == "description");
        assert(value.proxyRules().length == 3);
        assert(value.serve() == true);
        assert(value.servePath() == "serve");
        assert(value.saveToFS() == true);
        assert(value.saveToFSPath() == "save");
    }

protected:
    string m_name;
    string m_description;
    ProxyRulePriority[] m_proxyRules;
    bool m_serve;
    string m_servePath;
    bool m_saveToFS;
    string m_saveToFSPath;
}

alias PAC = DataObject!(Key, PACValue);

alias IPACListener = IListener!(PAC);

class PACRepository : RepositoryBase!(Key, PACValue)
{
    this(IPACListener listener)
    {
        super(listener);
    }
}
