module model.entities.category;

import model.entities.common;
import model.errors.base;


class Category 
{
    @safe this(in long id, in string name) pure
    {
        m_id = id;
        m_name = name.dup;
    }

    @safe this(in Category other) pure
    {
        m_id = other.m_id;
        m_name = other.m_name.dup;
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
}


class CategoryNotFound : NotFoundBase!(Category)
{
    mixin finalEntityErrorCtors!("not found");
}
