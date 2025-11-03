module web.api.hostrule;

import vibe.web.rest;
import vibe.http.server;

import web.api.category;

interface HostRuleAPI
{
@safe:
    @method(HTTPMethod.GET) @path("/all")
    HostRuleList getAll();

    @method(HTTPMethod.GET) @path(":id")
    HostRuleDTO getById(in long _id);

    @method(HTTPMethod.POST) @path("/create") @bodyParam("c")
    HostRuleDTO create(in HostRuleInputDTO c);

    @method(HTTPMethod.PUT) @path("/:id/update") @bodyParam("c")
    HostRuleDTO update(in long _id, in HostRuleInputDTO c);

    @method(HTTPMethod.DELETE) @path(":id")
    HostRuleDTO remove(in long _id);
}

struct HostRuleList
{
    HostRuleDTO[] hostRules;
}

struct HostRuleInputDTO
{
    @safe this(in string hostTemplate, in bool strict, in long categoryId) pure
    {
        this.hostTemplate = hostTemplate.dup;
        this.strict = strict;
        this.categoryId = categoryId;
    }

    string hostTemplate;
    bool strict;
    long categoryId;
}

struct HostRuleDTO
{
    @safe this(in long id, in string hostTemplate, in bool strict, in CategoryDTO category) pure
    {
        this.id = id;
        this.hostTemplate = hostTemplate.dup;
        this.strict = strict;
        this.category = category;
    }

    @safe this(in HostRuleDTO other) pure
    {
        this.id = other.id;
        this.hostTemplate = other.hostTemplate.dup;
        this.strict = other.strict;
        this.category = other.category;
    }

    long id;
    string hostTemplate;
    bool strict;
    CategoryDTO category;
}
