import std.stdio : File, writeln;
import std.path : buildPath;
import std.file : exists, readText, remove, rename;
import std.json : parseJSON, JSONValue;

import vibe.core.args : finalizeCommandLineOptions, printCommandLineHelp, readOption;
import vibe.vibe;
import vibe.http.fileserver : serveStaticFiles, HTTPFileServerSettings ;
import vibe.http.server;

import datalayer.storage;
import model.model;
import model.pacmanager;

import options;
import web.api.root : APIRoot;
import web.pachandler;
import web.service;

int main(string[] args)
{
	string configPath = "pacwebadmin.conf";
	readOption("config", &configPath, "Path to the configuration file.");

	Options options;
	try
	{
		options = getOptions(configPath);
		validateOptions(options);
	}
	catch (Exception e)
	{
		writeln("Invalid argumens: ", e.message());
		printCommandLineHelp();
		return -1;
	}
	finalizeCommandLineOptions();

	auto dataFilePath = buildPath(options.dataDir, "data.json");
	string dataFileContent = readText(dataFilePath);
	JSONValue jsonData = parseJSON(dataFileContent);

	Storage storage = new Storage(new SimpleSaver(options.dataDir));
	storage.load(jsonData);

	Model model = new Model(storage);
	PACManager pacManager = new PACManager(model, options.dataDir);

	Service restService = new Service(model);
	PACHandler pacHandler = new PACHandler(pacManager, options.servePath);

	auto restSettings = new RestInterfaceSettings;
	restSettings.baseURL = URL(options.baseURL);
	restSettings.allowedOrigins = [
		"*", "localhost:5173", "127.0.0.1:5173", "http://localhost:5173"
	];

	auto router = new URLRouter;
	registerRestInterface(router, restService, restSettings);
	router.get("/myapi.js", serveRestJSClient!APIRoot(restSettings));

	router.match(HTTPMethod.GET, options.servePath ~ "*",
		(HTTPServerRequest req, HTTPServerResponse res) @safe {
		pacHandler.handlePACRequest(req, res);
	});

	if (!options.wwwDir.empty)
	{
		auto fsSettings = new HTTPFileServerSettings();
		fsSettings.serverPathPrefix = "/assets/";

		router.get("/index.html", serveStaticFiles(options.wwwDir));
		router.get("/vite.svg", serveStaticFiles(options.wwwDir));
		router.get("/assets/*", serveStaticFiles(buildPath(options.wwwDir, "assets"), fsSettings));
	}

	auto settings = new HTTPServerSettings;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.port = 8080;
	settings.accessLogToConsole = true;

	if (options.logDir.length != 0) {
		settings.accessLogFile = buildPath(options.logDir, "access.log");
	}

	auto listener = listenHTTP(settings, router);
	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication(&args);

	return 0;
}

class SimpleSaver : IStorageSaver
{
	this(string dataDir)
	{
		m_dataDir = dataDir;
	}

	@trusted override void save(ref const JSONValue v)
	{
		synchronized (this)
		{
			auto backupFilePath = buildPath(m_dataDir, "data.local.bak");
			if (exists(backupFilePath))
			{
				remove(backupFilePath);
			}
			auto dataFilePath = buildPath(m_dataDir, "data.local");

			if (exists(dataFilePath))
			{
				rename(dataFilePath, backupFilePath);
			}

			File file = File(dataFilePath, "w");
			file.write(v.toPrettyString());
			file.close();
		}
	}

private:
	string m_dataDir;
}
