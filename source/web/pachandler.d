module web.pachandler;

import vibe.core.path : GenericPath, InetPathFormat;
import vibe.http.server;

import model.pacmanager;

class PACHandler
{
    this(PACManager manager, string baseURL)
    {
        m_manager = manager;
        m_prefix = GenericPath!(InetPathFormat)(baseURL);
    }

    @safe void handlePACRequest(HTTPServerRequest request, HTTPServerResponse response)
    {
        if (!request.requestPath.startsWith(m_prefix))
        {
            // should not happen here, but...
            throw new HTTPStatusException(404, "invalid PAC URL");
        }

        import std.stdio;
        writeln("handlePACRequest(): " ~ request.requestPath.toString());

        // m_manager.getPACfile()
        response.writeBody("Hello, World!");
    }

private:
    PACManager m_manager;
    GenericPath!(InetPathFormat) m_prefix;
}
