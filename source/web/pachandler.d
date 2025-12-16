module web.pachandler;

import std.file;

import vibe.core.path : InetPath, relativeToWeb;
import vibe.http.fileserver : HTTPFileServerSettings, sendFile;
import vibe.http.server;

import model.model;
import model.pacmanager;
import web.auth.provider : AuthProvider;

class PACHandler
{
    this(Model model, PACManager manager, AuthProvider authProvider,
        in string basePACServeURL, in string basePACPreviewServeURL)
    {
        m_model = model;
        m_manager = manager;
        m_authProvider = authProvider;

        m_prefix = InetPath(basePACServeURL);
        m_previewPrefix = InetPath(basePACPreviewServeURL);

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
        auto servePath = path.relativeToWeb(m_prefix).toString();
        auto pac = m_model.pacByServePath(servePath);
        if (!pac.serve())
        {
            throw new HTTPStatusException(404, "not serving PAC " ~ servePath);
        }

        auto fileToServe = m_manager.getPACfilePath(servePath);
        if (!exists(fileToServe.toString()))
        {
            throw new HTTPStatusException(500, "internal error: file not exists");
        }

        sendFile(request, response, fileToServe, m_settings);
    }

    @safe void handlePACPreviewRequest(HTTPServerRequest request, HTTPServerResponse response)
    {
        m_authProvider.authenticate(request.headers.getAll("Authorization"));
        
        auto path = request.requestPath;
        if (!path.startsWith(m_previewPrefix))
        {
            // should not happen here, but...
            throw new HTTPStatusException(404, "invalid PAC preview URL");
        }
        auto servePath = path.relativeToWeb(m_previewPrefix).toString();
        auto pac = m_model.pacByServePath(servePath);

        auto fileToServe = m_manager.getPACfilePath(servePath);
        if (!exists(fileToServe.toString()))
        {
            throw new HTTPStatusException(500, "internal error: file not exists");
        }

        sendFile(request, response, fileToServe, m_settings);
    }

private:
    Model m_model;
    PACManager m_manager;
    AuthProvider m_authProvider;
    InetPath m_prefix;
    InetPath m_previewPrefix;
    HTTPFileServerSettings m_settings;
}
