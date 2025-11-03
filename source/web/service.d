module web.service;

import std.algorithm.comparison : cmp;
import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;
import std.conv;

import vibe.vibe;
import vibe.http.common;

import model.model;
import model.entities.category;
import model.entities.proxy;
import model.entities.hostrule;
import model.entities.proxyrules;
import model.entities.pac;
import model.errors.base : ConstraintError;

import web.api.root;
import web.api.category;
import web.api.proxy;
import web.api.hostrule;
import web.api.proxyrules;
import web.api.pac;

class Service : APIRoot
{
    this(Model model)
    {
        m_model = model;

        m_categorySvc = new CategoryService(m_model);
        m_proxySvc = new ProxyService(m_model);
        m_hostRuleSvc = new HostRuleService(m_model);
        m_proxyRulesSvc = new ProxyRulesService(m_model);
        m_pacSvc = new PACService(m_model);
    }

    override @property CategoryAPI categories()
    {
        return m_categorySvc;
    }

    override @property ProxyAPI proxies()
    {
        return m_proxySvc;
    }

    override @property HostRuleAPI hostRules()
    {
        return m_hostRuleSvc;
    }

    override @property ProxyRulesAPI proxyRules()
    {
        return m_proxyRulesSvc;
    }

    override @property PACAPI pacs()
    {
        return m_pacSvc;
    }

private:
    Model m_model;
    CategoryService m_categorySvc;
    ProxyService m_proxySvc;
    HostRuleService m_hostRuleSvc;
    ProxyRulesService m_proxyRulesSvc;
    PACService m_pacSvc;
}

class CategoryService : CategoryAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override CategoryList getAll()
    {
        CategoryList response =
        {
            m_model.getCategories()
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array //.sort!( (a, b) => cmp(a.name, b.name) < 0, SwapStrategy.stable ).array  // TODO: decide to order here or at web UI?
        
        };

        return response;
    }

    @safe override CategoryDTO create(in CategoryInputDTO c)
    {
        const CategoryInput ci = {name: c.name};
        const Category created = m_model.createCategory(ci);
        return toDTO(created);
    }

    @safe override CategoryDTO update(in long id, in CategoryInputDTO c)
    {
        return remapExceptions!(delegate() {
            const CategoryInput ci = {name: c.name};
            const Category updated = m_model.updateCategory(id, ci);
            return toDTO(updated);
        }, CategoryDTO);
    }

    @safe override CategoryDTO getById(in long id)
    {
        return remapExceptions!(delegate() {
            const Category got = m_model.categoryById(id);
            return toDTO(got);
        }, CategoryDTO);
    }

    @safe override CategoryDTO remove(in long id)
    {
        return remapExceptions!(delegate() {
            const Category removed = m_model.deleteCategory(id);
            return toDTO(removed);
        }, CategoryDTO);
    }

private:
    Model m_model;
}

