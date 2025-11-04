import std.stdio;
import std.path;
import std.file;
import std.json : parseJSON, JSONValue;

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

	auto dataFilePath = buildPath(options.dataDir, "data.local");
	string dataFileContent = readText(dataFilePath);
	JSONValue jsonData = parseJSON(dataFileContent);

	Storage storage = new Storage(new SimpleSaver(options.dataDir));
	storage.load(jsonData);

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

class SimpleSaver : IStorageSaver
{
	this(string dataDir)
	{
		m_dataDir = dataDir;
	}

    @trusted override void save(ref const JSONValue v)
	{
		synchronized(this)
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
