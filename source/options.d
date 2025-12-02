module options;

import args : Arg, Optional, parseArgsConfigFile, parseConfigFile;

static struct Options
{
	@Arg("The interfaces on which the HTTP server is listening", Optional.yes) string[] bindAddresses;
	@Arg("The port on which the HTTP server is listening", Optional.yes) ushort port;
	@Arg("Path to data dir", Optional.no) string dataDir;
	@Arg("Path to directory where *.pac will be saved", Optional.yes) string saveDir;
	@Arg("Path where *.pac will be served", Optional.yes) string servePath;
	@Arg("Base URL for REST API", Optional.yes) string baseURL;
	@Arg("Path to log dir", Optional.yes) string logDir;
	@Arg("Path to frontend dir", Optional.yes) string wwwDir;
}

Options getOptions(in string filePath)
{
	Options options;
	auto data = parseArgsConfigFile(filePath);
	parseConfigFile(options, data);

	return options;
}

void validateOptions(in Options opts)
{
	// TODO
}