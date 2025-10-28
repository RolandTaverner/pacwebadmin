module datalayer.repository;

import std.algorithm.iteration : each;
import std.algorithm.iteration : map;
import std.algorithm.searching : maxElement;
import std.array;
import std.json;


interface ISerializable {
public:
    JSONValue toJSON() const;
    void fromJSON(in JSONValue v);
}


class DataObject(K, V : ISerializable) : ISerializable {
public:
    alias KeyType = K;
    alias ValueType = V;

    this() {
    }

    this(in KeyType k, in ValueType v) {
        m_key = KeyType(k);
        m_value = new ValueType(v);
    }

    const(KeyType) key() const {
        return m_key;
    }

    const(ValueType) value() const {
        return m_value;
    }

    JSONValue toJSON() const {
        return JSONValue(["id": JSONValue(key()), "value": value().toJSON]);
    }
    
    void fromJSON(in JSONValue v) {
        setKey(v.object["id"].integer);
        ValueType value = new ValueType();
        value.fromJSON(v.object["value"]);
        setValue(value);
    }

protected:
    void setKey(in KeyType k) {
        m_key = KeyType(k);
    }

    void setValue(in ValueType v) {
        m_value = new ValueType(v);
    }

private:
    KeyType m_key;
    ValueType m_value;
}


interface IRepository(K, V) : ISerializable {
public:
    alias KeyType = K;
    alias ValueType = V;
    alias DataObjectType = DataObject!(K, V);

    const(DataObjectType)[] getAll() const;
    const(DataObjectType) getByKey(in KeyType key) const;
    const(DataObjectType) create(in ValueType value);
    const(DataObjectType) update(in KeyType key, in ValueType value);
    DataObjectType remove(in KeyType key);
}


alias Key = long;


class RepositoryBase(K, V) : IRepository!(K, V) {
public:
    this() {
    }

    const(DataObjectType)[] getAll() const {
        return m_entities.values;
    }

    const(DataObjectType) getByKey(in KeyType key) const{
        return m_entities[key];
    }

    const(DataObjectType) create(in ValueType value) {
        immutable KeyType key = getNewKey();
        DataObjectType newDataObject = new DataObject!(K, V)(key, value);
        m_entities[key] = newDataObject;
        return newDataObject;
    }

    const(DataObjectType) update(in KeyType key, in ValueType value) {
        if (key !in m_entities) {
            throw new Error("TODO");
        }

        DataObjectType newDataObject = new DataObject!(K, V)(key, value);
        m_entities[key] = newDataObject;
        return newDataObject;
    }

    DataObjectType remove(in KeyType key) {
        auto entity = key in m_entities;
        if (entity == null) {
            throw new Error("TODO");
        }
        m_entities.remove(key);
        return *entity;
    }

    JSONValue toJSON() const {
        return JSONValue(m_entities.values.map!(p => p.toJSON).array);
    }
    
    void fromJSON(in JSONValue v) {
        m_entities.clear();

        v.array.each!(
            (ref const JSONValue jv) => () { 
                DataObjectType d = new DataObjectType();
                d.fromJSON(jv);
                m_entities[d.key()] = d;
            }
        );
    }

protected:
    KeyType getNewKey() const {
        if (!m_entities.length) {
            return 0;
        }

        return m_entities.keys.maxElement + 1;
    }

private:
    DataObjectType[KeyType] m_entities;
}


private class TestValue : ISerializable {
    public:
        this() {
        }

        this(in TestValue v) {
            m_data = v.m_data.dup;
        }

        this(in string data) {
            m_data = data;
        }

        const(string) data() const {
            return m_data;
        }

        JSONValue toJSON() const {
            return JSONValue(["data": JSONValue(data())]);
        }

        void fromJSON(in JSONValue v) {
            m_data = v.object["data"].str;
        }

    protected:
        string m_data;
    }

unittest
{
    class TestRepository : RepositoryBase!(Key, TestValue) {
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