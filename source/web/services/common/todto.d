module web.services.common.todto;

import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;
import std.typecons : Nullable;

import model.entities.category;
import model.entities.proxy;
import model.entities.condition;
import model.entities.proxyrule;
import model.entities.pac;

import web.api.category;
import web.api.proxy;
import web.api.condition;
import web.api.proxyrule;
import web.api.pac;

@safe CategoryDTO toDTO(in Category c) pure
{
    return CategoryDTO(c.id(), c.name());
}

@safe ProxyDTO toDTO(in Proxy p) pure
{
    return ProxyDTO(p.id(), p.type(), p.address(), p.description());
}

@safe ConditionDTO toDTO(in Condition c) pure
{
    return ConditionDTO(c.id(),
        c.type(),
        c.expression(),
        toDTO(c.category()));
}

@safe ProxyRuleDTO toDTO(in ProxyRule prs) pure
{
    const auto conditions = prs.conditions()
        .map!(c => toDTO(c))
        .array
        .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
        .array;

    return ProxyRuleDTO(prs.id(), toDTO(prs.proxy()), prs.enabled(), prs.name(), conditions);
}

@safe ProxyRulePriorityDTO toDTO(in ProxyRulePriority prp) pure
{
    return ProxyRulePriorityDTO(toDTO(prp.proxyRule()), prp.priority());
}

@safe PACDTO toDTO(in PAC p, bool list = false) pure
{
    if (list)
    {
        return PACDTO(p.id(),
            p.name(),
            p.description(),
            Nullable!(ProxyRulePriorityDTO[])(),
            p.serve(),
            p.servePath(),
            p.saveToFS(),
            p.saveToFSPath(),
            toDTO(p.fallbackProxy()));
    }

    auto proxyRules = p.proxyRules()
        .map!(pr => toDTO(pr))
        .array
        .sort!((a, b) => a.priority < b.priority, SwapStrategy.stable)
        .array;

    Nullable!(ProxyRulePriorityDTO[]) prs = proxyRules;
    return PACDTO(p.id(),
        p.name(),
        p.description(),
        prs,
        p.serve(),
        p.servePath(),
        p.saveToFS(),
        p.saveToFSPath(),
        toDTO(p.fallbackProxy()));
}
