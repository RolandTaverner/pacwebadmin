module model.model;

import std.algorithm.iteration : filter, map;
import std.algorithm.searching : canFind;
import std.array;
import std.exception : enforce;
import std.string;

import datalayer.storage;
import re = datalayer.repository.errors;

import dlcategory = datalayer.entities.category;
import dlcondition = datalayer.entities.condition;
import dlpac = datalayer.entities.pac;
import dlproxy = datalayer.entities.proxy;
import dlproxyrule = datalayer.entities.proxyrule;

import model.entities.category;
import model.entities.condition;
import model.entities.proxy;
import model.entities.proxyrule;
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

    @trusted const(Category) createCategory(in CategoryInput i)
    {
        i.validate();

        // auto pred = (in dlcategory.Category c) {
        //     return canFind(c.value().name(), f.name);
        // };

        // categories.count()
        // TODO: check name uniqueness

        const auto created = categories.create(new dlcategory.CategoryValue(i.name.strip));
        return makeCategory(created);
    }

    @trusted const(Category) updateCategory(in long id, in CategoryInput i)
    {
        i.validate();
        try
        {
            // TODO: check name uniqueness
            const auto updated = categories.update(id, new dlcategory.CategoryValue(i.name.strip));
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

    @trusted const(Category[]) filterCategories(in CategoryFilter f)
    {
        auto pred = (in dlcategory.Category c) {
            return canFind(c.value().name(), f.name);
        };

        auto filtered = categories.filterBy(pred);

        return filtered.map!(c => makeCategory(c)).array;
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

    @trusted const(Proxy) createProxy(in ProxyInput i)
    {
        i.validate();

        // TODO: check address uniqueness
        const auto created = proxies.create(
            new dlproxy.ProxyValue(i.type.strip, i.address.strip, i.description));
        return makeProxy(created);
    }

    @trusted const(Proxy) updateProxy(in long id, in ProxyInput i)
    {
        i.validate();

        try
        {
            // TODO: check address uniqueness
            const auto updated = proxies.update(id,
                new dlproxy.ProxyValue(i.type.strip, i.address.strip, i.description));
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

    @trusted const(Proxy[]) filterProxies(in ProxyFilter f)
    {
        auto pred = (in dlproxy.Proxy p) {
            return (f.address.length == 0 || canFind(p.value().address(), f.address))
                && (f.type.length == 0 || canFind(p.value().type(), f.type));
        };

        auto filtered = proxies.filterBy(pred);

        return filtered.map!(p => makeProxy(p)).array;
    }

    // Conditions ======================

    @trusted const(Condition[]) getConditions()
    {
        return array(conditions.getAll().map!(c => makeCondition(c)));
    }

    @trusted const(Condition) conditionById(in long id)
    {
        try
        {
            return makeCondition(conditions.getByKey(id));
        }
        catch (re.NotFoundError e)
        {
            throw new ConditionNotFound(id);
        }
    }

    @trusted const(Condition) createCondition(in ConditionInput i)
    {
        i.validate();
        enforce!bool(categories.exists(i.categoryId), new CategoryNotFound(i.categoryId));

        // TODO: check hostTemplate uniqueness
        const auto created = conditions.create(
            new dlcondition.ConditionValue(i.type.strip, i.expression.strip, i.categoryId));
        return makeCondition(created);
    }

    @trusted const(Condition) updateCondition(in long id, in ConditionInput i)
    {
        i.validate();
        enforce!bool(categories.exists(i.categoryId), new CategoryNotFound(i.categoryId));

        try
        {
            // TODO: check hostTemplate uniqueness
            const auto updated = conditions.update(id,
                new dlcondition.ConditionValue(i.type.strip, i.expression.strip, i.categoryId));
            return makeCondition(updated);
        }
        catch (re.NotFoundError e)
        {
            throw new ConditionNotFound(id);
        }
    }

    @trusted const(Condition) deleteCondition(long id)
    {
        try
        {
            // TODO: update proxy rules
            const auto deleted = conditions.remove(id);
            return makeCondition(deleted);
        }
        catch (re.NotFoundError e)
        {
            throw new ConditionNotFound(id);
        }
    }

    // ProxyRules ======================

    @trusted const(ProxyRule[]) getProxyRules()
    {
        return array(proxyRules.getAll().map!(c => makeProxyRule(c)));
    }

    @trusted const(ProxyRule) proxyRuleById(in long id)
    {
        try
        {
            return makeProxyRule(proxyRules.getByKey(id));
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRuleNotFound(id);
        }
    }

    @trusted const(ProxyRule) createProxyRule(in ProxyRuleInput i)
    {
        i.validate();
        enforce!bool(proxies.exists(i.proxyId), new ProxyNotFound(i.proxyId));
        foreach (hrId; i.conditionIds)
        {
            enforce!bool(conditions.exists(hrId), new ConditionNotFound(hrId));
        }

        const auto created = proxyRules.create(
            new dlproxyrule.ProxyRuleValue(i.proxyId,
                i.enabled,
                i.name.strip, i.conditionIds));
        return makeProxyRule(created);
    }

    @trusted const(ProxyRule) updateProxyRule(in long id, in ProxyRuleInput i)
    {
        i.validate();
        enforce!bool(proxies.exists(i.proxyId), new ProxyNotFound(i.proxyId));
        foreach (hrId; i.conditionIds)
        {
            enforce!bool(conditions.exists(hrId), new ConditionNotFound(hrId));
        }

        try
        {
            // TODO: check conditionIds uniqueness and existance
            const auto updated = proxyRules.update(id,
                new dlproxyrule.ProxyRuleValue(i.proxyId,
                    i.enabled,
                    i.name.strip,
                    i.conditionIds));
            return makeProxyRule(updated);
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRuleNotFound(id);
        }
    }

    @trusted const(Condition[]) proxyRuleAddCondition(in long id, in long conditionId)
    {
        enforce!bool(conditions.exists(conditionId), new ConditionNotFound(conditionId));

        try
        {
            // TODO: check conditionIds uniqueness and existance
            const auto pr = proxyRules.getByKey(id);
            const auto hrIds = pr.value().conditionIds();
            if (hrIds.canFind(conditionId))
            {
                throw new ConstraintError("already exists"); // TODO: add info
            }
            const auto newHrIds = hrIds ~ conditionId;
            const auto updated = proxyRules.update(id, new dlproxyrule.ProxyRuleValue(pr.value()
                    .proxyId(), pr.value().enabled(), pr.value().name(), newHrIds));

            return makeProxyRule(updated).conditions();
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRuleNotFound(id);
        }
    }

    @trusted const(Condition[]) proxyRuleRemoveCondition(in long id, in long conditionId)
    {
        try
        {
            // TODO: check conditionIds uniqueness and existance
            const auto pr = proxyRules.getByKey(id);
            const auto hrIds = pr.value().conditionIds();
            if (!hrIds.canFind(conditionId))
            {
                throw new ConstraintError("not exists"); // TODO: add info
            }
            const auto filteredHrIds = array(hrIds.filter!(i => i != conditionId));
            const auto updated = proxyRules.update(id, new dlproxyrule.ProxyRuleValue(pr.value()
                    .proxyId(), pr.value().enabled(), pr.value().name(), filteredHrIds));

            return makeProxyRule(updated).conditions();
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRuleNotFound(id);
        }
    }

    @trusted const(ProxyRule) deleteProxyRule(long id)
    {
        try
        {
            // TODO: update PAC
            const auto deleted = proxyRules.remove(id);
            return makeProxyRule(deleted);
        }
        catch (re.NotFoundError e)
        {
            throw new ProxyRuleNotFound(id);
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

    @trusted const(PAC) createPAC(in PACInput i)
    {
        i.validate();
        foreach (prId; i.proxyRuleIds)
        {
            enforce!bool(proxyRules.exists(prId), new ProxyRuleNotFound(prId));
        }

        const auto created = pacs.create(
            new dlpac.PACValue(i.name.strip,
                i.description,
                i.proxyRuleIds,
                i.serve,
                i.servePath.strip,
                i.saveToFS,
                i.saveToFSPath.strip));
        return makePAC(created);
    }

    @trusted const(PAC) updatePAC(in long id, in PACInput i)
    {
        i.validate();
        foreach (prId; i.proxyRuleIds)
        {
            enforce!bool(proxyRules.exists(prId), new ProxyRuleNotFound(prId));
        }

        try
        {
            const auto updated = pacs.update(id,
                new dlpac.PACValue(i.name.strip,
                    i.description,
                    i.proxyRuleIds,
                    i.serve,
                    i.servePath.strip,
                    i.saveToFS,
                    i.saveToFSPath.strip));
            return makePAC(updated);
        }
        catch (re.NotFoundError e)
        {
            throw new PACNotFound(id);
        }
    }

    @trusted const(ProxyRule[]) pacAddProxyRule(in long id, in long proxyRuleId)
    {
        enforce!bool(proxyRules.exists(proxyRuleId), new ProxyRuleNotFound(proxyRuleId));

        try
        {
            // TODO: check conditionIds uniqueness and existance
            const auto pac = pacs.getByKey(id);
            const auto prIds = pac.value().proxyRuleIds();
            if (prIds.canFind(proxyRuleId))
            {
                throw new ConstraintError("already exists"); // TODO: add info
            }
            const auto newPrIds = prIds ~ proxyRuleId;
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

    @trusted const(ProxyRule[]) pacRemoveProxyRule(in long id, in long proxyRuleId)
    {
        enforce!bool(proxyRules.exists(proxyRuleId), new ProxyRuleNotFound(proxyRuleId));

        try
        {
            // TODO: check conditionIds uniqueness and existance
            const auto pac = pacs.getByKey(id);
            const auto prIds = pac.value().proxyRuleIds();
            if (!prIds.canFind(proxyRuleId))
            {
                throw new ConstraintError("not exists"); // TODO: add info
            }
            const auto filteredPrIds = array(prIds.filter!(i => i != proxyRuleId));
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
        return new Proxy(dto.key(),
            dto.value().type(),
            dto.value().address(),
            dto.value().description());
    }

    @safe Condition makeCondition(in dlcondition.ConditionRepository.DataObjectType dto)
    {
        auto id = dto.key();
        auto type = dto.value().type();
        auto expression = dto.value().expression();

        auto c = categories.getByKey(dto.value().categoryId());
        auto category = makeCategory(c);

        return new Condition(id, type, expression, category);
    }

    @safe ProxyRule makeProxyRule(in dlproxyrule.ProxyRuleRepository.DataObjectType dto)
    {
        auto id = dto.key();

        auto p = proxies.getByKey(dto.value().proxyId());
        auto proxy = makeProxy(p);

        auto enabled = dto.value().enabled();
        auto name = dto.value().name();

        auto conditions = dto.value().conditionIds()
            .map!(id => makeCondition(conditions.getByKey(id))).array;

        return new ProxyRule(id, proxy, enabled, name, conditions);
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

        auto proxyRules = dto.value().proxyRuleIds()
            .map!(id => makeProxyRule(proxyRules.getByKey(id))).array;

        return new PAC(id, name, description, proxyRules, serve, servePath, saveToFS, saveToFSPath);
    }

    @property @safe inout(dlcategory.CategoryRepository) categories() inout pure
    {
        return m_storage.categories();
    }

    @property @safe inout(dlcondition.ConditionRepository) conditions() inout pure
    {
        return m_storage.conditions();
    }

    @property @safe inout(dlpac.PACRepository) pacs() inout pure
    {
        return m_storage.pacs();
    }

    @property @safe inout(dlproxy.ProxyRepository) proxies() inout pure
    {
        return m_storage.proxies();
    }

    @property @safe inout(dlproxyrule.ProxyRuleRepository) proxyRules() inout pure
    {
        return m_storage.proxyRules();
    }

private:
    Storage m_storage;
}
