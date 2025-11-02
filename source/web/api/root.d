module web.api.root;

import vibe.web.rest;
import vibe.http.server;

import  web.api.category : CategoryAPI;
import  web.api.proxy : ProxyAPI;
import  web.api.hostrule : HostRuleAPI;
import  web.api.proxyrules : ProxyRulesAPI;

@path("/api/")
interface APIRoot
{
    @path("category/") 
    @property CategoryAPI categories();
    
    @path("proxy/") 
    @property ProxyAPI proxies();

    @path("hostrule/") 
    @property HostRuleAPI hostRules();

    @path("proxyrules/") 
    @property ProxyRulesAPI proxyRules();
}
