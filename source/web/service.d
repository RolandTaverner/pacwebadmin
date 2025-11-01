module web.service;

import std.algorithm.iteration : map;
import std.array;
import std.conv;

import vibe.vibe;
import vibe.http.common;

import model.model;
import model.category;
import model.proxy;

import web.api.root;
import web.api.category;
import web.api.proxy;


class Service : APIRoot 
{
    this(Model model)
    {
        m_model = model;

        m_categoriesSvc = new CategoriesService(m_model);
        m_proxiesSvc = new ProxiesService(m_model);
    }

    override @property CategoriesAPI categories()
    {
        return m_categoriesSvc;
    }

    override @property ProxiesAPI proxies()
    {
        return m_proxiesSvc;
    }

private:    
    Model m_model;
    CategoriesService m_categoriesSvc;
    ProxiesService m_proxiesSvc;
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

    @safe override CategoryDTO create(in NewCategoryDTO c)
    {
        const Category created = m_model.createCategory(new Category(0, c.name));
        return toDTO(created);
    }

    @safe override CategoryDTO update(in CategoryDTO c)
    {
        return remapExceptions!(delegate() 
        { 
            const Category updated = m_model.updateCategory(new Category(c.id, c.name));
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

    @safe override ProxyDTO create(in NewProxyDTO p)
    {
        const Proxy created = m_model.createProxy(new Proxy(0, p.hostAddress, p.description, p.builtIn));
        return toDTO(created);
    }

    @safe override ProxyDTO update(in ProxyDTO p)
    {
        return remapExceptions!(delegate() 
        { 
            const Proxy updated = m_model.updateProxy(new Proxy(p.id, p.hostAddress, p.description, p.builtIn));
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
}

@safe CategoryDTO toDTO(in Category c) {
    return CategoryDTO(c.id(), c.name());
}

@safe ProxyDTO toDTO(in Proxy p) {
    return ProxyDTO(p.id(), p.hostAddress(), p.description(), p.builtIn());
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

