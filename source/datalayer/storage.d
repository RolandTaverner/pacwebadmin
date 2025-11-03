module datalayer.storage;

import std.algorithm.iteration : each;
import std.algorithm.iteration : map;
import std.array;
import core.sync.rwmutex;
import std.exception;
import std.json;

import datalayer.entities.category;
import datalayer.entities.hostrule;
import datalayer.entities.pac;
import datalayer.entities.proxy;
import datalayer.entities.proxyrules;
import datalayer.repository.repository;

class Storage : ICategoryListener, IHostRuleListener, IPACListener, IProxyListener, IProxyRulesListener, ISerializable
{
    this()
    {
        m_mutex = new ReadWriteMutex();

        m_categories = new CategoryRepository(this);
        m_hostRules = new HostRuleRepository(this);
        m_pacs = new PACRepository(this);
        m_proxies = new ProxyRepository(this);
        m_proxyRules = new ProxyRulesRepository(this);
    }

    @safe override JSONValue toJSON() const pure
    {
        // return JSONValue([
        //     "category": m_categories.toJSON(),
        //     "hostrule": m_hostRules.toJSON(),
        //     "pac": m_pacs.toJSON(),
        //     "proxy": m_proxies.toJSON(),
        //     "proxyrule": m_proxyRules.toJSON(),
        // ]);
        return JSONValue();
    }

    override void fromJSON(in JSONValue v)
    {
        synchronized (m_mutex.writer)
        {
            loadCollection!(Category)(v, m_categories);
            loadCollection!(HostRule)(v, m_hostRules);
            loadCollection!(PAC)(v, m_pacs);
            loadCollection!(Proxy)(v, m_proxies);
            loadCollection!(ProxyRules)(v, m_proxyRules);
        }
    }

    @safe inout(CategoryRepository) categories() inout pure
    {
        return m_categories;
    }

    @safe inout(HostRuleRepository) hostRules() inout pure
    {
        return m_hostRules;
    }

    @safe inout(PACRepository) pacs() inout pure
    {
        return m_pacs;
    }

    @safe inout(ProxyRepository) proxies() inout pure
    {
        return m_proxies;
    }

    @safe inout(ProxyRulesRepository) proxyRules() inout pure
    {
        return m_proxyRules;
    }

    @safe override void onChange(in ListenerEvent e, in Category object)
    {
        updateStorage(e, object);
    }

    @safe override void onChange(in ListenerEvent e, in HostRule object)
    {
        updateStorage(e, object);
    }

    @safe override void onChange(in ListenerEvent e, in PAC object)
    {
        updateStorage(e, object);
    }

    @safe override void onChange(in ListenerEvent e, in Proxy object)
    {
        updateStorage(e, object);
    }

    @safe override void onChange(in ListenerEvent e, in ProxyRules object)
    {
        updateStorage(e, object);
    }

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
    }

    ReadWriteMutex m_mutex;
    JSONValue[Key][string] m_data;

    CategoryRepository m_categories;
    HostRuleRepository m_hostRules;
    PACRepository m_pacs;
    ProxyRepository m_proxies;
    ProxyRulesRepository m_proxyRules;
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

string collectionKey(T : HostRule)()
{
    return "hostRule";
}

string collectionKey(T : PAC)()
{
    return "pac";
}

string collectionKey(T : Proxy)()
{
    return "proxy";
}

string collectionKey(T : ProxyRules)()
{
    return "proxyRules";
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

void loadCollection(T)(in JSONValue v, IDataLoader!(T.KeyType, T.ValueType) loader)
{
    const string key = collectionKey!(T)();
    if (auto collectionValue = key in v)
    {
        loader.load(parseCollection!(T)(*collectionValue));
    }
}
