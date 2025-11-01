module model.model;

import std.algorithm.iteration : map;
import std.array;

import datalayer.storage;
import re = datalayer.repository.errors;

import dlcategory = datalayer.category;
import dlhostrule = datalayer.hostrule;
import dlpac = datalayer.pac;
import dlproxy = datalayer.proxy;
import dlproxyrules = datalayer.proxyrules;

import model.category;
import model.hostrule;
import model.proxy;


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

    @trusted const(Category) createCategory(in Category category) {
        const auto created = categories.create(new dlcategory.CategoryValue(category.name()));
        return makeCategory(created);
    }

    @trusted const(Category) updateCategory(Category category) {
        try
        {
            // TODO: check name uniqueness
            const auto updated = categories.update(category.id(), new dlcategory.CategoryValue(category.name()));
            return makeCategory(updated);
        } 
        catch (re.NotFoundError e) 
        {
            throw new CategoryNotFound(category.id());
        }
    }

    @trusted const(Category) deleteCategory(long id) {
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

    @trusted const(Proxy) createProxy(in Proxy proxy) {
        const auto created = proxies.create(new dlproxy.ProxyValue(proxy.hostAddress(), proxy.description(), proxy.builtIn()));
        return makeProxy(created);
    }

    @trusted const(Proxy) updateProxy(Proxy proxy) {
        try
        {
            // TODO: check name uniqueness
            const auto updated = proxies.update(proxy.id(), new dlproxy.ProxyValue(proxy.hostAddress(), proxy.description(), proxy.builtIn()));
            return makeProxy(updated);
        } 
        catch (re.NotFoundError e) 
        {
            throw new ProxyNotFound(proxy.id());
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

    // =====

    const(HostRule[]) getHostRules() const {
        return array(m_storage.hostRules().getAll().map!(c => makeHostRule(c)));
    }

    const(HostRule) hostRuleById(in long id) const {
        return makeHostRule(m_storage.hostRules().getByKey(id));
    }

protected:
    @safe Category makeCategory(in dlcategory.CategoryRepository.DataObjectType dto) const pure
    {
        return new Category(dto.key(), dto.value().name());
    }

    HostRule makeHostRule(in dlhostrule.HostRuleRepository.DataObjectType dto) const {
        auto id = dto.key();
        auto hostTemplate = dto.value().hostTemplate();
        auto strict = dto.value().strict();
        auto category = makeCategory(m_storage.categories.getByKey(dto.value().categoryId()));

        return new HostRule(id, hostTemplate, strict, category);
    }

    @safe Proxy makeProxy(in dlproxy.ProxyRepository.DataObjectType dto) const pure
    {
        return new Proxy(dto.key(), dto.value().hostAddress(), dto.value().description(), dto.value().builtIn());
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
