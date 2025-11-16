module datalayer.entities.condition;

import std.json;

import datalayer.repository.repository;

class ConditionValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in ConditionValue v) pure
    {
        m_type = v.m_type;
        m_expression = v.m_expression;
        m_categoryId = v.m_categoryId;
    }

    @safe this(in string type, in string expression, in long categoryId) pure
    {
        m_type = type;
        m_expression = expression;
        m_categoryId = categoryId;
    }

    @safe const(string) type() const pure
    {
        return m_type;
    }

    @safe const(string) expression() const pure
    {
        return m_expression;
    }

    @safe long categoryId() const pure
    {
        return m_categoryId;
    }

    @safe override JSONValue toJSON() const
    {
        return JSONValue([
            "type": JSONValue(m_type),
            "expression": JSONValue(m_expression),
            "categoryId": JSONValue(m_categoryId),
        ]);
    }

    unittest
    {
        ConditionValue value = new ConditionValue("domain", "example.com", true);
        const JSONValue v = value.toJSON();

        assert(v.object["type"].str == "domain");
        assert(v.object["expression"].str == "example.com");
        assert(v.object["categoryId"].integer == 1);
    }

    override void fromJSON(in JSONValue v)
    {
        m_type = v.object["type"].str;
        m_expression = v.object["expression"].str;
        m_categoryId = v.object["categoryId"].integer;
    }

    unittest
    {
        JSONValue v = JSONValue.emptyObject;
        v.object["type"] = JSONValue("domain");
        v.object["expression"] = JSONValue("example.com");
        v.object["categoryId"] = JSONValue(1L);

        ConditionValue value = new ConditionValue();
        value.fromJSON(v);

        assert(value.type() == "domain");
        assert(value.expression() == "example.com");
        assert(value.categoryId() == 1L);
    }

protected:
    string m_type;
    string m_expression;
    long m_categoryId;
}

alias Condition = DataObject!(Key, ConditionValue);

alias IConditionListener = IListener!(Condition);

class ConditionRepository : RepositoryBase!(Key, ConditionValue)
{
    this(IConditionListener listener)
    {
        super(listener);
    }
}
