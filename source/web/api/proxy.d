module web.api.proxy;

import vibe.data.serialization : optional;

import vibe.web.rest;
import vibe.http.server;

interface ProxyAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    ProxyList getAll();

    @method(HTTPMethod.POST) @path("/filter")  @bodyParam("f")
    ProxyList filter(in ProxyFilterDTO f);

    @method(HTTPMethod.GET) @path(":id")
    ProxyDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c")
    ProxyDTO create(in ProxyCreateDTO c);

    @method(HTTPMethod.PUT) @path("/:id/update") @bodyParam("p")
    ProxyDTO update(in long _id, in ProxyUpdateDTO p);

    @method(HTTPMethod.DELETE) @path(":id")
    void remove(in long _id);
}

struct ProxyList
{
    ProxyDTO[] proxies;
}

struct ProxyCreateDTO
{
    @safe this(in string type, in string address, in string description) pure
    {
        this.type = type;
        this.address = address;
        this.description = description;
    }

    string type;
    string address;
    string description;
}

struct ProxyUpdateDTO
{
    @safe this(in string type, in string address, in string description) pure
    {
        this.type = type;
        this.address = address;
        this.description = description;
    }

    @optional string type;
    @optional string address;
    @optional string description;
}

struct ProxyFilterDTO
{
    @optional string type;
    @optional string address;
}

struct ProxyDTO
{
    @safe this(in long id, in string type, in string address, in string description) pure
    {
        this.id = id;
        this.type = type;
        this.address = address;
        this.description = description;
    }

    @safe this(in ProxyDTO other) pure
    {
        this.id = other.id;
        this.type = other.type;
        this.address = other.address;
        this.description = other.description;
    }

    long id;
    string type;
    string address;
    string description;
}
