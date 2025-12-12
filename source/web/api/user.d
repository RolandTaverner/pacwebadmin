module web.api.user;

import vibe.http.server;
import vibe.web.auth : requiresAuth, anyAuth, noAuth;
import vibe.web.rest;

import web.auth.common;

@requiresAuth!AuthInfo
interface UserAPI
{
@safe:
    @noAuth @method(HTTPMethod.POST) @path("/login")
    LoginResponse login(@viaQuery("user") in string _user, @viaQuery("password") in string _password);

    @anyAuth @method(HTTPMethod.POST) @path("/logout")
    void logout();

    @anyAuth @method(HTTPMethod.GET) @path("/profile")
    ProfileResponse profile(@viaHeader("Authorization") in string _authorization);

    mixin authInterfaceMethod;
}

struct LoginResponse
{
    string token;
}

struct ProfileResponse
{
    string userName;
}
