module model.entities.category;

import std.exception : enforce;
import std.string;

import model.entities.common;
import model.errors.base;

class Category
{
    @safe this(in long id, in string name) pure
    {
        m_id = id;
        m_name = name;
    }

    @safe this(in Category other) pure
    {
        m_id = other.m_id;
        m_name = other.m_name;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

    mixin entityId!();

private:
    string m_name;
}

struct CategoryInput
{
    string name;

    @safe void validate() const pure
    {
        enforce!bool(name.strip().length != 0, new ConstraintError("name can't be empty"));
    }
}

struct CategoryFilter
{
    @safe this(in string name) pure
    {
        this.name = name;
    }

    string name;
}

class CategoryNotFound : NotFoundBase!(Category)
{
    mixin finalEntityErrorCtors!("not found");
}
