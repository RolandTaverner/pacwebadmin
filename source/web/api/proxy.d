module web.api.proxy;

import vibe.web.rest;
import vibe.http.server;


interface ProxyAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    ProxyList getAll();

    @method(HTTPMethod.GET) @path(":id")
    ProxyDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c") 
    ProxyDTO create(in ProxyInputDTO c);

    @method(HTTPMethod.PUT) @path("/:id/update") @bodyParam("p")
    ProxyDTO update(in long _id, in ProxyInputDTO p);

    @method(HTTPMethod.DELETE) @path(":id")
    ProxyDTO remove(in long _id);
}

struct ProxyList
{
    ProxyDTO[] proxies;
}

struct ProxyInputDTO
{
    @safe this(in string hostAddress, in string description, in bool builtIn) pure
    {
        this.hostAddress = hostAddress.dup;
        this.description = description.dup;
        this.builtIn = builtIn;
    }

    string hostAddress;
    string description;
    bool builtIn;
}

struct ProxyDTO
{
    @safe this(in long id, in string hostAddress, in string description, in bool builtIn) pure
    {
        this.id = id;
        this.hostAddress = hostAddress.dup;
        this.description = description.dup;
        this.builtIn = builtIn;
    }

    @safe this(in ProxyDTO other) pure
    {
        this.id = other.id;
        this.hostAddress = other.hostAddress.dup;
        this.description = other.description.dup;
        this.builtIn = other.builtIn;
    }

    long id;
    string hostAddress;
    string description;
    bool builtIn;
}
