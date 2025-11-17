module web.pachandler;

import std.file;

import vibe.core.path : GenericPath, InetPathFormat, NativePath, relativeTo;
import vibe.http.fileserver : HTTPFileServerSettings, sendFile;
import vibe.http.server;

import model.pacmanager;

class PACHandler
{
    this(PACManager manager, string baseURL)
    {
        m_manager = manager;
        m_prefix = GenericPath!(InetPathFormat)(baseURL);

        m_settings = new HTTPFileServerSettings();
        m_settings.preWriteCallback =
            (scope HTTPServerRequest req, scope HTTPServerResponse res, ref string physicalPath) {
            res.contentType = "application/x-ns-proxy-autoconfig";
        };
    }

    @safe void handlePACRequest(HTTPServerRequest request, HTTPServerResponse response)
    {
        auto path = request.requestPath;
        if (!path.startsWith(m_prefix))
        {
            // should not happen here, but...
            throw new HTTPStatusException(404, "invalid PAC URL");
        }

        auto fileToServe = m_manager.getPACfilePath(path.relativeTo(m_prefix).toString());
        if (!exists(fileToServe))
        {
            throw new HTTPStatusException(500, "internal error: file not exists");
        }

        sendFile(request, response, NativePath(fileToServe), m_settings);
    }

private:
    PACManager m_manager;
    GenericPath!(InetPathFormat) m_prefix;
    HTTPFileServerSettings m_settings;
}
