module model.category;

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
        m_name = other.m_name.dup;
    }

    @safe long id() const pure
    {
        return m_id;
    }

    @safe const(string) name() const pure
    {
        return m_name;
    }

private:
    long m_id;
    string m_name;
}


class CategoryNotFound : NotFoundBase!(Category)
{
    mixin finalEntityErrorCtors!("not found");
}
