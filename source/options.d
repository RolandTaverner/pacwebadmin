module options;

import args : Arg, Optional, parseArgsConfigFile, parseConfigFile;

static struct Options
{
	@Arg("Path to data dir", Optional.no) string dataDir;
	@Arg("Path to directory where *.pac will be saved", Optional.yes) string saveDir;
	@Arg("Path where *.pac will be served", Optional.yes) string servePath;
	@Arg("Base URL for REST API", Optional.yes) string baseURL;
}

Options getOptions(in string filePath)
{
	Options options;
	auto data = parseArgsConfigFile(filePath);
	parseConfigFile(options, data);

	return options;
}
