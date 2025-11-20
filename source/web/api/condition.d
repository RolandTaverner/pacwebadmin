module web.api.condition;

import vibe.data.serialization : optional;
import vibe.http.server;
import vibe.web.rest;

import web.api.category;

interface ConditionAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    ConditionList getAll();

    @method(HTTPMethod.GET) @path(":id")
    ConditionDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c")
    ConditionDTO create(in ConditionCreateDTO c);

    @method(HTTPMethod.PUT) @path("/:id/update") @bodyParam("c")
    ConditionDTO update(in long _id, in ConditionUpdateDTO c);

    @method(HTTPMethod.DELETE) @path(":id")
    void remove(in long _id);
}

struct ConditionList
{
    ConditionDTO[] conditions;
}

struct ConditionCreateDTO
{
    @safe this(in string type, in string expression, in long categoryId) pure
    {
        this.type = type;
        this.expression = expression;
        this.categoryId = categoryId;
    }

    string type;
    string expression;
    long categoryId;
}

struct ConditionUpdateDTO
{
    @safe this(in string type, in string expression, in long categoryId) pure
    {
        this.type = type;
        this.expression = expression;
        this.categoryId = categoryId;
    }

    @optional string type;
    @optional string expression;
    @optional long categoryId;
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
        this.type =  other.type;
        this.expression =  other.expression;
        this.category = other.category;
    }

    long id;
    string type;
    string expression;
    CategoryDTO category;
}
