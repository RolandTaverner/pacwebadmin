module model.pacbuilder;

import std.array : appender, Appender;

import model.model;
import model.entities.pac : PAC;

class PACBuilder
{
    this(Model model)
    {
        m_model = model;
    }

    string build(long id)
    {
        auto pacModel = m_model.pacById(id);
        auto app = appender!string();
        addHeader(app, pacModel);

        return app.data;
    }

protected:

    void addHeader(scope ref Appender!string app, scope ref const PAC pacModel)
    {
        app.put(commentLine(pacModel.name()));
        app.put(commentText(pacModel.description()));
    }

private:
    Model m_model;
}

string commentLine(scope const(string) line)
{
    return "// " ~ line ~ "\n";
}

unittest
{
    assert(commentLine("a b c") == "// a b c\n");
}

string commentText(scope const(string) text)
{
    import std.array : array, replace, split;
    import std.algorithm.iteration : each, filter;

    auto app = appender!string();

    text.replace("\r\n", "\n")
        .split("\n")
        .filter!(line => line.length != 0)
        .each!(line => app.put(commentLine(line)));

    return app.data;
}

unittest
{
    assert(commentText("a b c") == "// a b c\n");
    assert(commentText("abc\nxyz") == "// abc\n// xyz\n");
}
