module web.auth.errors;

import std.exception : basicExceptionCtors;

class AuthError : Exception
{
    mixin basicExceptionCtors;
}

class JWTError : AuthError
{
    mixin basicExceptionCtors;
}
