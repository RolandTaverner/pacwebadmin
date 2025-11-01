module web.api.category;

import vibe.web.rest;
import vibe.http.server;


interface CategoriesAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    Categories getAll();

    @method(HTTPMethod.GET) @path(":id")
    CategoryDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c") 
    CategoryDTO create(in NewCategoryDTO c);

    @method(HTTPMethod.PUT) @path("/update") @bodyParam("c")
    CategoryDTO update(in CategoryDTO c);

    @method(HTTPMethod.DELETE) @path(":id")
    CategoryDTO remove(in long _id);
}

struct Categories
{
    CategoryDTO[] categories;
}

struct NewCategoryDTO
{
    @safe this(in string name) pure {
        this.name = name.dup;
    }

    string name;
}

struct CategoryDTO
{
    @safe this(in long id, in string name) pure {
        this.id = id;
        this.name = name.dup;
    }

    long id;
    string name;
}
