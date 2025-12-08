module web.auth.provider;

import std.algorithm.comparison : equal;
import std.algorithm.searching : startsWith;
import std.array : split;
import std.datetime.systime : Clock, SysTime;
import std.datetime.timezone : UTC;
import std.digest.sha : sha256Of;
import std.exception : enforce;
import std.stdio : File;
import std.string : chomp, chompPrefix, indexOf, strip;

import vibe.http.common : HTTPStatusException;
import vibe.http.status : HTTPStatus;

import stringbuffer : StringBuffer;
import fastjwt.jwt : decodeJWTToken, encodeJWTToken, JWTAlgorithm;

import web.auth.errors;

struct AuthInfo
{
@safe:
    string userName;
    bool isReader;
    bool isWriter;
}

class AuthProvider
{
    this(in string usersFile, bool noAuth, in string secret)
    {
        m_noAuth = noAuth;
        m_secret = secret;

        File file = File(usersFile);
        scope (exit)
            file.close();

        string[] lines;
        foreach (line; file.byLine())
        {
            lines ~= line.chomp().strip().idup;
        }
        parseUsers(lines, m_users);
    }

    AuthInfo authenticate(in string[] authValues) @safe
    {
        if (m_noAuth)
        {
            return AuthInfo("anybody", true, true);
        }

        JWTPayload payload = getValidPayload(authValues);
        auto userInfo = payload.userName in m_users;
        if (userInfo == null)
        {
            throw new HTTPStatusException(HTTPStatus.forbidden, "user not found");
        }

        AuthInfo ai = {
            userName: userInfo.userName,
            isReader: userInfo.isReader,
            isWriter: userInfo.isWriter
        };
        return ai;
    }

    string login(in string user, in string password) @safe
    {
        auto userInfo = user in m_users;
        if (userInfo == null)
        {
            throw new HTTPStatusException(HTTPStatus.forbidden, "user/password invalid");
        }

        const(ubyte[]) passwordHash = sha256Of(password).dup;
        if (!equal(userInfo.passwordHash, passwordHash))
        {
            throw new HTTPStatusException(HTTPStatus.forbidden, "user/password invalid");
        }

        JWTPayload payload = {
            userName: userInfo.userName,
            createdAt: Clock.currTime(UTC())
        };
        return createToken(m_secret, JWTAlgorithm.HS512, payload);
    }

private:
    static void parseUsers(in string[] lines, scope ref UserInfo[string] users)
    {
        foreach (line; lines)
        {
            auto userInfo = parseUserLine(line);
            if (userInfo.userName in users)
            {
                throw new Exception("duplicated user name " ~ userInfo.userName);
            }

            users[userInfo.userName] = userInfo;
        }
    }

    unittest
    {
        UserInfo[string] users;
        auto lines = [
            "user1:a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b27796d9ad9f14:rw",
            "user2:a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b27796d9ad9f14:r"
        ];

        parseUsers(lines, users);

        assert(users.length == 2);
        assert("user1" in users);
        assert("user2" in users);
    }

    static struct UserInfo
    {
        string userName;
        ubyte[] passwordHash;
        bool isReader;
        bool isWriter;
    }

    static UserInfo parseUserLine(in string line) @safe
    {
        const(string[]) parts = line.split(":");
        enforce!bool(parts.length == 3,
            new Exception(
                "invalid line in users file (must be in form \"name:hash:roles\"), line: " ~ line)
        );

        auto name = parts[0].strip();
        enforce!bool(name.length != 0,
            new Exception("invalid line in users file: empty user name, line: " ~ line)
        );

        auto hashStr = parts[1].strip();
        enforce!bool(hashStr.length != 0,
            new Exception("invalid line in users file: empty hash, line: " ~ line)
        );

        auto roles = parts[2].strip();
        enforce!bool(roles.length <= 2,
            new Exception("invalid line in users file: roles invalid, line: " ~ line)
        );
        enforce!bool(roles.length == 0 || (roles.indexOf("r") != -1 || roles.indexOf("w") != -1),
            new Exception(
                "invalid line in users file: roles invalid (must be { (empty) | r | w | rw | wr }), line: " ~ line)
        );

        bool isWriter = roles.indexOf("w") != -1;
        bool isReader = isWriter || roles.indexOf("r") != -1;

        UserInfo ui = {
            userName: name,
            passwordHash: hexStringToByteArray(hashStr),
            isReader: isReader,
            isWriter: isWriter
        };

        return ui;
    }

