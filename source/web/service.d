module web.service;

import std.algorithm.iteration : map;
import std.array;
import std.conv;

import vibe.vibe;
import vibe.http.common;

import model.model;
import model.entities.category;
import model.entities.proxy;
import model.entities.hostrule;

import web.api.root;
import web.api.category;
import web.api.proxy;
import web.api.hostrule;


class Service : APIRoot 
{
    this(Model model)
    {
        m_model = model;

        m_categoriesSvc = new CategoriesService(m_model);
        m_proxiesSvc = new ProxiesService(m_model);
        m_hostRulesSvc = new HostRulesService(m_model);
    }

    override @property CategoriesAPI categories()
    {
        return m_categoriesSvc;
    }

    override @property ProxiesAPI proxies()
    {
        return m_proxiesSvc;
    }

    override @property HostRulesAPI hostRules()
    {
        return m_hostRulesSvc;
    }

private:    
    Model m_model;
    CategoriesService m_categoriesSvc;
    ProxiesService m_proxiesSvc;
    HostRulesService m_hostRulesSvc;
}


class CategoriesService : CategoriesAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override Categories getAll()
    {
        Categories response = { array(m_model.getCategories().map!(c => toDTO(c))) };
        return response;
    }

    @safe override CategoryDTO create(in CategoryInputDTO c)
    {
        const CategoryInput ci = { name: c.name };
        const Category created = m_model.createCategory(ci);
        return toDTO(created);
    }

    @safe override CategoryDTO update(in long id, in CategoryInputDTO c)
    {
        return remapExceptions!(delegate() 
        {
            const CategoryInput ci = { name: c.name };
            const Category updated = m_model.updateCategory(id, ci);
            return toDTO(updated);
        }, CategoryDTO);
    }

    @safe override CategoryDTO getById(in long id)
    {
        return remapExceptions!(delegate() 
        { 
            const Category got = m_model.categoryById(id);
            return toDTO(got);
        }, CategoryDTO);        
    }

    @safe override CategoryDTO remove(in long id)
    {
        return remapExceptions!(delegate() 
        { 
            const Category removed = m_model.deleteCategory(id);
            return toDTO(removed);
        }, CategoryDTO);
    }

private:    
    Model m_model;
}


class ProxiesService : ProxiesAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override Proxies getAll()
    {
        Proxies response = { array(m_model.getProxies().map!(c => toDTO(c))) };
        return response;
    }

    @safe override ProxyDTO create(in ProxyInputDTO p)
    {
        const ProxyInput pi = { hostAddress: p.hostAddress, description: p.description, builtIn: p.builtIn };
        const Proxy created = m_model.createProxy(pi);
        return toDTO(created);
    }

    @safe override ProxyDTO update(in long id, in ProxyInputDTO p)
    {
        return remapExceptions!(delegate() 
        { 
            const ProxyInput pi = { hostAddress: p.hostAddress, description: p.description, builtIn: p.builtIn };
            const Proxy updated = m_model.updateProxy(id, pi);
            return toDTO(updated);
        }, ProxyDTO);
    }

    @safe override ProxyDTO getById(in long id)
    {
        return remapExceptions!(delegate() 
        { 
            const Proxy got = m_model.proxyById(id);
            return toDTO(got);
        }, ProxyDTO);        
    }

    @safe override ProxyDTO remove(in long id)
    {
        return remapExceptions!(delegate() 
        { 
            const Proxy removed = m_model.deleteProxy(id);
            return toDTO(removed);
        }, ProxyDTO);
    }

private:    
    Model m_model;
}


