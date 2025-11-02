module model.errors.base;


import std.exception;
import std.traits;


abstract class ModelError : Exception 
{
    mixin basicExceptionCtors;
}


class ConstraintError : ModelError {
    mixin basicExceptionCtors;
}


abstract class EntityErrorBase(T) : ModelError 
{
    this(long id, string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @nogc @safe pure nothrow
    {
        super(msg, file, line, next);
        m_entityId = id;
        m_entityType = fullyQualifiedName!T;
    }

    this(long id, string msg, Throwable next, string file = __FILE__, size_t line = __LINE__) @nogc @safe pure nothrow
    {
        super(msg, file, line, next);
        m_entityId = id;
        m_entityType = fullyQualifiedName!T;
    }

    @safe long getEntityId() const pure {
        return m_entityId;
    }

    @safe const(string) getEntityType() const pure {
        return m_entityType;
    }

protected:
    long m_entityId;
    string m_entityType;    
}


abstract class NotFoundBase(T) : EntityErrorBase!(T) 
{
    mixin entityErrorCtors;
}


abstract class AlreadyExistsBase(T) : EntityErrorBase!(T) 
{
    mixin entityErrorCtors;
}


private mixin template entityErrorCtors()
{
    this(long id, string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @nogc @safe pure nothrow
    {
        super(id, msg, file, line, next);
    }

    this(long id, string msg, Throwable next, string file = __FILE__, size_t line = __LINE__) @nogc @safe pure nothrow
    {
        super(id, msg, file, line, next);
    }
}


mixin template finalEntityErrorCtors(string msg)
{
    this(long id, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @nogc @safe pure nothrow
    {
        super(id, msg, file, line, next);
    }

    this(long id, Throwable next, string file = __FILE__, size_t line = __LINE__) @nogc @safe pure nothrow
    {
        super(id, msg, file, line, next);
    }
}
