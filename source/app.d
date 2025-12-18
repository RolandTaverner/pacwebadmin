import std.stdio : File, writeln;
import std.path : buildPath;
import std.file : exists, readText, remove, rename;
import std.json : parseJSON, JSONValue;

import vibe.core.args : finalizeCommandLineOptions, printCommandLineHelp, readOption;
import vibe.vibe;
import vibe.http.fileserver : serveStaticFiles, HTTPFileServerSettings;
import vibe.http.server;

import datalayer.storage;

import model.model;
import model.pacmanager;

import web.auth.provider : AuthProvider;
import web.api.root : APIRoot;
import web.pachandler;
import web.service;

import options;

enum PACPreviewPath = "/api/pac/preview/";

int main(string[] args)
{
	string configPath = "pacwebadmin.conf";
	readOption("config", &configPath, "Path to the configuration file.");

	Options opts;
	try
	{
		opts = getOptions(configPath);
		validateOptions(opts);
	}
	catch (Exception e)
	{
		writeln("Invalid argumens: ", e.message());
		printCommandLineHelp();
		return -1;
	}
	finalizeCommandLineOptions();

	auto dataFilePath = buildPath(opts.dataDir, "data.json");
	string dataFileContent = readText(dataFilePath);
	JSONValue jsonData = parseJSON(dataFileContent);

	Storage storage = new Storage(new SimpleSaver(opts.dataDir));
	storage.load(jsonData);

	Model model = new Model(storage);
	PACManager pacManager = new PACManager(model, opts.serveCacheDir);

	AuthProvider authProvider = new AuthProvider(opts.authUsersFile, !opts.authEnable, "aaa");

	Service restService = new Service(model, authProvider);
	PACHandler pacHandler = new PACHandler(model, pacManager, authProvider, opts.servePath, PACPreviewPath);

	auto restSettings = new RestInterfaceSettings;
	//restSettings.baseURL = URL(opts.baseURL);
	//restSettings.allowedOrigins = ["*"];

	auto router = new URLRouter;
	registerRestInterface(router, restService, restSettings);
	//router.get("/myapi.js", serveRestJSClient!APIRoot(restSettings));

	// PAC serve
	router.match(HTTPMethod.GET, opts.servePath ~ "*",
		(HTTPServerRequest req, HTTPServerResponse res) @safe {
		pacHandler.handlePACRequest(req, res);
	});

	// PAC preview
	router.match(HTTPMethod.GET, PACPreviewPath ~ "*",
		(HTTPServerRequest req, HTTPServerResponse res) @safe {
		pacHandler.handlePACPreviewRequest(req, res);
	});

	// OPTIONS handler for PAC preview
	router.match(HTTPMethod.OPTIONS, PACPreviewPath ~ "*",
		(HTTPServerRequest req, HTTPServerResponse res) @safe {
		res.headers["Access-Control-Allow-Methods"] = "OPTIONS, GET";

		if ("Origin" in req.headers)
		{
			res.headers["Access-Control-Allow-Origin"] = req.headers["Origin"];
		}
		res.headers["Access-Control-Allow-Headers"] = "Authorization";

		res.writeVoidBody();
	});

	if (!opts.wwwDir.empty)
	{
		auto fsSettings = new HTTPFileServerSettings();
		fsSettings.serverPathPrefix = "/assets/";

		router.get("/index.html", serveStaticFiles(opts.wwwDir));
		router.get("/vite.svg", serveStaticFiles(opts.wwwDir));
		router.get("/assets/*", serveStaticFiles(buildPath(opts.wwwDir, "assets"), fsSettings));
		router.get("/", &rootHandler);
	}

	auto settings = new HTTPServerSettings;
	settings.bindAddresses = opts.bindAddresses;
	settings.port = opts.port != 0 ? opts.port : 8080;
	settings.useCompressionIfPossible = true;

	if (opts.privateKeyFile.length != 0)
	{
		settings.tlsContext = createTLSContext(TLSContextKind.server);
		settings.tlsContext.useCertificateChainFile(opts.certificateChainFile);
		settings.tlsContext.usePrivateKeyFile(opts.privateKeyFile);
	}

	settings.accessLogToConsole = opts.accessLogToConsole;
	if (opts.logDir.length != 0)
	{
		settings.accessLogFile = buildPath(opts.logDir, "access.log");
	}

	auto listener = listenHTTP(settings, router);
	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Please open " ~ (opts.privateKeyFile.length != 0 ? "https" : "http") ~ "://127.0.0.1:" ~ to!(
			string)(opts.port) ~ "/ in your browser.");
	runApplication(&args);

	return 0;
}

void rootHandler(HTTPServerRequest req, HTTPServerResponse res)
{
	res.redirect("/index.html");
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
			string backupFilePath = "";
			for (int i = 0; i < 10_000; ++i)
			{
				auto testFilePath = buildPath(m_dataDir, format("data.json.bak.%04d", i));
				if (!exists(testFilePath))
				{
					backupFilePath = testFilePath;
					break;
				}
			}
			if (backupFilePath.length == 0) // TODO: add backup rotation
			{
				backupFilePath = buildPath(m_dataDir, format("data.json.bak.%04d", 0));
			}
			if (exists(backupFilePath))
			{
				remove(backupFilePath);
			}
			auto dataFilePath = buildPath(m_dataDir, "data.json");

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