class ProxyService : ProxyAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override ProxyList getAll()
    {
        ProxyList response =
        {
            m_model.getProxies()
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array};

            return response;
        }

        @safe override ProxyDTO create(in ProxyInputDTO p)
        {
            const ProxyInput pi = {
                hostAddress: p.hostAddress, description: p.description, builtIn: p.builtIn};
                const Proxy created = m_model.createProxy(pi);
                return toDTO(created);
            }

            @safe override ProxyDTO update(in long id, in ProxyInputDTO p)
            {
                return remapExceptions!(delegate() {
                    const ProxyInput pi = {
                        hostAddress: p.hostAddress, description: p.description, builtIn: p.builtIn};
                        const Proxy updated = m_model.updateProxy(id, pi);
                        return toDTO(updated);
                    }, ProxyDTO);
                }

                @safe override ProxyDTO getById(in long id)
                {
                    return remapExceptions!(delegate() {
                        const Proxy got = m_model.proxyById(id);
                        return toDTO(got);
                    }, ProxyDTO);
                }

                @safe override ProxyDTO remove(in long id)
                {
                    return remapExceptions!(delegate() {
                        const Proxy removed = m_model.deleteProxy(id);
                        return toDTO(removed);
                    }, ProxyDTO);
                }

            private:
                Model m_model;
            }

            class HostRuleService : HostRuleAPI
            {
                this(Model model)
                {
                    m_model = model;
                }

                @safe override HostRuleList getAll()
                {
                    HostRuleList response = {
                        m_model.getHostRules()
                            .map!(c => toDTO(c))
                            .array
                            .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                            .array
        };

        return response;
    }

    @safe override HostRuleDTO create(in HostRuleInputDTO p)
    {
        const HostRuleInput hri = {
            hostTemplate: p.hostTemplate, strict: p.strict, categoryId: p.categoryId
            };
            const HostRule created = m_model.createHostRule(hri);
            return toDTO(created);
        }

        @safe override HostRuleDTO update(in long id, in HostRuleInputDTO p)
        {
            return remapExceptions!(delegate() {
                const HostRuleInput hri = {
                    hostTemplate: p.hostTemplate, strict: p.strict, categoryId: p.categoryId
                    };
                    const HostRule updated = m_model.updateHostRule(id, hri);
                    return toDTO(updated);
                }, HostRuleDTO);
            }

            @safe override HostRuleDTO getById(in long id)
            {
                return remapExceptions!(delegate() {
                    const HostRule got = m_model.hostRuleById(id);
                    return toDTO(got);
                }, HostRuleDTO);
            }

            @safe override HostRuleDTO remove(in long id)
            {
                return remapExceptions!(delegate() {
                    const HostRule removed = m_model.deleteHostRule(id);
                    return toDTO(removed);
                }, HostRuleDTO);
            }

        private:
            Model m_model;
        }

        class ProxyRulesService : ProxyRulesAPI
        {
            this(Model model)
            {
                m_model = model;
            }

            @safe override ProxyRulesList getAll()
            {
                ProxyRulesList response =
                {
                    m_model.getProxyRules()
                        .map!(c => toDTO(c))
                        .array
                        .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                        .array};

                    return response;
                }

                @safe override ProxyRulesDTO create(in ProxyRulesInputDTO prs)
                {
                    const ProxyRulesInput prsi = {
                        proxyId: prs.proxyId, enabled: prs.enabled, name: prs.name.dup, hostRuleIds: prs
                            .hostRuleIds.dup};
                        const ProxyRules created = m_model.createProxyRules(prsi);
                        return toDTO(created);
                    }

                    @safe override ProxyRulesDTO update(in long id, in ProxyRulesInputDTO prs)
                    {
                        return remapExceptions!(delegate() {
                            const ProxyRulesInput prsi = {
                                proxyId: prs.proxyId, enabled: prs.enabled, name: prs.name.dup, hostRuleIds: prs
                                    .hostRuleIds.dup};
                                const ProxyRules updated = m_model.updateProxyRules(id, prsi);
                                return toDTO(updated);
                            }, ProxyRulesDTO);
                        }

                        @safe override ProxyRulesDTO getById(in long id)
                        {
                            return remapExceptions!(delegate() {
                                const ProxyRules got = m_model.proxyRulesById(id);
                                return toDTO(got);
                            }, ProxyRulesDTO);
                        }

                        @safe override ProxyRulesDTO remove(in long id)
                        {
                            return remapExceptions!(delegate() {
                                const ProxyRules removed = m_model.deleteProxyRules(id);
                                return toDTO(removed);
                            }, ProxyRulesDTO);
                        }

                        @safe override HostRuleList getHostRules(in long id)
                        {
                            return remapExceptions!(delegate() {
                                HostRuleList response = {
                                    array(m_model.proxyRulesById(id)
                                        .hostRules().map!(c => toDTO(c)))
                    };
                        return response;
                    }, HostRuleList);
                }

                @safe override HostRuleList addHostRule(in long id, in long hrid)
                {
                    return remapExceptions!(delegate() {
                        const auto updated = m_model.proxyRulesAddHostRule(id, hrid);
                        HostRuleList response = {
                            array(updated.map!(c => toDTO(c)))
        };
            return response;
        }, HostRuleList);
    }

    @safe override HostRuleList removeHostRule(in long id, in long hrid)
    {
        return remapExceptions!(delegate() {
            const auto updated = m_model.proxyRulesRemoveHostRule(id, hrid);
            HostRuleList response = {array(updated.map!(c => toDTO(c)))
                };
            return response;
        }, HostRuleList);
    }

private:
    Model m_model;
}

