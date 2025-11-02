module web.api.category;

import vibe.web.rest;
import vibe.http.server;


interface CategoryAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    CategoryList getAll();

    @method(HTTPMethod.GET) @path(":id")
    CategoryDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c") 
    CategoryDTO create(in CategoryInputDTO c);

    @method(HTTPMethod.PUT) @path("/:id/update") @bodyParam("c")
    CategoryDTO update(in long _id, in CategoryInputDTO c);

    @method(HTTPMethod.DELETE) @path(":id")
    CategoryDTO remove(in long _id);
}


struct CategoryList
{
    CategoryDTO[] categories;
}


struct CategoryInputDTO
{
    @safe this(in string name) pure
    {
        this.name = name.dup;
    }

    string name;
}


struct CategoryDTO
{
    @safe this(in long id, in string name) pure
    {
        this.id = id;
        this.name = name.dup;
    }

    @safe this(in CategoryDTO other) pure
    {
        this.id = other.id;
        this.name = other.name.dup;
    }

    long id;
    string name;
}
