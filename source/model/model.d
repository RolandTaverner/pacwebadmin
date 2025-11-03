module model.model;

import std.algorithm.iteration : filter;
import std.algorithm.iteration : map;
import std.algorithm : canFind;
import std.array;
import std.exception : enforce;

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
import model.entities.pac;
import model.errors.base : ConstraintError;

class Model
{
    @safe this(Storage storage)
    {
        m_storage = storage;
    }

    // Categories ======================

    @trusted const(Category[]) getCategories()
    {
        return array(categories.getAll().map!(c => makeCategory(c)));
    }

    @trusted const(Category) categoryById(in long id)
    {
        try
        {
            return makeCategory(categories.getByKey(id));
        }
        catch (re.NotFoundError e)
        {
            throw new CategoryNotFound(id);
        }
    }

    @trusted const(Category) createCategory(in CategoryInput ci)
    {
        // TODO: check name uniqueness
        const auto created = categories.create(new dlcategory.CategoryValue(ci.name));
        return makeCategory(created);
    }

    @trusted const(Category) updateCategory(in long id, in CategoryInput ci)
    {
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

    @trusted const(Category) deleteCategory(in long id)
    {
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

    @trusted const(Proxy[]) getProxies()
    {
        return array(proxies.getAll().map!(c => makeProxy(c)));
    }

    @trusted const(Proxy) proxyById(in long id)
    {
        try
        {
            return makeProxy(proxies.getByKey(id));
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyNotFound(id);
        }
    }

    @trusted const(Proxy) createProxy(in ProxyInput pi)
    {
        // TODO: check hostAddress uniqueness
        const auto created = proxies.create(new dlproxy.ProxyValue(pi.hostAddress, pi.description, pi
                .builtIn));
        return makeProxy(created);
    }

    @trusted const(Proxy) updateProxy(in long id, in ProxyInput pi)
    {
        try
        {
            // TODO: check hostAddress uniqueness
            const auto updated = proxies.update(id, new dlproxy.ProxyValue(pi.hostAddress, pi.description, pi
                    .builtIn));
            return makeProxy(updated);
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyNotFound(id);
        }
    }

    @trusted const(Proxy) deleteProxy(long id)
    {
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

    @trusted const(HostRule[]) getHostRules()
    {
        return array(hostRules.getAll().map!(c => makeHostRule(c)));
    }

    @trusted const(HostRule) hostRuleById(in long id)
    {
        try
        {
            return makeHostRule(hostRules.getByKey(id));
        }
        catch (re.NotFoundError e)
        {
            throw new HostRuleNotFound(id);
        }
    }

    @trusted const(HostRule) createHostRule(in HostRuleInput hri)
    {
        enforce!bool(categories.exists(hri.categoryId), new CategoryNotFound(hri.categoryId));

        // TODO: check hostTemplate uniqueness
        const auto created = hostRules.create(new dlhostrule.HostRuleValue(hri.hostTemplate, hri.strict, hri
                .categoryId));
        return makeHostRule(created);
    }

    @trusted const(HostRule) updateHostRule(in long id, in HostRuleInput hri)
    {
        enforce!bool(categories.exists(hri.categoryId), new CategoryNotFound(hri.categoryId));

        try
        {
            // TODO: check hostTemplate uniqueness
            const auto updated = hostRules.update(id, new dlhostrule.HostRuleValue(hri.hostTemplate, hri.strict, hri
                    .categoryId));
            return makeHostRule(updated);
        }
        catch (re.NotFoundError e)
        {
            throw new HostRuleNotFound(id);
        }
    }

    @trusted const(HostRule) deleteHostRule(long id)
    {
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

    @trusted const(ProxyRules[]) getProxyRules()
    {
        return array(proxyRules.getAll().map!(c => makeProxyRules(c)));
    }

    @trusted const(ProxyRules) proxyRulesById(in long id)
    {
        try
        {
            return makeProxyRules(proxyRules.getByKey(id));
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    @trusted const(ProxyRules) createProxyRules(in ProxyRulesInput pri)
    {
        enforce!bool(proxies.exists(pri.proxyId), new ProxyNotFound(pri.proxyId));
        foreach (hrId; pri.hostRuleIds)
        {
            enforce!bool(hostRules.exists(hrId), new HostRuleNotFound(hrId));
        }

        const auto created = proxyRules.create(new dlproxyrules.ProxyRulesValue(pri.proxyId, pri.enabled, pri.name, pri
                .hostRuleIds));
        return makeProxyRules(created);
    }

    @trusted const(ProxyRules) updateProxyRules(in long id, in ProxyRulesInput pri)
    {
        enforce!bool(proxies.exists(pri.proxyId), new ProxyNotFound(pri.proxyId));
        foreach (hrId; pri.hostRuleIds)
        {
            enforce!bool(hostRules.exists(hrId), new HostRuleNotFound(hrId));
        }

        try
        {
            // TODO: check hostRuleIds uniqueness and existance
            const auto updated = proxyRules.update(id, new dlproxyrules.ProxyRulesValue(pri.proxyId, pri.enabled, pri
                    .name, pri.hostRuleIds));
            return makeProxyRules(updated);
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    @trusted const(HostRule[]) proxyRulesAddHostRule(in long id, in long hostRuleId)
    {
        enforce!bool(hostRules.exists(hostRuleId), new HostRuleNotFound(hostRuleId));

        try
        {
            // TODO: check hostRuleIds uniqueness and existance
            const auto pr = proxyRules.getByKey(id);
            const auto hrIds = pr.value().hostRuleIds();
            if (hrIds.canFind(hostRuleId))
            {
                throw new ConstraintError("already exists"); // TODO: add info
            }
            const auto newHrIds = hrIds ~ hostRuleId;
            const auto updated = proxyRules.update(id, new dlproxyrules.ProxyRulesValue(pr.value()
                    .proxyId(), pr.value().enabled(), pr.value().name(), newHrIds));

            return makeProxyRules(updated).hostRules();
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    @trusted const(HostRule[]) proxyRulesRemoveHostRule(in long id, in long hostRuleId)
    {
        try
        {
            // TODO: check hostRuleIds uniqueness and existance
            const auto pr = proxyRules.getByKey(id);
            const auto hrIds = pr.value().hostRuleIds();
            if (!hrIds.canFind(hostRuleId))
            {
                throw new ConstraintError("not exists"); // TODO: add info
            }
            const auto filteredHrIds = array(hrIds.filter!(i => i != hostRuleId));
            const auto updated = proxyRules.update(id, new dlproxyrules.ProxyRulesValue(pr.value()
                    .proxyId(), pr.value().enabled(), pr.value().name(), filteredHrIds));

            return makeProxyRules(updated).hostRules();
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    @trusted const(ProxyRules) deleteProxyRules(long id)
    {
        try
        {
            // TODO: update PAC
            const auto deleted = proxyRules.remove(id);
            return makeProxyRules(deleted);
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRulesNotFound(id);
        }
    }

    // PAC ======================

    @trusted const(PAC[]) getPACs()
    {
        return array(pacs.getAll().map!(c => makePAC(c)));
    }

    @trusted const(PAC) pacById(in long id)
    {
        try
        {
            return makePAC(pacs.getByKey(id));
        }
        catch (re.NotFoundError e)
        {
            throw new PACNotFound(id);
        }
    }

    @trusted const(PAC) createPAC(in PACInput pi)
    {
        foreach (prId; pi.proxyRulesIds)
        {
            enforce!bool(proxyRules.exists(prId), new ProxyRulesNotFound(prId));
        }

        const auto created = pacs.create(new dlpac.PACValue(pi.name, pi.description, pi.proxyRulesIds,
                pi.serve, pi.servePath, pi.saveToFS, pi.saveToFSPath));
        return makePAC(created);
    }

    @trusted const(PAC) updatePAC(in long id, in PACInput pi)
    {
        foreach (prId; pi.proxyRulesIds)
        {
            enforce!bool(proxyRules.exists(prId), new ProxyRulesNotFound(prId));
        }

        try
        {
            const auto updated = pacs.update(id, new dlpac.PACValue(pi.name, pi.description, pi.proxyRulesIds,
                    pi.serve, pi.servePath, pi.saveToFS, pi.saveToFSPath));
            return makePAC(updated);
        }
        catch (re.NotFoundError e)
        {
            throw new PACNotFound(id);
        }
    }

    @trusted const(ProxyRules[]) pacAddProxyRules(in long id, in long proxyRulesId)
    {
        enforce!bool(proxyRules.exists(proxyRulesId), new ProxyRulesNotFound(proxyRulesId));

        try
        {
            // TODO: check hostRuleIds uniqueness and existance
            const auto pac = pacs.getByKey(id);
            const auto prIds = pac.value().proxyRulesIds();
            if (prIds.canFind(proxyRulesId))
            {
                throw new ConstraintError("already exists"); // TODO: add info
            }
            const auto newPrIds = prIds ~ proxyRulesId;
            const auto updated = pacs.update(id, new dlpac.PACValue(pac.value()
                    .name(), pac.value().description(),
                    newPrIds, pac.value()
                    .serve(), pac.value().servePath(), pac.value()
                    .saveToFS(), pac.value().saveToFSPath()));

            return makePAC(updated).proxyRules();
        }
        catch (re.NotFoundError e)
        {
            throw new PACNotFound(id);
        }
    }

    @trusted const(ProxyRules[]) pacRemoveProxyRules(in long id, in long proxyRulesId)
    {
        enforce!bool(proxyRules.exists(proxyRulesId), new ProxyRulesNotFound(proxyRulesId));

        try
        {
            // TODO: check hostRuleIds uniqueness and existance
            const auto pac = pacs.getByKey(id);
            const auto prIds = pac.value().proxyRulesIds();
            if (!prIds.canFind(proxyRulesId))
            {
                throw new ConstraintError("not exists"); // TODO: add info
            }
            const auto filteredPrIds = array(prIds.filter!(i => i != proxyRulesId));
            const auto updated = pacs.update(id, new dlpac.PACValue(pac.value()
                    .name(), pac.value().description(),
                    filteredPrIds, pac.value().serve(), pac.value()
                    .servePath(), pac.value().saveToFS(), pac.value().saveToFSPath()));

            return makePAC(updated).proxyRules();
        }
        catch (re.NotFoundError e)
        {
            throw new PACNotFound(id);
        }
    }

    @trusted const(PAC) deletePAC(long id)
    {
        try
        {
            // TODO: update PAC
            const auto deleted = pacs.remove(id);
            return makePAC(deleted);
        }
        catch (re.NotFoundError e)
        {
            throw new PACNotFound(id);
        }
    }

    //=======================

protected:
    @safe Category makeCategory(in dlcategory.CategoryRepository.DataObjectType dto)
    {
        return new Category(dto.key(), dto.value().name());
    }

    @safe Proxy makeProxy(in dlproxy.ProxyRepository.DataObjectType dto)
    {
        return new Proxy(dto.key(), dto.value().hostAddress(), dto.value()
                .description(), dto.value().builtIn());
    }

    @safe HostRule makeHostRule(in dlhostrule.HostRuleRepository.DataObjectType dto)
    {
        auto id = dto.key();
        auto hostTemplate = dto.value().hostTemplate();
        auto strict = dto.value().strict();

        auto c = categories.getByKey(dto.value().categoryId());
        auto category = makeCategory(c);

        return new HostRule(id, hostTemplate, strict, category);
    }

    @safe ProxyRules makeProxyRules(in dlproxyrules.ProxyRulesRepository.DataObjectType dto)
    {
        auto id = dto.key();

        auto p = proxies.getByKey(dto.value().proxyId());
        auto proxy = makeProxy(p);

        auto enabled = dto.value().enabled();
        auto name = dto.value().name();

        auto hostRules = dto.value().hostRuleIds()
            .map!(id => makeHostRule(hostRules.getByKey(id))).array;

        return new ProxyRules(id, proxy, enabled, name, hostRules);
    }

    @safe PAC makePAC(in dlpac.PACRepository.DataObjectType dto)
    {
        auto id = dto.key();
        auto name = dto.value().name();
        auto description = dto.value().description();
        auto serve = dto.value().serve();
        auto servePath = dto.value().servePath();
        auto saveToFS = dto.value().saveToFS();
        auto saveToFSPath = dto.value().saveToFSPath();

        auto proxyRules = dto.value().proxyRulesIds()
            .map!(id => makeProxyRules(proxyRules.getByKey(id))).array;

        return new PAC(id, name, description, proxyRules, serve, servePath, saveToFS, saveToFSPath);
    }

    @property @safe inout(dlcategory.CategoryRepository) categories() inout pure
    {
        return m_storage.categories();
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
