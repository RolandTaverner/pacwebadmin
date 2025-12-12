module web.services.user;

import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;

import vibe.web.auth;
import vibe.web.common : noRoute;

import model.model;
import model.entities.category;
import web.api.user : LoginResponse, ProfileResponse, UserAPI;

import web.services.common.auth;

class UserService : UserAPI
{
    this(AuthProvider authProvider)
    {
        m_authProvider = authProvider;
    }

    @safe override LoginResponse login(in string user, in string password)
    {
        auto token = m_authProvider.login(user, password);
        LoginResponse response = {token: token};
        return response;
    }

    @safe override void logout()
    {
        // TODO: invalidate token
    }

    @safe override ProfileResponse profile(in string authorization)
    {
        auto authInfo = m_authProvider.authenticate([authorization]);
        ProfileResponse response = {userName: authInfo.userName};
        return response;
    }

    mixin authMethodImpl;
}
