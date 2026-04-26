module web.api.tool;

import vibe.http.server;
import vibe.web.auth : requiresAuth, anyAuth, auth, Role;
import vibe.web.rest;

import web.auth.common;
public import web.api.condition : ConditionDTO;

@requiresAuth!AuthInfo
interface ToolAPI
{
@safe:
    @auth(Role.writer) @method(HTTPMethod.POST) @path("/quick_add_conditions")
    QuickAddResponseDTO quickAddConditions(@viaBody()  in QuickAddInputDTO c);

    mixin authInterfaceMethod;
}

struct QuickAddInputDTO
{
    string type;
    string[] expressions;
    long categoryId;
    long proxyRuleId;
}

struct ExpressionErrorDTO 
{
    @safe this(in string expression, in string error) pure
    {
        this.expression = expression;
        this.error = error;
    }

    string expression;
    string error;
}

struct QuickAddResponseDTO
{
    ConditionDTO[] conditions;
    ExpressionErrorDTO[] errors;
}
