module model.pacmanager;

import model.model;

class PACManager
{
    this(Model model)
    {
        m_model = model;
    }

    const(string) getPACfilePath(in string urlPath) @trusted
    {
        import std.stdio;
        writeln("getPACfilePath(): " ~ urlPath);

        return "todo";
    }

private:
    Model m_model;
}
