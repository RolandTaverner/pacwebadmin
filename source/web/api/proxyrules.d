module web.api.proxyrules;

import vibe.web.rest;
import vibe.http.server;

import web.api.hostrule;
import web.api.proxy;

interface ProxyRulesAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    ProxyRulesList getAll();

    @method(HTTPMethod.GET) @path(":id")
    ProxyRulesDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c") 
    ProxyRulesDTO create(in ProxyRulesInputDTO c);

    @method(HTTPMethod.PUT) @path("/:id/update") @bodyParam("c")
    ProxyRulesDTO update(in long _id, in ProxyRulesInputDTO c);

    @method(HTTPMethod.DELETE) @path(":id")
    ProxyRulesDTO remove(in long _id);

    @method(HTTPMethod.GET) @path("/:id/hostrules")
    HostRuleList getHostRules(in long _id);

    @method(HTTPMethod.POST) @path("/:id/hostrules/:hrid")
    HostRuleList addHostRule(in long _id, in long _hrid);

    @method(HTTPMethod.DELETE) @path("/:id/hostrules/:hrid")
    HostRuleList removeHostRule(in long _id, in long _hrid);
}


struct ProxyRulesList
{
    ProxyRulesDTO[] hostRules;
}


struct ProxyRulesInputDTO
{
    @safe this(in long proxyId, in bool enabled, in string name, in long[] hostRuleIds) pure
    {
        this.proxyId = proxyId;
        this.enabled = enabled;
        this.name = name.dup;
        this.hostRuleIds = hostRuleIds.dup;
    }

    long proxyId;
    bool enabled;
    string name;
    long[] hostRuleIds;
}


struct ProxyRulesDTO
{
    @safe this(in long id, in ProxyDTO proxy, in bool enabled, in string name, in HostRuleDTO[] hostRules) pure
    {
        this.id = id;
        this.proxy = proxy;
        this.enabled = enabled;
        this.name = name.dup;
        this.hostRules = hostRules.dup;
    }

    @safe this(in ProxyRulesDTO other) pure
    {
        this.id = other.id;
        this.proxy = other.proxy;
        this.enabled = other.enabled;
        this.name = other.name.dup;
        this.hostRules = other.hostRules.dup;
    }

    long id;
    ProxyDTO proxy;
    bool enabled;
    string name;
    HostRuleDTO[] hostRules;
}

unittest
{
    const HostRuleDTO[] hostRules = [];
    auto p = ProxyRulesDTO(1, ProxyDTO(), true, "name", hostRules);
    assert( p.id == 1 );
}
