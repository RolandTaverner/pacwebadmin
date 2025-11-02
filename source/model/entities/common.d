module model.entities.common;

mixin template entityId()
{
    @safe long id() const pure
    {
        return m_id;
    }

    private long m_id;
}
