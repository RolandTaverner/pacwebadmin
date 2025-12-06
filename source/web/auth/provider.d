module web.auth.provider;

struct AuthInfo
{
@safe:
    string userName;
}

class AuthProvider
{
    AuthInfo authenticate(in string[] authValues) @safe
    {
        import std.stdio;
        writeln("authValues: ", authValues);

        AuthInfo ai = {userName: "default"};
        return ai;
    }
}
