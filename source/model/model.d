module model.model;

import core.sync.rwmutex;
import std.algorithm.iteration : filter, map;
import std.algorithm.searching : canFind;
import std.array;
import std.datetime.systime : Clock;
import std.datetime.timezone : UTC;
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
        m_mutex = new ReadWriteMutex();
    }

    // Categories ======================

    @trusted const(Category[]) getCategories()
    {
        synchronized (m_mutex.reader)
        {
            return array(categories.getAll().map!(c => makeCategory(c)));
        }
    }

    @trusted const(Category) categoryById(in long id)
    {
        synchronized (m_mutex.reader)
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
    }

    @trusted const(Category) createCategory(in CategoryInput i)
    {
        i.validate();

        synchronized (m_mutex.writer)
        {
            validateCategoryModify(-1, i, false);

            const auto created = categories.create(new dlcategory.CategoryValue(i.name.strip));
            return makeCategory(created);
        }
    }

    @trusted const(Category) updateCategory(in long id, in CategoryInput i)
    {
        i.validate();

        synchronized (m_mutex.writer)
        {
            validateCategoryModify(id, i, true);
            try
            {
                const auto updated = categories.update(id,
                    new dlcategory.CategoryValue(i.name.strip));
                return makeCategory(updated);
            }
            catch (re.NotFoundError e)
            {
                throw new CategoryNotFound(id);
            }
        }
    }

    @trusted const(Category) deleteCategory(in long id)
    {
        synchronized (m_mutex.writer)
        {
            validateCategoryDelete(id);
            try
            {
                const auto deleted = categories.remove(id);
                return makeCategory(deleted);
            }
            catch (re.NotFoundError e)
            {
                throw new CategoryNotFound(id);
            }
        }
    }

    @trusted const(Category[]) filterCategories(in CategoryFilter f)
    {
        synchronized (m_mutex.reader)
        {
            auto pred = (in dlcategory.Category c) {
                return canFind(c.value().name(), f.name);
            };

            auto filtered = categories.filterBy(pred);

            return filtered.map!(c => makeCategory(c)).array;
        }
    }

    // Proxies ======================

    @trusted const(Proxy[]) getProxies()
    {
        synchronized (m_mutex.reader)
        {
            return array(proxies.getAll().map!(c => makeProxy(c)));
        }
    }

    @trusted const(Proxy) proxyById(in long id)
    {
        synchronized (m_mutex.reader)
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
    }

    @trusted const(Proxy) createProxy(in ProxyInput i)
    {
        i.validate(false);

        synchronized (m_mutex.writer)
        {
            validateProxyModify(-1, i, false);

            const auto created = proxies.create(
                new dlproxy.ProxyValue(i.type.strip, i.address.strip, i.description));
            return makeProxy(created);
        }
    }

    @trusted const(Proxy) updateProxy(in long id, in ProxyInput i)
    {
        i.validate(true);

        synchronized (m_mutex.writer)
        {
            validateProxyModify(id, i, true);
            try
            {
                auto old = proxies.getByKey(id).value();
                auto newType = valueOrDefault(i.type, old.type());
                auto newAddress = valueOrDefault(i.address, old.address());
                auto newDescription = valueOrDefault(i.description, old.description());

                if (newType == ProxyType.DIRECT)
                {
                    newAddress = "";
                }

                const auto updated = proxies.update(id,
                    new dlproxy.ProxyValue(newType, newAddress, newDescription));
                return makeProxy(updated);
            }
            catch (re.NotFoundError e)
            {
                throw new ProxyNotFound(id);
            }
        }
    }

    @trusted const(Proxy) deleteProxy(long id)
    {
        synchronized (m_mutex.writer)
        {
            validateProxyDelete(id);
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
    }

    @trusted const(Proxy[]) filterProxies(in ProxyFilter f)
    {
        f.validate();

        synchronized (m_mutex.reader)
        {
            auto pred = (in dlproxy.Proxy p) {
                return (f.address.length == 0 || canFind(p.value().address(), f.address))
                    && (f.type.length == 0 || canFind(p.value().type(), f.type));
            };

            auto filtered = proxies.filterBy(pred);

            return filtered.map!(p => makeProxy(p)).array;
        }
    }

    // Conditions ======================

    @trusted const(Condition[]) getConditions()
    {
        synchronized (m_mutex.reader)
        {
            return array(conditions.getAll().map!(c => makeCondition(c)));
        }
    }

    @trusted const(Condition) conditionById(in long id)
    {
        synchronized (m_mutex.reader)
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
    }

    @trusted const(Condition) createCondition(in ConditionInput i)
    {
        i.validate(false);

        synchronized (m_mutex.writer)
        {
            validateConditionModify(-1, i, false);

            const auto created = conditions.create(
                new dlcondition.ConditionValue(i.type.strip, i.expression.strip, i.categoryId));
            return makeCondition(created);
        }
    }

    @trusted const(Condition) updateCondition(in long id, in ConditionInput i)
    {
        i.validate(true);

        synchronized (m_mutex.writer)
        {
            validateConditionModify(id, i, true);
            try
            {
                auto old = conditions.getByKey(id).value();
                auto newType = valueOrDefault(i.type, old.type());
                auto newExpression = valueOrDefault(i.expression, old.expression());
                auto newCategoryId = valueOrDefault(i.categoryId, old.categoryId());

                const auto updated = conditions.update(id,
                    new dlcondition.ConditionValue(newType, newExpression, newCategoryId));
                return makeCondition(updated);
            }
            catch (re.NotFoundError e)
            {
                throw new ConditionNotFound(id);
            }
        }
    }

    @trusted const(Condition) deleteCondition(long id)
    {
        synchronized (m_mutex.writer)
        {
            validateConditionDelete(id);
            try
            {
                const auto deleted = conditions.remove(id);
                return makeCondition(deleted);
            }
            catch (re.NotFoundError e)
            {
                throw new ConditionNotFound(id);
            }
        }
    }

    // ProxyRules ======================

    @trusted const(ProxyRule[]) getProxyRules()
    {
        synchronized (m_mutex.reader)
        {
            return array(proxyRules.getAll().map!(c => makeProxyRule(c)));
        }
    }

    @trusted const(ProxyRule) proxyRuleById(in long id)
    {
        synchronized (m_mutex.reader)
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
    }

    @trusted const(ProxyRule) createProxyRule(in ProxyRuleInput i)
    {
        i.validate(false);

        synchronized (m_mutex.writer)
        {
            validateProxyRuleModify(-1, i, false);

            const auto created = proxyRules.create(
                new dlproxyrule.ProxyRuleValue(i.proxyId.get,
                    i.enabled.get,
                    i.name.strip,
                    i.conditionIds));
            return makeProxyRule(created);
        }
    }

    @trusted const(ProxyRule) updateProxyRule(in long id, in ProxyRuleInput i)
    {
        i.validate(true);
        synchronized (m_mutex.writer)
        {
            validateProxyRuleModify(id, i, true);
            try
            {
                auto old = proxyRules.getByKey(id).value();
                auto newProxyId = i.proxyId ? i.proxyId.get : old.proxyId();
                auto newEnabled = i.enabled ? i.enabled.get : old.enabled();
                auto newName = valueOrDefault(i.name, old.name());
                auto newConditionIds = i.conditionIds.length != 0 ? i.conditionIds : old.conditionIds();

                const auto updated = proxyRules.update(id,
                    new dlproxyrule.ProxyRuleValue(newProxyId,
                        newEnabled,
                        newName,
                        newConditionIds));
                return makeProxyRule(updated);
            }
            catch (re.NotFoundError e)
            {
                throw new ProxyRuleNotFound(id);
            }
        }
    }

    @trusted const(Condition[]) proxyRuleAddCondition(in long id, in long conditionId)
    {
        enforce!bool(conditions.exists(conditionId), new ConditionNotFound(conditionId));

        synchronized (m_mutex.writer)
        {
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
    }

    @trusted const(Condition[]) proxyRuleRemoveCondition(in long id, in long conditionId)
    {
        synchronized (m_mutex.writer)
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
    }

    @trusted const(ProxyRule) deleteProxyRule(long id)
    {
        synchronized (m_mutex.writer)
        {
            validateProxyRuleDelete(id);
            try
            {
                const auto deleted = proxyRules.remove(id);
                return makeProxyRule(deleted);
            }
            catch (re.NotFoundError e)
            {
                throw new ProxyRuleNotFound(id);
            }
        }
    }

    // PAC ======================

    @trusted const(PAC[]) getPACs()
    {
        synchronized (m_mutex.reader)
        {
            return array(pacs.getAll().map!(c => makePAC(c)));
        }
    }

    @trusted const(PAC) pacById(in long id)
    {
        synchronized (m_mutex.reader)
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
    }

    @trusted const(PAC) pacByServePath(in string servePath)
    {
        synchronized (m_mutex.reader)
        {
            auto pred = (in dlpac.PAC p) {
                return p.value().servePath() == servePath;
            };
            auto found = pacs.filterBy(pred);
            if (found.length == 0)
            {
                throw new ConstraintError("PAC with specified servePath not found");
            }
            else if (found.length > 1)
            {
                // Should not happen
                // TODO: throw exception indicating internal error, model is broken
                throw new ConstraintError("multiple PACs with specified servePath found");
            }
            return makePAC(found[0]);
        }
    }

    @trusted const(PAC) createPAC(in PACInput i)
    {
        i.validate(false);

        synchronized (m_mutex.writer)
        {
            validatePACModify(-1, i, false);

            const auto created = pacs.create(
                new dlpac.PACValue(i.name.get().strip(),
                    i.description.get().strip(),
                    i.proxyRules.byKeyValue.map!(e => dlpac.ProxyRulePriority(e.key, e.value)).array,
                    i.serve.get(),
                    i.servePath.get().strip(),
                    i.saveToFS.get(),
                    i.saveToFSPath.get().strip(),
                    i.fallbackProxyId.get(),
                    Clock.currTime(UTC())));
            return makePAC(created);
        }
    }

    @trusted const(PAC) updatePAC(in long id, in PACInput i)
    {
        i.validate(true);

        synchronized (m_mutex.writer)
        {
            validatePACModify(id, i, true);
            try
            {
                auto old = pacs.getByKey(id).value();

                auto newName = i.name ? i.name.get().strip() : old.name();
                auto newDescription = i.description ? i.description.get().strip() : old.description();
                auto newProxyRules = i.proxyRules.length != 0 ? i.proxyRules.byKeyValue.map!(e => dlpac.ProxyRulePriority(e.key, e.value)).array : old.proxyRules();
                auto newServe = i.serve ? i.serve.get : old.serve();
                auto newServePath = i.servePath ? i.servePath.get().strip() : old.servePath();
                auto newSaveToFS = i.saveToFS ? i.saveToFS.get : old.saveToFS();
                auto newSaveToFSPath = i.saveToFSPath ? i.saveToFSPath.get().strip() : old.saveToFSPath();
                auto newFallbackProxyId = i.fallbackProxyId ? i.fallbackProxyId.get : old.fallbackProxyId();

                const auto updated = pacs.update(id,
                    new dlpac.PACValue(newName,
                        newDescription,
                        newProxyRules,
                        newServe,
                        newServePath,
                        newSaveToFS,
                        newSaveToFSPath,
                        newFallbackProxyId,
                        Clock.currTime(UTC())));
                return makePAC(updated);
            }
            catch (re.NotFoundError e)
            {
                throw new PACNotFound(id);
            }
        }
    }

    @trusted const(ProxyRulePriority[]) pacAddProxyRule(in long id, in long proxyRuleId, in long priority)
    {
        synchronized (m_mutex.writer)
        {
            enforce!bool(proxyRules.exists(proxyRuleId), new ProxyRuleNotFound(proxyRuleId));

            try
            {
                const auto pac = pacs.getByKey(id);
                const auto prIds = pac.value().proxyRules().map!(pr => pr.proxyRuleId).array;
                if (prIds.canFind(proxyRuleId))
                {
                    throw new ConstraintError("already exists");
                }

                dlpac.ProxyRulePriority[] updatedPrs = pac.value().proxyRules().dup;
                updatedPrs ~= dlpac.ProxyRulePriority(proxyRuleId, priority);

                auto updatedValue = new dlpac.PACValue(pac.value()
                        .name(),
                        pac.value().description(),
                        updatedPrs,
                        pac.value().serve(),
                        pac.value().servePath(),
                        pac.value().saveToFS(),
                        pac.value().saveToFSPath(),
                        pac.value().fallbackProxyId(),
                        Clock.currTime(UTC()));
                const auto updated = pacs.update(id, updatedValue);

                return makePAC(updated).proxyRules();
            }
            catch (re.NotFoundError e)
            {
                throw new PACNotFound(id);
            }
        }
    }

    @trusted const(ProxyRulePriority[]) pacSetProxyRulePriority(in long id, in long proxyRuleId, in long priority)
    {
        synchronized (m_mutex.writer)
        {
            enforce!bool(proxyRules.exists(proxyRuleId), new ProxyRuleNotFound(proxyRuleId));

            try
            {
                const auto pac = pacs.getByKey(id);
                const auto prIds = pac.value().proxyRules().map!(pr => pr.proxyRuleId).array;
                if (!prIds.canFind(proxyRuleId))
                {
                    throw new ConstraintError("not found");
                }

                auto filteredPrs = pac.value().proxyRules()
                    .filter!(pr => pr.proxyRuleId != proxyRuleId).array;
                filteredPrs ~= dlpac.ProxyRulePriority(proxyRuleId, priority);

                auto updatedValue = new dlpac.PACValue(pac.value().name(),
                        pac.value().description(),
                        filteredPrs,
                        pac.value().serve(),
                        pac.value().servePath(),
                        pac.value().saveToFS(),
                        pac.value().saveToFSPath(),
                        pac.value().fallbackProxyId(),
                        Clock.currTime(UTC()));
                const auto updated = pacs.update(id, updatedValue);

                return makePAC(updated).proxyRules();
            }
            catch (re.NotFoundError e)
            {
                throw new PACNotFound(id);
            }
        }
    }

    @trusted const(ProxyRulePriority[]) pacRemoveProxyRule(in long id, in long proxyRuleId)
    {
        synchronized (m_mutex.writer)
        {
            enforce!bool(proxyRules.exists(proxyRuleId), new ProxyRuleNotFound(proxyRuleId));

            try
            {
                const auto pac = pacs.getByKey(id);
                const auto prIds = pac.value().proxyRules().map!(pr => pr.proxyRuleId).array;
                if (!prIds.canFind(proxyRuleId))
                {
                    throw new ConstraintError("not exists");
                }
                const auto filteredPds = pac.value().proxyRules()
                    .filter!(pr => pr.proxyRuleId != proxyRuleId).array;

                auto updatedValue = new dlpac.PACValue(pac.value()
                        .name(),
                        pac.value().description(),
                        filteredPds,
                        pac.value().serve(),
                        pac.value().servePath(),
                        pac.value().saveToFS(),
                        pac.value().saveToFSPath(),
                        pac.value().fallbackProxyId(),
                        Clock.currTime(UTC()));
                const auto updated = pacs.update(id, updatedValue);

                return makePAC(updated).proxyRules();
            }
            catch (re.NotFoundError e)
            {
                throw new PACNotFound(id);
            }
        }
    }

    @trusted const(PAC) deletePAC(long id)
    {
        synchronized (m_mutex.writer)
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
    }

    //=======================

protected:
    void validateCategoryModify(in long id, in CategoryInput i, in bool update)
    {
        auto pred = (in dlcategory.Category c) {
            return (!update || c.key() != id) && c.value().name() == i.name.strip;
        };

        enforce!bool(categories.count(pred) == 0, new ConstraintError("already exists"));
    }

    void validateCategoryDelete(in long id)
    {
        auto pred = (in dlcondition.Condition c) {
            return c.value().categoryId() == id;
        };

        enforce!bool(conditions.count(pred) == 0, new ConstraintError(
                "there are conditions referenced this category"));
    }

    @safe Category makeCategory(in dlcategory.Category dto)
    {
        return new Category(dto.key(), dto.value().name());
    }

    void validateProxyModify(in long id, in ProxyInput i, in bool update)
    {
        auto pred = (in dlproxy.Proxy p) {
            return (!update || p.key() != id) && p.value().type() == i.type.strip && p.value().address() == i.address.strip;
        };

        enforce!bool(proxies.count(pred) == 0, new ConstraintError("already exists"));

        if (update)
        {
            auto old = proxies.getByKey(id).value();
            auto newType = valueOrDefault(i.type, old.type());
            auto newAddress = valueOrDefault(i.address, old.address());

            if (newType != ProxyType.DIRECT)
            {
                enforce!bool(newAddress.strip().length != 0, new ConstraintError("address can't be empty"));
            }
        }
    }

    void validateProxyDelete(in long id)
    {
        auto pred = (in dlproxyrule.ProxyRule p) {
            return p.value().proxyId() == id;
        };

        enforce!bool(proxyRules.count(pred) == 0, new ConstraintError(
                "there are proxy rules referenced this proxy"));
    }

    @safe Proxy makeProxy(in dlproxy.Proxy dto)
    {
        return new Proxy(dto.key(),
            dto.value().type(),
            dto.value().address(),
            dto.value().description());
    }

    void validateConditionModify(in long id, in ConditionInput i, in bool update)
    {
        enforce!bool(categories.exists(i.categoryId), new ConstraintError("category not exists"));

        auto pred = (in dlcondition.Condition c) {
            return (!update || c.key() != id) && (c.value().type() == i.type.strip() && c.value().expression() == i.expression.strip());
        };

        enforce!bool(conditions.count(pred) == 0, new ConstraintError("already exists"));
    }

    void validateConditionDelete(in long id)
    {
        auto pred = (in dlproxyrule.ProxyRule p) {
            return p.value().conditionIds().canFind(id);
        };

        enforce!bool(proxyRules.count(pred) == 0,
            new ConstraintError("there are proxy rules referenced this condition"));
    }

    @safe Condition makeCondition(in dlcondition.Condition dto)
    {
        auto id = dto.key();
        auto type = dto.value().type();
        auto expression = dto.value().expression();

        auto c = categories.getByKey(dto.value().categoryId());
        auto category = makeCategory(c);

        return new Condition(id, type, expression, category);
    }

    void validateProxyRuleModify(in long id, in ProxyRuleInput i, in bool update)
    {
        auto pred = (in dlproxyrule.ProxyRule p) {
            return (!update || p.key() != id) && p.value().name().strip == i.name.strip;
        };
        enforce!bool(proxyRules.count(pred) == 0, new ConstraintError("already exists"));

        if (update && !i.proxyId.isNull)
        {
            enforce!bool(proxies.exists(i.proxyId.get), new ConstraintError("proxy not exists"));
        }

        foreach (conditionId; i.conditionIds)
        {
            enforce!bool(conditions.exists(conditionId), new ConstraintError("condition not exists"));
        }
    }

    void validateProxyRuleDelete(in long id)
    {
        auto pred = (in dlpac.PAC p) {
            return p.value().proxyRules().canFind!(pr => pr.proxyRuleId == id);
        };

        enforce!bool(pacs.count(pred) == 0,
            new ConstraintError("there are PAC's referenced this proxy rule"));
    }

    @safe ProxyRule makeProxyRule(in dlproxyrule.ProxyRule dto)
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

    void validatePACModify(in long id, in PACInput i, in bool update)
    {
        if (!i.name.isNull)
        {
            auto name = i.name.get().strip();
            auto nameEq = (in dlpac.PAC p) {
                return (!update || p.key() != id) && p.value().name() == name;
            };
            enforce!bool(pacs.count(nameEq) == 0, new ConstraintError("PAC with the same name already exists"));
        }

        if (!update)
        {
            if (i.serve.get())
            {
                enforce!bool(!i.servePath.isNull, new ConstraintError("servePath can't be null"));
                enforce!bool(i.servePath.get.strip().length != 0, new ConstraintError("servePath can't be empty"));
                auto servePath = i.servePath.get().strip();

                auto servePathEq = (in dlpac.PAC p) {
                    return (!update || p.key() != id) && p.value().servePath() == servePath;
                };
                enforce!bool(pacs.count(servePathEq) == 0, new ConstraintError("PAC with the same servePath already exists"));
            }

            if (i.saveToFS.get())
            {
                enforce!bool(!i.saveToFSPath.isNull, new ConstraintError("saveToFSPath can't be null"));
                enforce!bool(i.saveToFSPath.get.strip().length != 0, new ConstraintError("saveToFSPath can't be empty"));
                auto saveToFSPath = i.saveToFSPath.get().strip();

                auto saveToFSPathEq = (in dlpac.PAC p) {
                    return (!update || p.key() != id) && p.value().saveToFSPath() == saveToFSPath;
                };
                enforce!bool(pacs.count(saveToFSPathEq) == 0, new ConstraintError("PAC with the same saveToFSPath already exists"));
            }
        }
        else
        {
            auto old = pacs.getByKey(id).value();

            if (!i.serve.isNull && i.serve.get())
            {
                if (!i.servePath.isNull)
                {
                    auto newServePath = i.servePath.get().strip();
                    auto servePathEq = (in dlpac.PAC p) {
                        return p.key() != id && p.value().servePath() == newServePath;
                    };
                    enforce!bool(pacs.count(servePathEq) == 0, new ConstraintError("PAC with the same servePath already exists"));
                }
                else 
                {
                    enforce!bool(old.servePath().length != 0, new ConstraintError("servePath can't be empty"));
                }
            }

            if (!i.saveToFS.isNull && i.saveToFS.get())
            {
                if (!i.saveToFSPath.isNull)
                {
                    auto newSaveToFSPath = i.saveToFSPath.get().strip();
                    auto saveToFSPathEq = (in dlpac.PAC p) {
                        return p.key() != id && p.value().saveToFSPath() == newSaveToFSPath;
                    };
                    enforce!bool(pacs.count(saveToFSPathEq) == 0, new ConstraintError("PAC with the same saveToFSPath already exists"));
                }
                else 
                {
                    enforce!bool(old.saveToFSPath().length != 0, new ConstraintError("saveToFSPath can't be empty"));
                }
            }           
        }
        
        foreach (prId; i.proxyRules.byKey())
        {
            enforce!bool(proxyRules.exists(prId), new ProxyRuleNotFound(prId));
        }

        enforce!bool(i.fallbackProxyId.isNull || proxies.exists(i.fallbackProxyId.get()), new ProxyNotFound(i.fallbackProxyId.get()));
    }

    @safe PAC makePAC(in dlpac.PAC dto)
    {
        auto id = dto.key();

        auto prs = dto.value().proxyRules()
            .map!(
                pr => new ProxyRulePriority(makeProxyRule(proxyRules.getByKey(pr.proxyRuleId)),
                    pr.priority)
            )
            .array;

        auto fallBackProxy = makeProxy(proxies.getByKey(dto.value().fallbackProxyId()));

        return new PAC(id,
            dto.value().name(),
            dto.value().description(),
            prs,
            dto.value().serve(),
            dto.value().servePath(),
            dto.value().saveToFS(),
            dto.value().saveToFSPath(),
            fallBackProxy,
            dto.value().updatedAt()
        );
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
    ReadWriteMutex m_mutex;
}

private string valueOrDefault(in string s1, in string s2) pure @safe
{
    auto s = s1.strip;
    return s.length != 0 ? s : s2;
}

private long valueOrDefault(in long v1, in long v2) pure @safe
{
    return v1 > 0 ? v1 : v2;
}
