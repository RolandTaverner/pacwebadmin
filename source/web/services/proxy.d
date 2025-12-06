module web.services.proxy;

import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;

import vibe.web.auth;
import vibe.web.common : noRoute;

import model.model;
import model.entities.proxy;

import web.api.proxy;

import web.services.common.auth;
import web.services.common.exceptions;
import web.services.common.todto;

class ProxyService : ProxyAPI
{
    this(Model model, AuthProvider authProvider)
    {
        m_model = model;
        m_authProvider = authProvider;
    }

    @safe override ProxyList getAll()
    {
        ProxyList response =
        {
            m_model.getProxies()
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array
        };

        return response;
    }

    @safe override ProxyList filter(in ProxyFilterDTO f)
    {
        auto filter = ProxyFilter(f.type, f.address);
        ProxyList response =
        {
            m_model.filterProxies(filter)
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array
        };

        return response;
    }

    @safe override ProxyDTO create(in ProxyCreateDTO p)
    {
        return remapExceptions!(delegate() {
            const ProxyInput pi = {
                type: p.type, address: p.address, description: p.description,
            };
            const Proxy created = m_model.createProxy(pi);
            return toDTO(created);
        }, ProxyDTO);
    }

    @safe override ProxyDTO update(in long id, in ProxyUpdateDTO p)
    {
        return remapExceptions!(delegate() {
            const ProxyInput pi = {
                type: p.type, address: p.address, description: p.description
            };
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

    @safe override void remove(in long id)
    {
        return remapExceptions!(delegate() {
            m_model.deleteProxy(id);
        }, void);
    }

    mixin authMethodImpl;

    private:
        Model m_model;
    }
