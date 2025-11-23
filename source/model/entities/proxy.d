module model.entities.proxy;

import std.algorithm : canFind, map;
import std.array;
import std.exception : enforce;
import std.string;
import std.traits : EnumMembers;
import std.typecons : Nullable;

import model.entities.common;
import model.errors.base;

enum ProxyType : string
{
    DIRECT = "DIRECT",
    PROXY = "PROXY",
    SOCKS = "SOCKS",
    SOCKS4 = "SOCKS4",
    SOCKS5 = "SOCKS5",
    HTTP = "HTTP",
    HTTPS = "HTTPS",
}

class Proxy
{
    @safe this(in Proxy other) pure
    {
        m_id = other.m_id;
        m_type = other.m_type;
        m_address = other.m_address;
        m_description = other.m_description;
    }

    @safe this(in long id, in string type, in string address, in string description) pure
    {
        m_id = id;
        m_type = type;
        m_address = address;
        m_description = description;
    }

    @safe const(string) type() const pure
    {
        return m_type;
    }

    @safe const(string) address() const pure
    {
        return m_address;
    }

    @safe const(string) description() const pure
    {
        return m_description;
    }

    mixin entityId!();

private:
    string m_type;
    string m_address;
    string m_description;
}

struct ProxyInput
{
    Nullable!string type;
    Nullable!string address;
    Nullable!string description;

    @safe void validate(bool update) const pure
    {
        if (!update)
        {
            enforce!bool(!type.isNull, new ConstraintError("type can't be null"));
            enforce!bool(type.get().strip().length != 0, new ConstraintError("type can't be empty"));

            if (type.get().strip() == ProxyType.DIRECT)
            {
                enforce!bool(address.isNull || address.get().strip().length == 0, 
                    new ConstraintError("address must be empty for proxy with type == DIRECT"));
            }
            else
            {
                enforce!bool(!address.isNull && address.get().strip().length != 0,
                    new ConstraintError("address can't be empty"));
            }
        }
        else
        {
            if (!type.isNull)
            {
                if (type.get().strip() == ProxyType.DIRECT)
                {
                    enforce!bool(address.isNull || address.get().strip().length == 0, 
                        new ConstraintError("address must be empty for proxy with type == DIRECT"));
                }
                else
                {
                    enforce!bool(address.isNull || address.get().strip().length != 0,
                        new ConstraintError("address can't be empty"));
                }
            }
        }

        if (!type.isNull)
        {
            const auto proxyTypeValues = [EnumMembers!ProxyType]
                .map!(el => cast(string) el)
                .array;
            enforce!bool(proxyTypeValues.canFind(type.get()), new ConstraintError("invalid type"));
        }
    }
}

struct ProxyFilter
{
    @safe this(in string type, in string address) pure
    {
        this.type = type;
        this.address = address;
    }

    string type;
    string address;

    @safe void validate() const pure
    {
        enforce!bool(type.strip().length != 0 || address.strip().length,
            new ConstraintError("empty filter values"));
    }
}

class ProxyNotFound : NotFoundBase!(Proxy)
{
    mixin finalEntityErrorCtors!("not found");
}
