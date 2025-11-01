module web.api.proxy;

import vibe.web.rest;
import vibe.http.server;


interface ProxiesAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    Proxies getAll();

    @method(HTTPMethod.GET) @path(":id")
    ProxyDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c") 
    ProxyDTO create(in NewProxyDTO c);

    @method(HTTPMethod.PUT) @path("/update") @bodyParam("c")
    ProxyDTO update(in ProxyDTO c);

    @method(HTTPMethod.DELETE) @path(":id")
    ProxyDTO remove(in long _id);
}

struct Proxies
{
    ProxyDTO[] proxies;
}

struct NewProxyDTO
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

    long id;
    string hostAddress;
    string description;
    bool builtIn;
}
