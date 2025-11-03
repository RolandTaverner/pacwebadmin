module model.entities.hostrule;

import model.entities.category;
import model.entities.common;
import model.errors.base;

class HostRule
{
    @safe this(in long id, in string hostTemplate, in bool strict, in Category category) pure
    {
        m_id = id;
        m_hostTemplate = hostTemplate.dup;
        m_strict = strict;
        m_category = new Category(category);
    }

    @safe this(in HostRule other) pure
    {
        m_id = other.m_id;
        m_hostTemplate = other.m_hostTemplate.dup;
        m_strict = other.m_strict;
        m_category = new Category(other.m_category);
    }

    @safe const(string) hostTemplate() const pure
    {
        return m_hostTemplate;
    }

    @safe bool strict() const pure
    {
        return m_strict;
    }

    @safe const(Category) category() const pure
    {
        return m_category;
    }

    mixin entityId!();

private:
    string m_hostTemplate;
    bool m_strict;
    Category m_category;
}

struct HostRuleInput
{
    string hostTemplate;
    bool strict;
    long categoryId;
}

class HostRuleNotFound : NotFoundBase!(HostRule)
{
    mixin finalEntityErrorCtors!("not found");
}
