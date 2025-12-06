module web.service;

import vibe.vibe;
import vibe.http.common;

import model.model;

import web.api.root;
import web.api.category;
import web.api.proxy;
import web.api.condition;
import web.api.proxyrule;
import web.api.pac;

import web.auth.provider : AuthProvider;

import web.services.category;
import web.services.proxy;
import web.services.condition;
import web.services.proxyrule;
import web.services.pac;

import web.services.common.exceptions;
import web.services.common.todto;

class Service : APIRoot
{
    this(Model model, AuthProvider authProvider)
    {
        m_model = model;

        m_categorySvc = new CategoryService(m_model, authProvider);
        m_proxySvc = new ProxyService(m_model, authProvider);
        m_conditionSvc = new ConditionService(m_model, authProvider);
        m_proxyRuleSvc = new ProxyRuleService(m_model, authProvider);
        m_pacSvc = new PACService(m_model, authProvider);
    }

    override @property CategoryAPI categories()
    {
        return m_categorySvc;
    }

    override @property ProxyAPI proxies()
    {
        return m_proxySvc;
    }

    override @property ConditionAPI conditions()
    {
        return m_conditionSvc;
    }

    override @property ProxyRuleAPI proxyRules()
    {
        return m_proxyRuleSvc;
    }

    override @property PACAPI pacs()
    {
        return m_pacSvc;
    }

private:
    Model m_model;
    CategoryService m_categorySvc;
    ProxyService m_proxySvc;
    ConditionService m_conditionSvc;
    ProxyRuleService m_proxyRuleSvc;
    PACService m_pacSvc;
}
