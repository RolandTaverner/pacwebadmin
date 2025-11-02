module model.model;

import std.algorithm.iteration : filter;
import std.algorithm.iteration : map;
import std.algorithm : canFind;
import std.array;

import datalayer.storage;
import re = datalayer.repository.errors;

import dlcategory = datalayer.category;
import dlhostrule = datalayer.hostrule;
import dlpac = datalayer.pac;
import dlproxy = datalayer.proxy;
import dlproxyrules = datalayer.proxyrules;

import model.entities.category;
import model.entities.hostrule;
import model.entities.proxy;
import model.entities.proxyrules;
import model.errors.base : ConstraintError;


class Model {
    @safe this(Storage storage)
    {
        m_storage = storage;
    }

    // Categories ======================

    @trusted const(Category[]) getCategories() const {
        return array(categories.getAll().map!(c => makeCategory(c)));
    }

    @trusted const(Category) categoryById(in long id) const {
        try
        {
            return makeCategory(categories.getByKey(id));
        } 
        catch (re.NotFoundError e) 
        {
            throw new CategoryNotFound(id);
        }
    }

    @trusted const(Category) createCategory(in CategoryInput ci) {
        // TODO: check name uniqueness
        const auto created = categories.create(new dlcategory.CategoryValue(ci.name));
        return makeCategory(created);
    }

    @trusted const(Category) updateCategory(in long id, in CategoryInput ci) {
        try
        {
            // TODO: check name uniqueness
            const auto updated = categories.update(id, new dlcategory.CategoryValue(ci.name));
            return makeCategory(updated);
        } 
        catch (re.NotFoundError e) 
        {
            throw new CategoryNotFound(id);
        }
    }

    @trusted const(Category) deleteCategory(in long id) {
        try
        {
            // TODO: update hosts
            const auto deleted = categories.remove(id);
            return makeCategory(deleted);
        } 
        catch (re.NotFoundError e) 
        {
            throw new CategoryNotFound(id);
        }
    }

    // Proxies ======================

    @trusted const(Proxy[]) getProxies() const {
        return array(proxies.getAll().map!(c => makeProxy(c)));
    }

    @trusted const(Proxy) proxyById(in long id) const {
        try
        {
            return makeProxy(proxies.getByKey(id));
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyNotFound(id);
        }
    }

    @trusted const(Proxy) createProxy(in ProxyInput pi) {
        // TODO: check hostAddress uniqueness
        const auto created = proxies.create(new dlproxy.ProxyValue(pi.hostAddress, pi.description, pi.builtIn));
        return makeProxy(created);
    }

    @trusted const(Proxy) updateProxy(in long id, in ProxyInput pi) {
        try
        {
            // TODO: check hostAddress uniqueness
            const auto updated = proxies.update(id, new dlproxy.ProxyValue(pi.hostAddress, pi.description, pi.builtIn));
            return makeProxy(updated);
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyNotFound(id);
        }
    }

    @trusted const(Proxy) deleteProxy(long id) {
        try
        {
            // TODO: update proxy rules
            const auto deleted = proxies.remove(id);
            return makeProxy(deleted);
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyNotFound(id);
        }
    }

    // HostRules ======================

    @trusted const(HostRule[]) getHostRules() const {
        return array(hostRules.getAll().map!(c => makeHostRule(c)));
    }

    @trusted const(HostRule) hostRuleById(in long id) const {
        try
        {
            return makeHostRule(hostRules.getByKey(id));
        } 
        catch (re.NotFoundError e) 
        {
            throw new HostRuleNotFound(id);
        }
    }

    @trusted const(HostRule) createHostRule(in HostRuleInput hri) {
        // TODO: check hostTemplate uniqueness
        const auto created = hostRules.create(new dlhostrule.HostRuleValue(hri.hostTemplate, hri.strict, hri.categoryId));
        return makeHostRule(created);
    }

    @trusted const(HostRule) updateHostRule(in long id, in HostRuleInput hri) {
        try
        {
            // TODO: check hostTemplate uniqueness
            const auto updated = hostRules.update(id, new dlhostrule.HostRuleValue(hri.hostTemplate, hri.strict, hri.categoryId));
            return makeHostRule(updated);
        } 
        catch (re.NotFoundError e) 
        {
            throw new HostRuleNotFound(id);
        }
    }

    @trusted const(HostRule) deleteHostRule(long id) {
        try
        {
            // TODO: update proxy rules
            const auto deleted = hostRules.remove(id);
            return makeHostRule(deleted);
        } 
        catch (re.NotFoundError e) 
        {
            throw new HostRuleNotFound(id);
        }
    }


    // ProxyRules ======================

