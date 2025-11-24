module model.entities.condition;

import std.algorithm : canFind, map;
import std.array;
import std.exception : enforce;
import std.string;
import std.traits : EnumMembers;
import std.typecons : Nullable;

import model.entities.category;
import model.entities.common;
import model.errors.base;

enum ConditionType : string
{
    hostDomainOnly = "host_domain_only",
    hostDomainSubdomain = "host_domain_subdomain",
    hostSubdomainOnly = "host_subdomain_only",
    urlShexpMatch = "url_shexp_match",
    urlRegexpMatch = "url_regexp_match",
}

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
    Nullable!string type;
    Nullable!string expression;
    Nullable!long categoryId;

    @safe void validate(bool update) const pure
    {
        if (!update)
        {
            enforce!bool(!type.isNull, new ConstraintError("type can't be null"));
            enforce!bool(!expression.isNull, new ConstraintError("expression can't be null"));
            enforce!bool(!categoryId.isNull, new ConstraintError("categoryId can't be null"));

            enforce!bool(type.get().strip().length != 0, new ConstraintError("type can't be empty"));

            enforce!bool(expression.get().strip().length != 0, 
                new ConstraintError("expression can't be empty"));
        }
        else
        {
            enforce!bool(type.isNull || type.get().strip().length != 0, 
                new ConstraintError("type can't be empty"));

            enforce!bool(expression.isNull || expression.get().strip().length != 0, 
                new ConstraintError("expression can't be empty"));
        }

        if (!type.isNull)
        {
            const auto conditionTypeValues = [EnumMembers!ConditionType]
                .map!(el => cast(string) el)
                .array;

            enforce!bool(conditionTypeValues.canFind(type.get()), new ConstraintError("invalid type"));
        }
    }
}

class ConditionNotFound : NotFoundBase!(Condition)
{
    mixin finalEntityErrorCtors!("not found");
}
