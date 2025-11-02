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
    JSONValue toJSON() const;
    void fromJSON(in JSONValue v);
}


class DataObject(K, V : ISerializable) : ISerializable 
{
    alias KeyType = K;
    alias ValueType = V;

    @safe this() pure
    {
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

    JSONValue toJSON() const 
    {
        return JSONValue(["id": JSONValue(key()), "value": value().toJSON]);
    }
    
    void fromJSON(in JSONValue v) 
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


interface IRepository(K, V) : ISerializable {
    alias KeyType = K;
    alias ValueType = V;
    alias DataObjectType = DataObject!(K, V);

    @safe const(DataObjectType)[] getAll() const;
    const(DataObjectType) getByKey(in KeyType key) const;
    const(DataObjectType) create(in ValueType value);
    const(DataObjectType) update(in KeyType key, in ValueType value);
    DataObjectType remove(in KeyType key);
}


alias Key = long;


class RepositoryBase(K, V) : IRepository!(K, V) 
{
    this()
    {
        m_mutex = new ReadWriteMutex();
    }

    const(DataObjectType)[] getAll() const pure
    {
        return m_entities.values;
    }

    @safe const(DataObjectType) getByKey(in KeyType key) const pure
    {
        auto entity = enforce!NotFoundError(key in m_entities, fullyQualifiedName!V ~ " id=" ~ to!string(key) ~ " not found");
        return *entity;
    }

    @safe bool exists(in KeyType key) const pure
    {
        return (key in m_entities) != null;
    }

    @safe const(DataObjectType) create(in ValueType value)
    {
        immutable KeyType key = getNewKey();
        DataObjectType newDataObject = new DataObject!(K, V)(key, value);
        m_entities[key] = newDataObject;
        return newDataObject;
    }

    @safe const(DataObjectType) update(in KeyType key, in ValueType value)
    {
        enforce!NotFoundError(key in m_entities, fullyQualifiedName!V ~ " id=" ~ to!string(key) ~ " not found");

        DataObjectType newDataObject = new DataObject!(K, V)(key, value);
        m_entities[key] = newDataObject;
        return newDataObject;
    }

    @safe DataObjectType remove(in KeyType key)
    {
        auto entity = enforce!NotFoundError(key in m_entities, fullyQualifiedName!V ~ " id=" ~ to!string(key) ~ " not found");
        m_entities.remove(key);
        return *entity;
    }

    JSONValue toJSON() const 
    {
        return JSONValue(m_entities.values.map!(p => p.toJSON).array);
    }
    
    void fromJSON(in JSONValue v)
    {
        m_entities.clear();

        v.array.each!(
            (ref const JSONValue jv) => () 
                { 
                    DataObjectType d = new DataObjectType();
                    d.fromJSON(jv);
                    m_entities[d.key()] = d;
                }
        );
    }

protected:
    @safe KeyType getNewKey() const pure
    {
        if (!m_entities.length) {
            return 1;
        }

        return m_entities.keys.maxElement + 1;
    }

private:
    DataObjectType[KeyType] m_entities;
    ReadWriteMutex m_mutex;
}


private class TestValue : ISerializable
{
    @safe this() pure
    {
    }

    @safe this(in TestValue v) pure
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

    JSONValue toJSON() const
    {
        return JSONValue(["data": JSONValue(data())]);
    }

    void fromJSON(in JSONValue v)
    {
        m_data = v.object["data"].str;
    }

protected:
    string m_data;
}


unittest
{
    class TestRepository : RepositoryBase!(Key, TestValue)
    {
    }

    TestRepository testRepository = new TestRepository();
    TestValue testValue = new TestValue("test");
    
    auto dataObjectFromCreate = testRepository.create(testValue);
    assert(dataObjectFromCreate.key() == 0);

    auto dataObjectFromGet = testRepository.getByKey(dataObjectFromCreate.key());
    assert(dataObjectFromGet is dataObjectFromCreate);

    assert(testRepository.getAll().length == 1);
    //testRepository.getById(-1); // throws
}