    @trusted const(ProxyRules[]) getProxyRules() const {
        return array(proxyRules.getAll().map!(c => makeProxyRules(c)));
    }

    @trusted const(ProxyRules) proxyRulesById(in long id) const {
        try
        {
            return makeProxyRules(proxyRules.getByKey(id));
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    @trusted const(ProxyRules) createProxyRules(in ProxyRulesInput pri) {
        // TODO: check hostRuleIds uniqueness and existance
        const auto created = proxyRules.create(new dlproxyrules.ProxyRulesValue(pri.proxyId, pri.enabled, pri.hostRuleIds));
        return makeProxyRules(created);
    }

    @trusted const(ProxyRules) updateProxyRules(in long id, in ProxyRulesInput pri) {
        try
        {
            // TODO: check hostRuleIds uniqueness and existance
            const auto updated = proxyRules.update(id, new dlproxyrules.ProxyRulesValue(pri.proxyId, pri.enabled, pri.hostRuleIds));
            return makeProxyRules(updated);
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    @trusted const(HostRule[]) proxyRulesAddHostRule(in long id, in long hostRuleId) {
        try
        {
            // TODO: check hostRuleIds uniqueness and existance
            const auto pr = proxyRules.getByKey(id);
            const auto hrIds = pr.value().hostRuleIds();
            if (hrIds.canFind(hostRuleId)) {
                throw new ConstraintError("already exists"); // TODO: add info
            }
            const auto newHrIds = hrIds ~ hostRuleId;
            const auto updated = proxyRules.update(id, new dlproxyrules.ProxyRulesValue(pr.value().proxyId(), pr.value().enabled(), newHrIds));

            return makeProxyRules(updated).hostRules();
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    @trusted const(HostRule[]) proxyRulesRemoveHostRule(in long id, in long hostRuleId) {
        try
        {
            // TODO: check hostRuleIds uniqueness and existance
            const auto pr = proxyRules.getByKey(id);
            const auto hrIds = pr.value().hostRuleIds();
            if (!hrIds.canFind(hostRuleId)) {
                throw new ConstraintError("not exists"); // TODO: add info
            }
            const auto filteredHrIds = array(hrIds.filter!(i => i != hostRuleId));
            const auto updated = proxyRules.update(id, new dlproxyrules.ProxyRulesValue(pr.value().proxyId(), pr.value().enabled(), filteredHrIds));

            return makeProxyRules(updated).hostRules();
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    @trusted const(ProxyRules) deleteProxyRules(long id) {
        try
        {
            // TODO: update proxy rules
            const auto deleted = proxyRules.remove(id);
            return makeProxyRules(deleted);
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyRulesNotFound(id);
        }
    }

// ===========


protected:
    @safe Category makeCategory(in dlcategory.CategoryRepository.DataObjectType dto) const pure
    {
        return new Category(dto.key(), dto.value().name());
    }

    @safe Proxy makeProxy(in dlproxy.ProxyRepository.DataObjectType dto) const pure
    {
        return new Proxy(dto.key(), dto.value().hostAddress(), dto.value().description(), dto.value().builtIn());
    }

    @safe HostRule makeHostRule(in dlhostrule.HostRuleRepository.DataObjectType dto) const pure
    {
        auto id = dto.key();
        auto hostTemplate = dto.value().hostTemplate();
        auto strict = dto.value().strict();
        
        auto c = categories.getByKey(dto.value().categoryId());
        auto category = makeCategory(c);

        return new HostRule(id, hostTemplate, strict, category);
    }

    @safe ProxyRules makeProxyRules(in dlproxyrules.ProxyRulesRepository.DataObjectType dto) const pure
    {
        auto id = dto.key();

        auto p =  proxies.getByKey(dto.value().proxyId());
        auto proxy = makeProxy(p);
        
        auto enabled = dto.value().enabled();

        auto hostRules = array(dto.value().hostRuleIds.map!( id => makeHostRule(hostRules.getByKey(id)) ));

        return new ProxyRules(id, proxy, enabled, hostRules);
    }

    @property @safe inout(dlcategory.CategoryRepository) categories() inout pure
    {
        return m_storage.categories;
    }

    @property @safe inout(dlhostrule.HostRuleRepository) hostRules() inout pure
    {
        return m_storage.hostRules();
    }

    @property @safe inout(dlpac.PACRepository) pacs() inout pure
    {
        return m_storage.pacs();
    }

    @property @safe inout(dlproxy.ProxyRepository) proxies() inout pure
    {
        return m_storage.proxies();
    }

    @property @safe inout(dlproxyrules.ProxyRulesRepository) proxyRules() inout pure
    {
        return m_storage.proxyRules();
    }

private:
    Storage m_storage;
}
