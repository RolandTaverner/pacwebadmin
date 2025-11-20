module web.api.proxyrule;

import vibe.web.rest;
import vibe.http.server;

import web.api.condition;
import web.api.proxy;

interface ProxyRuleAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    ProxyRuleList getAll();

    @method(HTTPMethod.GET) @path(":id")
    ProxyRuleDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c")
    ProxyRuleDTO create(in ProxyRuleInputDTO c);

    @method(HTTPMethod.PUT) @path("/:id/update") @bodyParam("c")
    ProxyRuleDTO update(in long _id, in ProxyRuleInputDTO c);

    @method(HTTPMethod.DELETE) @path(":id")
    void remove(in long _id);

    @method(HTTPMethod.GET) @path("/:id/conditions")
    ConditionList getConditions(in long _id);

    @method(HTTPMethod.POST) @path("/:id/conditions/:hrid")
    ConditionList addCondition(in long _id, in long _hrid);

    @method(HTTPMethod.DELETE) @path("/:id/conditions/:hrid")
    void removeCondition(in long _id, in long _hrid);
}

struct ProxyRuleList
{
    ProxyRuleDTO[] proxyRules;
}

struct ProxyRuleInputDTO
{
    @safe this(in long proxyId, in bool enabled, in string name, in long[] conditionIds) pure
    {
        this.proxyId = proxyId;
        this.enabled = enabled;
        this.name = name;
        this.conditionIds = conditionIds.dup;
    }

    long proxyId;
    bool enabled;
    string name;
    long[] conditionIds;
}

struct ProxyRuleDTO
{
    @safe this(in long id, in ProxyDTO proxy, in bool enabled, in string name, in ConditionDTO[] conditions) pure
    {
        this.id = id;
        this.proxy = proxy;
        this.enabled = enabled;
        this.name = name;
        this.conditions = conditions.dup;
    }

    @safe this(in ProxyRuleDTO other) pure
    {
        this.id = other.id;
        this.proxy = other.proxy;
        this.enabled = other.enabled;
        this.name = other.name;
        this.conditions = other.conditions.dup;
    }

    long id;
    ProxyDTO proxy;
    bool enabled;
    string name;
    ConditionDTO[] conditions;
}

unittest
{
    const ConditionDTO[] conditions = [];
    const ProxyRuleDTO p1 = ProxyRuleDTO(1, ProxyDTO(), true, "name", conditions);
    assert(p1.id == 1);

    auto p2 = ProxyRuleDTO(p1);
    assert(p2.id == p1.id);
}
