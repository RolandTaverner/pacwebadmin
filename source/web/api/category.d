module web.api.category;

import vibe.http.server;
import vibe.web.auth : requiresAuth, anyAuth, auth, Role;
import vibe.web.rest;

import web.auth.common;

@requiresAuth!AuthInfo
interface CategoryAPI
{
@safe:
    @anyAuth @method(HTTPMethod.GET) @path("/list")
    CategoryList getAll();

    @anyAuth @method(HTTPMethod.POST) @path("/filter")
    CategoryList filter(@viaBody() in CategoryFilterDTO f);

    @anyAuth @method(HTTPMethod.GET) @path("/list/:id")
    CategoryDTO getById(in long _id);

    @auth(Role.writer) @method(HTTPMethod.POST) @path("/list")
    CategoryDTO create(@viaBody() in CategoryInputDTO c);

    @auth(Role.writer) @method(HTTPMethod.PUT) @path("/list/:id")
    CategoryDTO update(in long _id, @viaBody() in CategoryInputDTO c);

    @auth(Role.writer) @method(HTTPMethod.DELETE) @path("/list/:id")
    void remove(in long _id);

    mixin authInterfaceMethod;
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
