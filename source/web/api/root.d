module web.api.root;

import vibe.web.rest;
import vibe.http.server;

import  web.api.category : CategoriesAPI;
import  web.api.proxy : ProxiesAPI;


@path("/api/")
interface APIRoot
{
    @path("categories/") 
    @property CategoriesAPI categories();
    
    @path("proxies/") 
    @property ProxiesAPI proxies();
}
