module web.api.root;

import vibe.web.rest;
import vibe.http.server;

import web.api.category : CategoryAPI;
import web.api.proxy : ProxyAPI;
import web.api.condition : ConditionAPI;
import web.api.proxyrule : ProxyRuleAPI;
import web.api.pac : PACAPI;
import web.api.user : UserAPI;

@path("/api/")
interface APIRoot
{
    @path("category/")
    @property CategoryAPI categories();

    @path("proxy/")
    @property ProxyAPI proxies();

    @path("condition/")
    @property ConditionAPI conditions();

    @path("proxyrule/")
    @property ProxyRuleAPI proxyRules();

    @path("pac/")
    @property PACAPI pacs();

    @path("user/")
    @property UserAPI user();
}