class HostRulesService : HostRulesAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override HostRules getAll()
    {
        HostRules response = { array(m_model.getHostRules().map!(c => toDTO(c))) };
        return response;
    }

    @safe override HostRuleDTO create(in HostRuleInputDTO p)
    {
        const HostRuleInput hri = { hostTemplate: p.hostTemplate, strict: p.strict, categoryId: p.categoryId };
        const HostRule created = m_model.createHostRule(hri);
        return toDTO(created);
    }

    @safe override HostRuleDTO update(in long id, in HostRuleInputDTO p)
    {
        return remapExceptions!(delegate() 
        { 
            const HostRuleInput hri = { hostTemplate: p.hostTemplate, strict: p.strict, categoryId: p.categoryId };
            const HostRule updated = m_model.updateHostRule(id, hri);
            return toDTO(updated);
        }, HostRuleDTO);
    }

    @safe override HostRuleDTO getById(in long id)
    {
        return remapExceptions!(delegate() 
        { 
            const HostRule got = m_model.hostRuleById(id);
            return toDTO(got);
        }, HostRuleDTO);        
    }

    @safe override HostRuleDTO remove(in long id)
    {
        return remapExceptions!(delegate() 
        { 
            const HostRule removed = m_model.deleteHostRule(id);
            return toDTO(removed);
        }, HostRuleDTO);
    }

private:    
    Model m_model;
}

T remapExceptions(alias fun, T)() @safe {
    try
    {
        return fun();
    } 
    catch (CategoryNotFound e)
    {
        throw new HTTPStatusException(404, e.getEntityType() ~ " id=" ~ to!string(e.getEntityId()) ~ " not found");
    }
    catch (ProxyNotFound e)
    {
        throw new HTTPStatusException(404, e.getEntityType() ~ " id=" ~ to!string(e.getEntityId()) ~ " not found");
    }
    catch (HostRuleNotFound e)
    {
        throw new HTTPStatusException(404, e.getEntityType() ~ " id=" ~ to!string(e.getEntityId()) ~ " not found");
    }
}


@safe CategoryDTO toDTO(in Category c) {
    return CategoryDTO(c.id(), c.name());
}

@safe ProxyDTO toDTO(in Proxy p) {
    return ProxyDTO(p.id(), p.hostAddress(), p.description(), p.builtIn());
}

@safe HostRuleDTO toDTO(in HostRule hr) {
    return HostRuleDTO(hr.id(), hr.hostTemplate, hr.strict, toDTO(hr.category()));
}

// class WebService {
//     private SessionVar!(string, "username") username_;

//     void index(HTTPServerResponse res)
//     {
//         auto contents = q{<html><head>
//             <title>Tell me!</title>
//         </head><body>
//         <form action="/username" method="POST">
//         Your name:
//         <input type="text" name="username">
//         <input type="submit" value="Submit">
//         </form>
//         </body>
//         </html>};

//         res.writeBody(contents, "text/html; charset=UTF-8");
//     }

//     @method(HTTPMethod.GET) @path("/api/categories")
//     void getCategories( ) {
        
//     }

//     @path("/name")
//     void getName(HTTPServerRequest req, HTTPServerResponse res)
//     {
//         import std.string : format;

//         // Инспектируется свойство запроса
//         // headers и генерируются
//         // теги <li>.
//         string[] headers;
//         foreach (key, value; req.headers.byKeyValue()) {
//             headers ~= "<li>%s: %s</li>".format(key, value);
//         }
//         auto contents = q{<html><head>
//             <title>Tell me!</title>
//         </head><body>
//         <h1>Your name: %s</h1>
//         <h2>Headers</h2>
//         <ul>
//         %s
//         </ul>
//         </body>
//         </html>}.format(username_.value, headers.join("\n"));

//         res.writeBody(contents, "text/html; charset=UTF-8");
//     }

//     void postUsername(string username, HTTPServerResponse res)
//     {
//         username_ = username;
//         auto contents = q{<html><head>
//             <title>Tell me!</title>
//         </head><body>
//         <h1>Your name: %s</h1>
//         </body>
//         </html>}.format(username_.value);

//         res.writeBody(contents, "text/html; charset=UTF-8");
//     }

// }

