module web.api.root;

import vibe.web.rest;
import vibe.http.server;

import  web.api.category : CategoriesAPI;
import  web.api.proxy : ProxiesAPI;
import  web.api.hostrule : HostRulesAPI;


@path("/api/")
interface APIRoot
{
    @path("categories/") 
    @property CategoriesAPI categories();
    
    @path("proxies/") 
    @property ProxiesAPI proxies();

    @path("hostrules/") 
    @property HostRulesAPI hostRules();
}
