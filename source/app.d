import std.stdio;

import vibe.core.args : finalizeCommandLineOptions, printCommandLineHelp, readOption;
import vibe.vibe;
import vibe.http.server;

import datalayer.storage;
import model.model;
import options;
import web.api.root : APIRoot;
import web.service;

int main(string[] args)
{
	string configPath = "pacwebadmin.conf";
	readOption("config", &configPath, "Path to the configuration file.");

	Options options;
	try
	{
		options = getOptions(configPath);
	}
	catch (Exception e)
	{
		writeln("Invalid argumens: ", e.message());
		printCommandLineHelp();
		return -1;
	}
	finalizeCommandLineOptions();

	Storage storage = new Storage();
	Model m = new Model(storage);
	Service svc = new Service(m);

	auto restSettings = new RestInterfaceSettings;
	restSettings.baseURL = URL(options.baseURL);

	auto router = new URLRouter;
	registerRestInterface(router, svc, restSettings);
	router.get("/myapi.js", serveRestJSClient!APIRoot(restSettings));

	auto settings = new HTTPServerSettings;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.port = 8080;
	// settings.sessionStore = new MemorySessionStore;
	// settings.errorHandler = (HTTPServerRequest req, HTTPServerResponse res, RestErrorInformation error) @safe {
	// 		res.writeJsonBody([
	// 			"error": serializeToJson([
	// 				"status": Json(cast(int)error.statusCode),
	// 				"message": Json(error.exception.msg),
	// 			])
	// 		]);
	// 	};

	auto listener = listenHTTP(settings, router);
	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication(&args);

	return 0;
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody("Hello, World!");
}

