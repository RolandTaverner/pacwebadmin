module web.api.pac;

import vibe.web.rest;
import vibe.http.server;

import web.api.proxyrules;


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
    ProxyRulesList getProxyRules(in long _id);

    @method(HTTPMethod.POST) @path("/:id/proxyrules/:prid")
    ProxyRulesList addProxyRules(in long _id, in long _prid);

    @method(HTTPMethod.DELETE) @path("/:id/proxyrules/:prid")
    ProxyRulesList removeProxyRules(in long _id, in long _prid);
}


struct PACList
{
    PACDTO[] pacs;
}


struct PACInputDTO
{
    @safe this(in string name, in string description, in long[] proxyRulesIds, 
        in bool serve, in string servePath, in bool saveToFS, in string saveToFSPath) pure
    {
        this.name = name.dup;
        this.description = description.dup;
        this.proxyRulesIds = proxyRulesIds.dup;
        this.serve = serve;
        this.servePath = servePath.dup;
        this.saveToFS = saveToFS;
        this.saveToFSPath = saveToFSPath.dup;
    }

    string name;
    string description;
    long[] proxyRulesIds;
    bool serve;
    string servePath;
    bool saveToFS;
    string saveToFSPath;
}


struct PACDTO
{
    @safe this(in long id, in string name, in string description, in ProxyRulesDTO[] proxyRules, 
        in bool serve, in string servePath, in bool saveToFS, in string saveToFSPath) pure
    {
        this.id = id;
        this.name = name.dup;
        this.description = description.dup;

        //this.proxyRules = proxyRules.dup;
        foreach (pr; proxyRules)
        {
            this.proxyRules ~= ProxyRulesDTO(pr);
        }

        this.serve = serve;
        this.servePath = servePath.dup;
        this.saveToFS = saveToFS;
        this.saveToFSPath = saveToFSPath.dup;
    }

    @safe this(in PACDTO other) pure
    {
        this.id = other.id;
        this.name = other.name.dup;
        this.description = other.description.dup;

        //this.proxyRules = other.proxyRules.dup;
        foreach (pr; other.proxyRules)
        {
            this.proxyRules ~= ProxyRulesDTO(pr);
        }

        this.serve = other.serve;
        this.servePath = other.servePath.dup;
        this.saveToFS = other.saveToFS;
        this.saveToFSPath = other.saveToFSPath.dup;
    }

    long id;
    string name;
    string description;
    ProxyRulesDTO[] proxyRules;
    bool serve;
    string servePath;
    bool saveToFS;
    string saveToFSPath;
}

unittest
{
    const ProxyRulesDTO[] proxyRules = [];
    
    auto p = PACDTO(1, "name", "desc", proxyRules, true, "serve", true, "save");
    
    assert( p.id == 1 );
}
