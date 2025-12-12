module web.services.pac;

import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;
import std.typecons : nullable, Nullable;

import vibe.web.auth;
import vibe.web.common : noRoute;

import model.model;
import model.entities.pac;

import web.api.pac;
import web.api.proxyrule;

import web.services.common.auth;
import web.services.common.exceptions;
import web.services.common.todto;

class PACService : PACAPI
{
    this(Model model, AuthProvider authProvider)
    {
        m_model = model;
        m_authProvider = authProvider;
    }

    @safe override PACList getAll()
    {
        PACList response =
        {
            m_model.getPACs()
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array
        };

        return response;
    }

    @safe override PACDTO create(in PACCreateDTO p)
    {
        return remapExceptions!(delegate() {
            long[long] proxyRules;
            foreach (pr; p.proxyRules)
            {
                proxyRules[pr.proxyRuleId] = pr.priority;
            }

            const PACInput pi = {
                p.name,
                p.description,
                proxyRules,
                p.serve,
                p.servePath,
                p.saveToFS,
                p.saveToFSPath,
                p.fallbackProxyId
            };

            const PAC created = m_model.createPAC(pi);
            return toDTO(created);
        }, PACDTO);
    }

    @safe override PACDTO update(in long id, in PACUpdateDTO p)
    {
        return remapExceptions!(delegate() {
            long[long] proxyRulesMap;
            if (p.proxyRules)
            {
                foreach (pr; p.proxyRules.get)
                {
                    proxyRulesMap[pr.proxyRuleId] = pr.priority;
                }
            }

            const PACInput pi = {
                p.name,
                p.description,
                p.proxyRules ? nullable!()(proxyRulesMap) : Nullable!(long[long]).init,
                p.serve,
                p.servePath,
                p.saveToFS,
                p.saveToFSPath,
                p.fallbackProxyId
            };

            const PAC updated = m_model.updatePAC(id, pi);
            return toDTO(updated);
        }, PACDTO);
    }

    @safe override PACDTO getById(in long id)
    {
        return remapExceptions!(delegate() {
            const PAC got = m_model.pacById(id);
            return toDTO(got);
        }, PACDTO);
    }

    @safe override void remove(in long id)
    {
        return remapExceptions!(delegate() {
            m_model.deletePAC(id);
        }, void);
    }

    @safe override ProxyRulePriorityList getProxyRules(in long id)
    {
        return remapExceptions!(delegate() {
            ProxyRulePriorityList response = {
                array(m_model.pacById(id).proxyRules().map!(p => toDTO(p)))
            };
            return response;
        }, ProxyRulePriorityList);
    }

    @safe override ProxyRulePriorityList addProxyRule(in long id, in long prid, long priority)
    {
        return remapExceptions!(delegate() {
            const auto updated = m_model.pacAddProxyRule(id, prid, priority);
            ProxyRulePriorityList response = {array(updated.map!(c => toDTO(c)))};
            return response;
        }, ProxyRulePriorityList);
    }

    @safe override ProxyRulePriorityList setProxyRulePriority(in long id, in long prid, long priority)
    {
        return remapExceptions!(delegate() {
            const auto updated = m_model.pacSetProxyRulePriority(id, prid, priority);
            ProxyRulePriorityList response = {array(updated.map!(c => toDTO(c)))};
            return response;
        }, ProxyRulePriorityList);
    }

    @safe override void removeProxyRule(in long id, in long prid)
    {
        return remapExceptions!(delegate() {
            m_model.pacRemoveProxyRule(id, prid);
        }, void);
    }

    mixin authMethodImpl;

private:
    Model m_model;
}