    unittest
    {
        auto userInfoRW = parseUserLine(
            "user:a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b27796d9ad9f14:rw");
        assert(userInfoRW.userName == "user");
        assert(equal(
                userInfoRW.passwordHash,
                hexStringToByteArray("a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b27796d9ad9f14"))
        );
        assert(userInfoRW.isReader);
        assert(userInfoRW.isWriter);

        auto userInfoR = parseUserLine(
            "user:a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b27796d9ad9f14:r");
        assert(userInfoR.userName == "user");
        assert(equal(
                userInfoR.passwordHash,
                hexStringToByteArray("a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b27796d9ad9f14"))
        );
        assert(userInfoR.isReader);
        assert(!userInfoR.isWriter);
    }

    static struct JWTPayload
    {
        string userName;
        SysTime createdAt;
    }

    static string createToken(in string secret, in JWTAlgorithm algo, in JWTPayload payload) @trusted
    {
        StringBuffer buf;
        encodeJWTToken(buf, algo, secret,
            "userName", payload.userName,
            "createdAt", payload.createdAt.toUTC().toUnixTime());

        return buf.getData().dup;
    }

    unittest
    {
        auto secret = "aaa";
        auto algo = JWTAlgorithm.HS256;

        JWTPayload payload = {userName: "user", createdAt: Clock.currTime(UTC())};
        auto token = createToken(secret, algo, payload);
        auto decodedPayload = decodeToken(token, secret, algo);

        assert(payload.userName == decodedPayload.userName);
        assert(payload.createdAt.toUnixTime() == decodedPayload.createdAt.toUnixTime()); // we save UnixTime not full time
    }

    JWTPayload getValidPayload(in string[] authValues) @safe
    {
        const auto bearer = "Bearer ";
        foreach (authValue; authValues)
        {
            if (!authValue.startsWith(bearer))
            {
                continue;
            }
            auto token = authValue.chompPrefix(bearer);

            try
            {
                return decodeToken(token, m_secret, JWTAlgorithm.HS512);
            }
            catch (JWTError e)
            {
                continue;
            }
        }

        throw new HTTPStatusException(HTTPStatus.forbidden, "no valid authorization header found");
    }

    static JWTPayload decodeToken(in string token, in string secret, in JWTAlgorithm algo) @trusted
    {
        import std.conv : ConvException;
        import std.json : parseJSON, JSONValue, JSONException;

        StringBuffer headerBuf;
        StringBuffer payloadBuf;

        if (decodeJWTToken(token, secret, algo, headerBuf, payloadBuf) != 0)
        {
            throw new JWTError("invalid token");
        }

        JWTPayload decodedPayload;
        try
        {
            JSONValue jsonData = parseJSON(payloadBuf.getData());
            decodedPayload.userName = jsonData.object["userName"].str.dup;
            decodedPayload.createdAt = SysTime.fromUnixTime(jsonData.object["createdAt"].integer, UTC());
        }
        catch (JSONException e)
        {
            throw new JWTError("malformed payload JSON");
        }
        catch (ConvException e)
        {
            throw new JWTError("invalid value in payload JSON");
        }

        return decodedPayload;
    }

    bool m_noAuth;
    UserInfo[string] m_users;
    string m_secret;
}

private ubyte[] hexStringToByteArray(in string hexString) @safe
{
    import std.algorithm.iteration : map;
    import std.array : array;
    import std.conv : to;
    import std.range : chunks;

    if (hexString.length % 2 != 0)
    {
        throw new Exception("Hex string must have an even length");
    }

    return hexString.chunks(2)
        .map!(digits => digits.to!ubyte(16))
        .array;
}
