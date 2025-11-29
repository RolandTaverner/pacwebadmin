module web.api.pac;

import std.typecons : Nullable;

import vibe.data.serialization : optional;
import vibe.http.server;
import vibe.web.rest;

import web.api.proxy;
import web.api.proxyrule;

interface PACAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/list")
    PACList getAll();

    @method(HTTPMethod.GET) @path("/list/:id")
    PACDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/list")
    PACDTO create(@viaBody() in PACCreateDTO c);

    @method(HTTPMethod.PUT) @path("/list/:id")
    PACDTO update(in long _id, @viaBody() in PACUpdateDTO c);

    @method(HTTPMethod.DELETE) @path("/list/:id")
    void remove(in long _id);

    @method(HTTPMethod.GET) @path("/list/:id/proxyrules")
    ProxyRulePriorityList getProxyRules(in long _id);

    @method(HTTPMethod.POST) @path("/list/:id/proxyrules/:prid")
    ProxyRulePriorityList addProxyRule(in long _id, in long _prid, @viaQuery("priority") long _priority);

    @method(HTTPMethod.PATCH) @path("/list/:id/proxyrules/:prid")
    ProxyRulePriorityList setProxyRulePriority(in long _id, in long _prid, @viaQuery("priority") long _priority);

    @method(HTTPMethod.DELETE) @path("/list/:id/proxyrules/:prid")
    void removeProxyRule(in long _id, in long _prid);
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
    @optional ProxyRulePriorityInput[] proxyRules;
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
        in ProxyRulePriorityDTO[] proxyRules,
        in bool serve,
        in string servePath,
        in bool saveToFS,
        in string saveToFSPath,
        in ProxyDTO fallbackProxy) pure
    {
        this.id = id;
        this.name = name;
        this.description = description;

        //this.proxyRules = proxyRules.dup;
        foreach (pr; proxyRules)
        {
            this.proxyRules ~= ProxyRulePriorityDTO(pr);
        }

        this.serve = serve;
        this.servePath = servePath;
        this.saveToFS = saveToFS;
        this.saveToFSPath = saveToFSPath;
        this.fallbackProxy = ProxyDTO(fallbackProxy);
    }

    @safe this(in PACDTO other) pure
    {
        this.id = other.id;
        this.name = other.name;
        this.description = other.description;

        //this.proxyRules = other.proxyRules.dup;
        foreach (pr; other.proxyRules)
        {
            this.proxyRules ~= ProxyRulePriorityDTO(pr);
        }

        this.serve = other.serve;
        this.servePath = other.servePath;
        this.saveToFS = other.saveToFS;
        this.saveToFSPath = other.saveToFSPath;
        this.fallbackProxy = ProxyDTO(other.fallbackProxy);
    }

    long id;
    string name;
    string description;
    ProxyRulePriorityDTO[] proxyRules;
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
    const ProxyRulePriorityDTO[] proxyRules = [];

    auto p = PACDTO(1, "name", "desc", proxyRules, true, "serve", true, "save", ProxyDTO(1, "DIRECT", "", ""));

    assert(p.id == 1);
}
