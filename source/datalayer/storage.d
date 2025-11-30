module datalayer.storage;

import std.algorithm.iteration : map;
import std.array;
import core.sync.rwmutex;
import std.exception;
import std.json;

import datalayer.entities.category;
import datalayer.entities.condition;
import datalayer.entities.pac;
import datalayer.entities.proxy;
import datalayer.entities.proxyrule;
import datalayer.repository.repository;

interface IStorageSaver
{
    @trusted void save(ref const JSONValue v);
}

class Storage : ICategoryListener, IConditionListener, IPACListener, IProxyListener, IProxyRuleListener
{
    this(IStorageSaver saver)
    {
        m_saver = saver;
        m_mutex = new ReadWriteMutex();

        m_categories = new CategoryRepository(this);
        m_conditions = new ConditionRepository(this);
        m_pacs = new PACRepository(this);
        m_proxies = new ProxyRepository(this);
        m_proxyRules = new ProxyRuleRepository(this);
    }

    @safe JSONValue dump()
    {
        JSONValue v = JSONValue();
        synchronized (m_mutex.reader)
        {
            foreach (ref collection; m_data.byKeyValue)
            {
                v[collection.key] = JSONValue(collection.value.byValue.array);
            }
        }

        return v;
    }

    void load(in JSONValue v)
    {
        synchronized (m_mutex.writer)
        {
            loadCollection!(Category)(v, m_categories);
            loadCollection!(Condition)(v, m_conditions);
            loadCollection!(PAC)(v, m_pacs);
            loadCollection!(Proxy)(v, m_proxies);
            loadCollection!(ProxyRule)(v, m_proxyRules);
        }
    }

    @safe inout(CategoryRepository) categories() inout pure
    {
        return m_categories;
    }

    @safe inout(ConditionRepository) conditions() inout pure
    {
        return m_conditions;
    }

    @safe inout(PACRepository) pacs() inout pure
    {
        return m_pacs;
    }

    @safe inout(ProxyRepository) proxies() inout pure
    {
        return m_proxies;
    }

    @safe inout(ProxyRuleRepository) proxyRules() inout pure
    {
        return m_proxyRules;
    }

    mixin onChangeFuncs!(Category);
    mixin onChangeFuncs!(Condition);
    mixin onChangeFuncs!(PAC);
    mixin onChangeFuncs!(Proxy);
    mixin onChangeFuncs!(ProxyRule);

private:

    @safe void updateStorage(T)(in ListenerEvent e, const ref T dataObject)
    {
        synchronized (m_mutex.writer)
        {
            if (isPutEvent(e))
            {
                m_data[collectionKey!(T)()][dataObject.key()] = dataObject.toJSON();
            }
            else
            {
                m_data[collectionKey!(T)()].remove(dataObject.key());
            }
        }

        auto snapshot = dump();
        m_saver.save(snapshot);
    }

    @safe void updateStorageBatch(T)(in ListenerEvent e, in const(T)[] dataObjects)
    {
        synchronized (m_mutex.writer)
        {
            if (isPutEvent(e))
            {
                foreach (dataObject; dataObjects)
                {
                    m_data[collectionKey!(T)()][dataObject.key()] = dataObject.toJSON();
                }
            }
            else
            {
                foreach (dataObject; dataObjects)
                {
                    m_data[collectionKey!(T)()].remove(dataObject.key());
                }
            }
        }

        auto snapshot = dump();
        m_saver.save(snapshot);
    }

    void loadCollection(T)(in JSONValue v, IDataLoader!(T.KeyType, T.ValueType) loader)
    {
        const string key = collectionKey!(T)();
        if (auto collectionValue = key in v)
        {
            auto dataObjects = parseCollection!(T)(*collectionValue);
            // TODO: check key uniqueness

            foreach (d; dataObjects)
            {
                m_data[collectionKey!(T)()][d.key()] = d.toJSON();
            }
            loader.load(dataObjects);
        }
    }

    ReadWriteMutex m_mutex;
    JSONValue[Key][string] m_data;
    IStorageSaver m_saver;

    CategoryRepository m_categories;
    ConditionRepository m_conditions;
    PACRepository m_pacs;
    ProxyRepository m_proxies;
    ProxyRuleRepository m_proxyRules;
}

private @safe bool isPutEvent(in ListenerEvent e) pure
{
    return e == ListenerEvent.CREATE || e == ListenerEvent.UPDATE;
}

void collectionKey(T)(void)
{
    // invalid instantiaion
}

string collectionKey(T : Category)()
{
    return "category";
}

string collectionKey(T : Condition)()
{
    return "condition";
}

string collectionKey(T : PAC)()
{
    return "pac";
}

string collectionKey(T : Proxy)()
{
    return "proxy";
}

string collectionKey(T : ProxyRule)()
{
    return "proxyRule";
}

T parseEntity(T)(in JSONValue v)
{
    T d = new T();
    d.fromJSON(v);
    return d;
}

T[] parseCollection(T)(in JSONValue v)
{
    return v.array.map!(i => parseEntity!(T)(i)).array;
}

private mixin template onChangeFuncs(T)
{
    @safe override void onChange(in ListenerEvent e, in T object)
    {
        updateStorage(e, object);
    }

    @safe override void onChangeBatch(in ListenerEvent e, in const(T)[] objects)
    {
        updateStorageBatch(e, objects);
    }
}
