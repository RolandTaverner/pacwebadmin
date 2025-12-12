module web.api.proxy;

import std.typecons : Nullable;

import vibe.data.serialization : optional;
import vibe.http.server;
import vibe.web.auth : requiresAuth, anyAuth, auth, Role;
import vibe.web.rest;

import web.auth.common;

@requiresAuth!AuthInfo
interface ProxyAPI
{
@safe:
    @anyAuth @method(HTTPMethod.GET) @path("/list")
    ProxyList getAll();

    @anyAuth @method(HTTPMethod.POST) @path("/filter")
    ProxyList filter(@viaBody() in ProxyFilterDTO f);

    @anyAuth @method(HTTPMethod.GET) @path("/list/:id")
    ProxyDTO getById(in long _id);

    @auth(Role.writer) @method(HTTPMethod.POST) @path("/list")
    ProxyDTO create(@viaBody() in ProxyCreateDTO c);

    @auth(Role.writer) @method(HTTPMethod.PUT) @path("/list/:id")
    ProxyDTO update(in long _id, @viaBody() in ProxyUpdateDTO p);

    @auth(Role.writer) @method(HTTPMethod.DELETE) @path("/list/:id")
    void remove(in long _id);

    mixin authInterfaceMethod;
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
