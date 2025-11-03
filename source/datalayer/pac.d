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
        m_proxyRulesIds = v.m_proxyRulesIds.dup;
        m_serve = v.m_serve;
        m_servePath = v.m_servePath;
        m_saveToFS = v.m_saveToFS;
        m_saveToFSPath = v.m_saveToFSPath;
    }

    @safe this(in string name, in string description, in long[] proxyRulesIds,
        bool serve, string servePath, bool saveToFS, string saveToFSPath) pure
    {
        m_name = name;
        m_description = description;
        m_proxyRulesIds = proxyRulesIds.dup;
        m_serve = serve;
        m_servePath = servePath.dup;
        m_saveToFS = saveToFS;
        m_saveToFSPath = saveToFSPath.dup;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

    @safe const(string) description() const pure
    {
        return m_description;
    }

    @safe const(long[]) proxyRulesIds() const pure
    {
        return m_proxyRulesIds;
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

    JSONValue toJSON() const
    {
        return JSONValue([
            "name": JSONValue(name()),
            "description": JSONValue(description()),
            "proxyRulesIds": JSONValue(proxyRulesIds()),
            "serve": JSONValue(serve()),
            "servePath": JSONValue(servePath()),
            "saveToFS": JSONValue(saveToFS()),
            "saveToFSPath": JSONValue(saveToFSPath()),
        ]);
    }

    unittest
    {
        PACValue value = new PACValue("name", "description", [1, 2, 3], true, "serve", true, "save");
        const JSONValue v = value.toJSON();

        assert(v.object["name"].str == "name");
        assert(v.object["description"].str == "description");
        assert(v.object["proxyRulesIds"].array.length == 3);
        assert(v.object["serve"].boolean == true);
        assert(v.object["servePath"].str == "serve");
        assert(v.object["saveToFS"].boolean == true);
        assert(v.object["saveToFSPath"].str == "save");
    }

    void fromJSON(in JSONValue v)
    {
        m_name = v.object["name"].str;
        m_description = v.object["description"].str;
        m_proxyRulesIds = array(v.object["proxyRulesIds"].array.map!(jv => jv.integer));
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
        v.object["proxyRulesIds"] = JSONValue([1, 2, 3]);
        v.object["serve"] = JSONValue(true);
        v.object["servePath"] = JSONValue("serve");
        v.object["saveToFS"] = JSONValue(true);
        v.object["saveToFSPath"] = JSONValue("save");

        PACValue value = new PACValue();
        value.fromJSON(v);

        assert(value.name() == "name");
        assert(value.description() == "description");
        assert(value.proxyRulesIds().length == 3);
        assert(value.serve() == true);
        assert(value.servePath() == "serve");
        assert(value.saveToFS() == true);
        assert(value.saveToFSPath() == "save");
    }

protected:
    string m_name;
    string m_description;
    long[] m_proxyRulesIds;
    bool m_serve;
    string m_servePath;
    bool m_saveToFS;
    string m_saveToFSPath;
}

class PACRepository : RepositoryBase!(Key, PACValue)
{
}

unittest
{
    PACRepository r = new PACRepository();
    r.create(new PACValue());
}
