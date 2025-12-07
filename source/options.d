module options;

import args : Arg, Optional, parseArgsConfigFile, parseConfigFile;

static struct Options
{
	@Arg("The interfaces on which the HTTP server is listening", Optional.yes) string[] bindAddresses;
	@Arg("The port on which the HTTP server is listening", Optional.yes) ushort port;
	@Arg("Path to frontend dir", Optional.yes) string wwwDir;
	@Arg("Path to data dir", Optional.no) string dataDir;
	@Arg("Path to cached PACs dir", Optional.no) string serveCacheDir;
	@Arg("Path to directory where *.pac will be saved", Optional.yes) string saveDir;
	@Arg("Path where *.pac will be served", Optional.yes) string servePath;
	@Arg("Path to log dir", Optional.yes) string logDir;
	@Arg("Access log entries will be output to the console", Optional.yes) bool accessLogToConsole;
	@Arg("Path to server certificate chain file", Optional.yes) string certificateChainFile;
	@Arg("Path to private key file", Optional.yes) string privateKeyFile;
	@Arg("Path to trusted certificates for verifying peer certificates", Optional.yes) string trustedCertificateFile;
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