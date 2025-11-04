module datalayer.repository.repository;

import core.sync.rwmutex;
import std.algorithm.iteration : each;
import std.algorithm.iteration : map;
import std.algorithm.searching : maxElement;
import std.array;
import std.conv;
import std.exception : enforce;
import std.json;
import std.traits;

import datalayer.repository.errors;

interface ISerializable
{
    @safe JSONValue toJSON() const pure;
    void fromJSON(in JSONValue v);
}

class DataObject(K, V:
    ISerializable) : ISerializable
{
    alias KeyType = K;
    alias ValueType = V;
    alias ThisType = DataObject!(K, V);

    @safe this() pure
    {
    }

    @safe this(in ThisType other) pure
    {
        m_key = KeyType(other.m_key);
        m_value = new ValueType(other.m_value);
    }

    @safe this(in KeyType k, in ValueType v) pure
    {
        m_key = KeyType(k);
        m_value = new ValueType(v);
    }

    @safe const(KeyType) key() const pure
    {
        return m_key;
    }

    @safe const(ValueType) value() const pure
    {
        return m_value;
    }

    @safe override JSONValue toJSON() const pure
    {
        return JSONValue(["id": JSONValue(key()), "value": value().toJSON()]);
    }

    override void fromJSON(in JSONValue v)
    {
        setKey(v.object["id"].integer);
        ValueType value = new ValueType();
        value.fromJSON(v.object["value"]);
        setValue(value);
    }

protected:
    void setKey(in KeyType k)
    {
        m_key = KeyType(k);
    }

    void setValue(in ValueType v)
    {
        m_value = new ValueType(v);
    }

private:
    KeyType m_key;
    ValueType m_value;
}

interface IRepository(K, V)
{
    alias KeyType = K;
    alias ValueType = V;
    alias DataObjectType = DataObject!(K, V).ThisType;

    const(DataObjectType)[] getAll();
    const(DataObjectType) getByKey(in KeyType key);
    bool exists(in KeyType key);
    const(DataObjectType) create(in ValueType value);
    const(DataObjectType) update(in KeyType key, in ValueType value);
    DataObjectType remove(in KeyType key);
}

interface IDataLoader(K, V)
{
    @safe void load(in DataObject!(K, V)[] data);
}

enum ListenerEvent
{
    CREATE,
    UPDATE,
    REMOVE
}

interface IListener(T)
{
    @safe void onChange(in ListenerEvent e, in T object);
}

alias Key = long;

class RepositoryBase(K, V) : IRepository!(K, V), IDataLoader!(K, V)
{
    this(IListener!(DataObjectType) listener)
    {
        m_mutex = new ReadWriteMutex();
        m_listener = listener;
    }

    override const(DataObjectType)[] getAll()
    {
        synchronized (m_mutex.reader)
        {
            return m_entities.values;
        }
    }

    @safe override const(DataObjectType) getByKey(in KeyType key)
    {
        synchronized (m_mutex.reader)
        {
            auto entity = enforce!NotFoundError(key in m_entities, fullyQualifiedName!V ~ " id=" ~ to!string(
                    key) ~ " not found");
            return *entity;
        }
    }

    @safe override bool exists(in KeyType key)
    {
        synchronized (m_mutex.reader)
        {
            return (key in m_entities) != null;
        }
    }

    @safe override const(DataObjectType) create(in ValueType value)
    {
        DataObjectType newDataObject;
        synchronized (m_mutex.writer)
        {
            immutable KeyType key = getNewKey();
            newDataObject = new DataObject!(K, V)(key, value);
            m_entities[key] = newDataObject;
        }
        m_listener.onChange(ListenerEvent.CREATE, newDataObject);
        return newDataObject;
    }

    @safe override const(DataObjectType) update(in KeyType key, in ValueType value)
    {
        DataObjectType updatedDataObject;
        synchronized (m_mutex.writer)
        {
            enforce!NotFoundError(key in m_entities, fullyQualifiedName!V ~ " id=" ~ to!string(
                    key) ~ " not found");

            updatedDataObject = new DataObject!(K, V)(key, value);
            m_entities[key] = updatedDataObject;
        }
        m_listener.onChange(ListenerEvent.UPDATE, updatedDataObject);
        return updatedDataObject;
    }

    @safe override DataObjectType remove(in KeyType key)
    {
        DataObjectType removedDataObject;
        synchronized (m_mutex.writer)
        {
            auto entity = enforce!NotFoundError(key in m_entities, fullyQualifiedName!V ~ " id=" ~ to!string(
                    key) ~ " not found");
            m_entities.remove(key);
            removedDataObject = *entity;
        }
        m_listener.onChange(ListenerEvent.UPDATE, removedDataObject);
        return removedDataObject;
    }

    @safe override void load(in DataObjectType[] data)
    {
        synchronized (m_mutex.writer)
        {
            m_entities.clear();
            foreach (d; data)
            {
                m_entities[d.key()] = new DataObjectType(d);
            }
        }
    }

protected:
    @safe KeyType getNewKey() const pure
    {
        if (!m_entities.length)
        {
            return 1;
        }

        return m_entities.keys.maxElement + 1;
    }

private:
    DataObjectType[KeyType] m_entities;
    ReadWriteMutex m_mutex;
    IListener!(DataObjectType) m_listener;
}

private class UnitTestValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in UnitTestValue v) pure
    {
        m_data = v.m_data.dup;
    }

    @safe this(in string data) pure
    {
        m_data = data;
    }

    @safe const(string) data() const pure
    {
        return m_data;
    }

    @safe JSONValue toJSON() const
    {
        return JSONValue(["data": JSONValue(data())]);
    }

    override void fromJSON(in JSONValue v)
    {
        m_data = v.object["data"].str;
    }

protected:
    string m_data;
}

unittest
{
    alias UnitTest = DataObject!(Key, UnitTestValue);

    class UnitTestRepository : RepositoryBase!(Key, UnitTestValue)
    {
        this(IListener!(UnitTest) listener)
        {
            super(listener);
        }
    }

    class StubListener : IListener!(UnitTest)
    {
        @safe void onChange(in ListenerEvent e, in UnitTest object)
        {
        }
    }

    UnitTestRepository testRepository = new UnitTestRepository(new StubListener());
    UnitTestValue testValue = new UnitTestValue("test");

    auto dataObjectFromCreate = testRepository.create(testValue);
    assert(dataObjectFromCreate.key() == 1);

    auto dataObjectFromGet = testRepository.getByKey(dataObjectFromCreate.key());
    assert(dataObjectFromGet is dataObjectFromCreate);

    assert(testRepository.getAll().length == 1);

    bool caught = false;
    try
    {
        testRepository.getByKey(-1); // throws
    }
    catch (NotFoundError e)
    {
        caught = true;
    }
    assert(caught);
}
