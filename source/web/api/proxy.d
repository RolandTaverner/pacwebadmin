module web.api.proxy;

import std.typecons : Nullable;

import vibe.data.serialization : optional;
import vibe.http.server;
import vibe.web.rest;

interface ProxyAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/list")
    ProxyList getAll();

    @method(HTTPMethod.POST) @path("/filter")
    ProxyList filter(@viaBody() in ProxyFilterDTO f);

    @method(HTTPMethod.GET) @path("/list/:id")
    ProxyDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/list")
    ProxyDTO create(@viaBody() in ProxyCreateDTO c);

    @method(HTTPMethod.PUT) @path("/list/:id")
    ProxyDTO update(in long _id, @viaBody() in ProxyUpdateDTO p);

    @method(HTTPMethod.DELETE) @path("/list/:id")
    void remove(in long _id);
}

struct ProxyList
{
    ProxyDTO[] proxies;
}

struct ProxyCreateDTO
{
    string type;
    @optional string address;
    @optional string description;
}

struct ProxyUpdateDTO
{
    @optional Nullable!string type;
    @optional Nullable!string address;
    @optional Nullable!string description;
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
