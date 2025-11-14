module web.api.pac;

import vibe.web.rest;
import vibe.http.server;

import web.api.proxyrule;

interface PACAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    PACList getAll();

    @method(HTTPMethod.GET) @path(":id")
    PACDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c")
    PACDTO create(in PACInputDTO c);

    @method(HTTPMethod.PUT) @path("/:id/update") @bodyParam("c")
    PACDTO update(in long _id, in PACInputDTO c);

    @method(HTTPMethod.DELETE) @path(":id")
    PACDTO remove(in long _id);

    @method(HTTPMethod.GET) @path("/:id/proxyrules")
    ProxyRulePriorityList getProxyRules(in long _id);

    @method(HTTPMethod.POST) @path("/:id/proxyrules/:prid")
    ProxyRulePriorityList addProxyRule(in long _id, in long _prid, @viaQuery("priority") long _priority);

    @method(HTTPMethod.PATCH) @path("/:id/proxyrules/:prid")
    ProxyRulePriorityList setProxyRulePriority(in long _id, in long _prid, @viaQuery("priority") long _priority);

    @method(HTTPMethod.DELETE) @path("/:id/proxyrules/:prid")
    ProxyRulePriorityList removeProxyRule(in long _id, in long _prid);
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

struct PACInputDTO
{
    @safe this(in string name,
        in string description,
        in ProxyRulePriorityInput[] proxyRules,
        in bool serve,
        in string servePath,
        in bool saveToFS,
        in string saveToFSPath) pure
    {
        this.name = name;
        this.description = description;
        this.proxyRules = proxyRules.dup;
        this.serve = serve;
        this.servePath = servePath;
        this.saveToFS = saveToFS;
        this.saveToFSPath = saveToFSPath;
    }

    string name;
    string description;
    ProxyRulePriorityInput[] proxyRules;
    bool serve;
    string servePath;
    bool saveToFS;
    string saveToFSPath;
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
        in string saveToFSPath) pure
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
    }

    long id;
    string name;
    string description;
    ProxyRulePriorityDTO[] proxyRules;
    bool serve;
    string servePath;
    bool saveToFS;
    string saveToFSPath;
}

struct ProxyRulePriorityList
{
    ProxyRulePriorityDTO[] proxyRules;
}

unittest
{
    const ProxyRulePriorityDTO[] proxyRules = [];

    auto p = PACDTO(1, "name", "desc", proxyRules, true, "serve", true, "save");

    assert(p.id == 1);
}
