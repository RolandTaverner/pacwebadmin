module datalayer.storage;

import std.json;

import datalayer.category;
import datalayer.hostrule;
import datalayer.pac;
import datalayer.proxy;
import datalayer.proxyrules;
import datalayer.repository : ISerializable;

class Storage : ISerializable {
public:
    this() {
        m_categories = new CategoryRepository();
        m_hostRules = new HostRuleRepository();
        m_pacs = new PACRepository();
        m_proxies = new ProxyRepository();
        m_proxyRules = new ProxyRulesRepository();
    }

    JSONValue toJSON() const {
        return JSONValue([
            "category": m_categories.toJSON(),
            "hostrule": m_hostRules.toJSON(),
            "pac": m_pacs.toJSON(),
            "proxy": m_proxies.toJSON(),
            "proxyrule": m_proxyRules.toJSON(),
            ]);
    }
    
    void fromJSON(in JSONValue v) {
        m_categories.fromJSON(v.object["category"]);
        m_hostRules.fromJSON(v.object["hostrule"]);
        m_pacs.fromJSON(v.object["pac"]);
        m_proxies.fromJSON(v.object["proxy"]);
        m_proxyRules.fromJSON(v.object["proxyrule"]);
    }

    inout (CategoryRepository) categories() inout {
        return m_categories;
    }

    inout(HostRuleRepository) hostRules() inout{
        return m_hostRules;
    }

    inout(PACRepository) pacs() inout {
        return m_pacs;
    }

    inout(ProxyRepository) proxies() inout {
        return m_proxies;
    }

    inout(ProxyRulesRepository) proxyRules() inout {
        return m_proxyRules;
    }

private:
    CategoryRepository m_categories;
    HostRuleRepository m_hostRules;
    PACRepository m_pacs;
    ProxyRepository m_proxies;
    ProxyRulesRepository m_proxyRules;
}
