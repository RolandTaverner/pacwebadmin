module web.api.condition;

import std.typecons : Nullable;

import vibe.data.serialization : optional;
import vibe.http.server;
import vibe.web.rest;

import web.api.category;

interface ConditionAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/list")
    ConditionList getAll();

    @method(HTTPMethod.GET) @path("/list/:id")
    ConditionDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/list")
    ConditionDTO create(@viaBody() in ConditionCreateDTO c);

    @method(HTTPMethod.PUT) @path("/list/:id")
    ConditionDTO update(in long _id, @viaBody() in ConditionUpdateDTO c);

    @method(HTTPMethod.DELETE) @path("/list/:id")
    void remove(in long _id);
}

struct ConditionList
{
    ConditionDTO[] conditions;
}

struct ConditionCreateDTO
{
    string type;
    string expression;
    long categoryId;
}

struct ConditionUpdateDTO
{
    @optional Nullable!string type;
    @optional Nullable!string expression;
    @optional Nullable!long categoryId;
}

struct ConditionDTO
{
    @safe this(in long id, in string type, in string expression, in CategoryDTO category) pure
    {
        this.id = id;
        this.type = type;
        this.expression = expression;
        this.category = category;
    }

    @safe this(in ConditionDTO other) pure
    {
        this.id = other.id;
        this.type = other.type;
        this.expression = other.expression;
        this.category = other.category;
    }

    long id;
    string type;
    string expression;
    CategoryDTO category;
}