class PACService : PACAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override PACList getAll()
    {
        PACList response =
        {
            m_model.getPACs()
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array};

            return response;
        }

        @safe override PACDTO create(in PACInputDTO p)
        {
            const PACInput pi = {
                p.name.dup, p.description.dup, p.proxyRulesIds.dup,
                p.serve, p.servePath.dup, p.saveToFS, p.saveToFSPath.dup};

                const PAC created = m_model.createPAC(pi);
                return toDTO(created);
            }

            @safe override PACDTO update(in long id, in PACInputDTO p)
            {
                return remapExceptions!(delegate() {
                    const PACInput pi = {
                        p.name.dup, p.description.dup, p.proxyRulesIds.dup,
                        p.serve, p.servePath.dup, p.saveToFS, p.saveToFSPath.dup};

                        const PAC updated = m_model.updatePAC(id, pi);
                        return toDTO(updated);
                    }, PACDTO);
                }

                @safe override PACDTO getById(in long id)
                {
                    return remapExceptions!(delegate() {
                        const PAC got = m_model.pacById(id);
                        return toDTO(got);
                    }, PACDTO);
                }

                @safe override PACDTO remove(in long id)
                {
                    return remapExceptions!(delegate() {
                        const PAC removed = m_model.deletePAC(id);
                        return toDTO(removed);
                    }, PACDTO);
                }

                @safe override ProxyRulesList getProxyRules(in long id)
                {
                    return remapExceptions!(delegate() {
                        ProxyRulesList response = {
                            array(m_model.pacById(id).proxyRules().map!(p => toDTO(p)))
                };
                    return response;
                }, ProxyRulesList);
            }

            @safe override ProxyRulesList addProxyRules(in long id, in long prid)
            {
                return remapExceptions!(delegate() {
                    const auto updated = m_model.pacAddProxyRules(id, prid);
                    ProxyRulesList response = {
                        array(updated.map!(c => toDTO(c)))
                    };
                    return response;
                }, ProxyRulesList);
            }

            @safe override ProxyRulesList removeProxyRules(in long id, in long prid)
            {
                return remapExceptions!(delegate() {
                    const auto updated = m_model.pacRemoveProxyRules(id, prid);
                    ProxyRulesList response = {
                        array(updated.map!(c => toDTO(c)))
                            };
                        return response;
                    }, ProxyRulesList);
                }

            private:
                Model m_model;
            }

            T remapExceptions(alias fun, T)() @trusted
            {
                try
                {
                    return fun();
                }
                catch (CategoryNotFound e)
                {
                    throw new HTTPStatusException(404, e.getEntityType() ~ " id=" ~ to!string(
                            e.getEntityId()) ~ " not found");
                }
                catch (ProxyNotFound e)
                {
                    throw new HTTPStatusException(404, e.getEntityType() ~ " id=" ~ to!string(
                            e.getEntityId()) ~ " not found");
                }
                catch (HostRuleNotFound e)
                {
                    throw new HTTPStatusException(404, e.getEntityType() ~ " id=" ~ to!string(
                            e.getEntityId()) ~ " not found");
                }
                catch (ProxyRulesNotFound e)
                {
                    throw new HTTPStatusException(404, e.getEntityType() ~ " id=" ~ to!string(
                            e.getEntityId()) ~ " not found");
                }
                catch (PACNotFound e)
                {
                    throw new HTTPStatusException(404, e.getEntityType() ~ " id=" ~ to!string(
                            e.getEntityId()) ~ " not found");
                }
                catch (ConstraintError e)
                {
                    throw new HTTPStatusException(400, e.toString());
                }
            }

            @safe CategoryDTO toDTO(in Category c) pure
            {
                return CategoryDTO(c.id(), c.name());
            }

            @safe ProxyDTO toDTO(in Proxy p) pure
            {
                return ProxyDTO(p.id(), p.hostAddress(), p.description(), p.builtIn());
            }

            @safe HostRuleDTO toDTO(in HostRule hr) pure
            {
                return HostRuleDTO(hr.id(), hr.hostTemplate, hr.strict, toDTO(hr.category()));
            }

            @safe ProxyRulesDTO toDTO(in ProxyRules prs) pure
            {
                const auto hostRules = prs.hostRules()
                    .map!(hr => toDTO(hr))
                    .array
                    .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                    .array;

                return ProxyRulesDTO(prs.id(), toDTO(prs.proxy()), prs.enabled(), prs.name(), hostRules);
            }

            @safe PACDTO toDTO(in PAC p) pure
            {
                const auto proxyRules = p.proxyRules()
                    .map!(pr => toDTO(pr))
                    .array
                    .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                    .array;

                return PACDTO(p.id(), p.name(), p.description(), proxyRules,
                    p.serve(), p.servePath(), p.saveToFS(), p.saveToFSPath());
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
