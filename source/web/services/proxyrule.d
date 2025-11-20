module web.services.proxyrule;

import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;

import model.model;
import model.entities.proxyrule;

import web.api.condition;
import web.api.proxyrule;

import web.services.common.exceptions;
import web.services.common.todto;

class ProxyRuleService : ProxyRuleAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override ProxyRuleList getAll()
    {
        ProxyRuleList response =
        {
            m_model.getProxyRules()
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array
        };

        return response;
    }

    @safe override ProxyRuleDTO create(in ProxyRuleInputDTO prs)
    {
        return remapExceptions!(delegate() {
            const ProxyRuleInput prsi = {
                proxyId: prs.proxyId, enabled: prs.enabled, name: prs.name, conditionIds: prs
                    .conditionIds.dup
            };
            const ProxyRule created = m_model.createProxyRule(prsi);
            return toDTO(created);
        }, ProxyRuleDTO);
    }

    @safe override ProxyRuleDTO update(in long id, in ProxyRuleInputDTO prs)
    {
        return remapExceptions!(delegate() {
            const ProxyRuleInput prsi = {
                proxyId: prs.proxyId, enabled: prs.enabled, name: prs.name, conditionIds: prs
                    .conditionIds.dup};
                const ProxyRule updated = m_model.updateProxyRule(id, prsi);
                return toDTO(updated);
            }, ProxyRuleDTO);
        }

        @safe override ProxyRuleDTO getById(in long id)
        {
            return remapExceptions!(delegate() {
                const ProxyRule got = m_model.proxyRuleById(id);
                return toDTO(got);
            }, ProxyRuleDTO);
        }

        @safe override void remove(in long id)
        {
            return remapExceptions!(delegate() {
                m_model.deleteProxyRule(id);
            }, void);
        }

        @safe override ConditionList getConditions(in long id)
        {
            return remapExceptions!(delegate() {
                ConditionList response = {
                    array(m_model.proxyRuleById(id)
                        .conditions().map!(c => toDTO(c)))
            };
            return response;
        }, ConditionList);
    }

    @safe override ConditionList addCondition(in long id, in long hrid)
    {
        return remapExceptions!(delegate() {
            const auto updated = m_model.proxyRuleAddCondition(id, hrid);
            ConditionList response = {array(updated.map!(c => toDTO(c)))};
            return response;
        }, ConditionList);
    }

    @safe override void removeCondition(in long id, in long hrid)
    {
        return remapExceptions!(delegate() {
            m_model.proxyRuleRemoveCondition(id, hrid);
        }, void);
    }

private:
    Model m_model;
}
