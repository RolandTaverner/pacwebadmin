module model.entities.condition;

import std.exception : enforce;
import std.string;

import model.entities.category;
import model.entities.common;
import model.errors.base;

class Condition
{
    @safe this(in long id, in string type, in string expression, in Category category) pure
    {
        m_id = id;
        m_type = type;
        m_expression = expression;
        m_category = new Category(category);
    }

    @safe this(in Condition other) pure
    {
        m_id = other.m_id;
        m_type = other.m_type;
        m_expression = other.m_expression;
        m_category = new Category(other.m_category);
    }

    @safe const(string) type() const pure
    {
        return m_type;
    }

    @safe const(string) expression() const pure
    {
        return m_expression;
    }

    @safe const(Category) category() const pure
    {
        return m_category;
    }

    mixin entityId!();

private:
    string m_type;
    string m_expression;
    Category m_category;
}

struct ConditionInput
{
    string type;
    string expression;
    long categoryId;

    @safe void validate() const pure
    {
        enforce!bool(type.strip().length != 0, new ConstraintError("type can't be empty"));
        enforce!bool(expression.strip().length != 0, new ConstraintError("expression can't be empty"));
    }
}

class ConditionNotFound : NotFoundBase!(Condition)
{
    mixin finalEntityErrorCtors!("not found");
}
