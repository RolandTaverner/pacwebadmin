module datalayer.entities.category;

import std.json;

import datalayer.repository.repository;

class CategoryValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in CategoryValue v) pure
    {
        m_name = v.m_name.dup;
    }

    @safe this(in string name) pure
    {
        m_name = name;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

    @safe override JSONValue toJSON() const pure
    {
        return JSONValue(["name": JSONValue(name())]);
    }

    unittest
    {
        CategoryValue value = new CategoryValue("name");
        const JSONValue v = value.toJSON();

        assert(v.object["name"].str == "name");
    }

    override void fromJSON(in JSONValue v)
    {
        m_name = v.object["name"].str;
    }

    unittest
    {
        JSONValue v = JSONValue.emptyObject;
        v.object["name"] = JSONValue("name");

        CategoryValue value = new CategoryValue();
        value.fromJSON(v);

        assert(value.name() == "name");
    }

protected:
    string m_name;
}

alias Category = DataObject!(Key, CategoryValue);

alias ICategoryListener = IListener!(Category);

class CategoryRepository : RepositoryBase!(Key, CategoryValue)
{
    this(ICategoryListener listener)
    {
        super(listener);
    }
}
