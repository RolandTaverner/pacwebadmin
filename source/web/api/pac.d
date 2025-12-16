module web.api.pac;

import std.typecons : Nullable;

import vibe.data.serialization : embedNullable, optional;
import vibe.http.server;
import vibe.web.auth : requiresAuth, anyAuth, auth, Role;
import vibe.web.rest;

import web.api.proxy;
import web.api.proxyrule;
import web.auth.common;

@requiresAuth!AuthInfo
interface PACAPI
{
@safe:
    @anyAuth @method(HTTPMethod.GET) @path("/list")
    PACList getAll();

    @anyAuth @method(HTTPMethod.GET) @path("/list/:id")
    PACDTO getById(in long _id);

    @auth(Role.writer) @method(HTTPMethod.POST) @path("/list")
    PACDTO create(@viaBody()  in PACCreateDTO c);

    @auth(Role.writer) @method(HTTPMethod.PUT) @path("/list/:id")
    PACDTO update(in long _id, @viaBody()  in PACUpdateDTO c);

    @auth(Role.writer) @method(HTTPMethod.DELETE) @path("/list/:id")
    void remove(in long _id);

    @anyAuth @method(HTTPMethod.GET) @path("/list/:id/proxyrules")
    ProxyRulePriorityList getProxyRules(in long _id);

    @auth(Role.writer) @method(HTTPMethod.POST) @path("/list/:id/proxyrules/:prid")
    ProxyRulePriorityList addProxyRule(in long _id, in long _prid, @viaQuery("priority") long _priority);

    @auth(Role.writer) @method(HTTPMethod.PATCH) @path("/list/:id/proxyrules/:prid")
    ProxyRulePriorityList setProxyRulePriority(in long _id, in long _prid, @viaQuery("priority") long _priority);

    @auth(Role.writer) @method(HTTPMethod.DELETE) @path("/list/:id/proxyrules/:prid")
    void removeProxyRule(in long _id, in long _prid);

    mixin authInterfaceMethod;
}

struct PACList
{
    PACDTO[] pacs;
}

struct ProxyRulePriorityInput
{
    long proxyRuleId;
    long priority;
}

struct PACCreateDTO
{
    string name;
    string description;
    ProxyRulePriorityInput[] proxyRules;
    bool serve;
    string servePath;
    bool saveToFS;
    string saveToFSPath;
    long fallbackProxyId;
}

struct PACUpdateDTO
{
    @optional Nullable!string name;
    @optional Nullable!string description;
    @optional Nullable!(ProxyRulePriorityInput[]) proxyRules;
    @optional Nullable!bool serve;
    @optional Nullable!string servePath;
    @optional Nullable!bool saveToFS;
    @optional Nullable!string saveToFSPath;
    @optional Nullable!long fallbackProxyId;
}

struct ProxyRulePriorityDTO
{
    @safe this(in ProxyRuleDTO proxyRule, in long priority) pure
    {
        this.proxyRule = ProxyRuleDTO(proxyRule);
        this.priority = priority;
    }

    @safe this(in ProxyRulePriorityDTO other) pure
    {
        this.proxyRule = ProxyRuleDTO(other.proxyRule);
        this.priority = other.priority;
    }

    ProxyRuleDTO proxyRule;
    long priority;
}

struct PACDTO
{
    @safe this(in long id,
        in string name,
        in string description,
        in Nullable!(ProxyRulePriorityDTO[]) proxyRules,
        in bool serve,
        in string servePath,
        in bool saveToFS,
        in string saveToFSPath,
        in ProxyDTO fallbackProxy) pure
    {
        this.id = id;
        this.name = name;
        this.description = description;

        if (!proxyRules.isNull())
        {
            this.proxyRules = [];

            foreach (pr; proxyRules.get())
            {
                this.proxyRules.get() ~= ProxyRulePriorityDTO(pr);
            }
        }

        this.serve = serve;
        this.servePath = servePath;
        this.saveToFS = saveToFS;
        this.saveToFSPath = saveToFSPath;
        this.fallbackProxy = ProxyDTO(fallbackProxy);
    }

    long id;
    string name;
    string description;
    @embedNullable Nullable!(ProxyRulePriorityDTO[]) proxyRules;
    bool serve;
    string servePath;
    bool saveToFS;
    string saveToFSPath;
    ProxyDTO fallbackProxy;
}

struct ProxyRulePriorityList
{
    ProxyRulePriorityDTO[] proxyRules;
}

unittest
{
    const Nullable!(ProxyRulePriorityDTO[]) proxyRules = [];

    auto p = PACDTO(1, "name", "desc", proxyRules, true, "serve", true, "save", ProxyDTO(1, "DIRECT", "", ""));

    assert(p.id == 1);
}
