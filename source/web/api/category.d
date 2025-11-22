module web.api.category;

import vibe.http.server;
import vibe.web.rest;

interface CategoryAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/list")
    CategoryList getAll();

    @method(HTTPMethod.POST) @path("/filter")
    CategoryList filter(@viaBody() in CategoryFilterDTO f);

    @method(HTTPMethod.GET) @path("/list/:id")
    CategoryDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/list")
    CategoryDTO create(@viaBody() in CategoryInputDTO c);

    @method(HTTPMethod.PUT) @path("/list/:id")
    CategoryDTO update(in long _id, @viaBody() in CategoryInputDTO c);

    @method(HTTPMethod.DELETE) @path("/list/:id")
    void remove(in long _id);
}

struct CategoryList
{
    CategoryDTO[] categories;
}

struct CategoryInputDTO
{
    @safe this(in string name) pure
    {
        this.name = name;
    }

    string name;
}

struct CategoryFilterDTO
{
    string name;
}

struct CategoryDTO
{
    @safe this(in long id, in string name) pure
    {
        this.id = id;
        this.name = name;
    }

    @safe this(in CategoryDTO other) pure
    {
        this.id = other.id;
        this.name = other.name;
    }

    long id;
    string name;
}
