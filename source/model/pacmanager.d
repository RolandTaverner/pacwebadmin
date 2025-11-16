module model.pacmanager;

import model.model;

class PACManager
{
    this(Model model)
    {
        m_model = model;
    }

    const(string) getPACfile(in string urlPath)
    {
        return "todo";
    }

private:
    Model m_model;
}
