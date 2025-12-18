# PAC web admin

Web admin to manage and serve [Proxy Auto-Configuration (PAC) file(s)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file).

# Goal

Provide a simple and user-friendly tool for managing, generating, and serving PAC (Proxy Auto-Configuration) files without editing JavaScript PAC code manually.

It is suitable for small LANs, home networks with a dedicated server, or standalone machines.

# Features

**Web-based interface** for managing PAC rules with an intuitive UI.

**Multiple PAC file support** - serve multiple PAC files, each generated from its own configuration.

**Generated PAC file preview** – allows inspection of the resulting PAC file.

**Shared proxy rules** across multiple PAC files for easier maintenance.

**Standalone service** - runs independently with no external web server required.

**JSON-based configuration** - stored as a simple JSON file that you can easily backup, version control, or edit manually.

**HTTP caching support** - efficient PAC file delivery with ETag and Last-Modified headers to minimize bandwidth and client-side updates.

**Automatic configuration backup** - protects against accidental data loss.

**HTTPS support (optional)** - secure delivery of PAC files when needed.

**Cross-platform** - runs on Linux, Windows, and macOS.

**Lightweight and fast** - minimal resource footprint suitable for small LANs, home networks, or standalone machines.

**JWT-based authentication (optional)** - kinda rudimentary at this moment, but.

# Current state

It basically works (see Roadmap).

# Roadmap

Advanced input validation at backend and frontend.

Polish UI.

Install as Windows service.

# Key concepts

## Category

Just a human-readable label for Condition. For example: Work, Social, Trash etc. Categories are only used for grouping/filtering conditions in the UI. They do not affect the generated PAC logic.

## Proxy

Represents a proxy in terms of [Proxy Auto-Configuration (PAC) file](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file). It has type and address (except for DIRECT).
Type can be one of
- DIRECT (proxy bypass)
- PROXY
- SOCKS
- SOCKS4
- SOCKS5
- HTTP
- HTTPS

In a PAC file, each proxy is represented as a string such as `"PROXY 192.168.0.1:8080"` or `"DIRECT"`.

## Condition

Represents a condition on `url` or `host` arguments of FindProxyForURL() function. Has type, expression and category.
A Condition defines when a Proxy Rule should apply.
If any condition in a rule matches, the rule is considered a match.

Type can be one of
- host_domain_only
- host_domain_subdomain
- host_subdomain_only
- url_shexp_match
- url_regexp_match

A condition defines when a proxy rule should apply. Conditions are evaluated against the `url` and `host` parameters passed to `FindProxyForURL()`.

### host_domain_only

Tests if lowercased `host` equals to expression (exact match).

If expression is `bar.com` then it translates to `(host_lc == "bar.com")`.

### host_domain_subdomain

Tests if lowercased `host` equals to expression or is a subdomain of a domain provided in expression.

If expression is `foo.com` then it translates to `/^(?:.*\.)?foo\.com$/.test(host_lc)`. So it will match `foo.com`, `www.foo.com`, `www.some.foo.com` etc.

### host_subdomain_only

Tests if lowercased `host` is a subdomain of a domain provided in expression.

If expression is `baz.com` then it translates to `/^.*\.baz\.com$/.test(host_lc)`. So it will match `www.baz.com`, `www.some.baz.com` etc but not `baz.com`.

### url_shexp_match

Tests `shExpMatch(url, expression)`.

If expression is `*goog*` then it translates to `shExpMatch(url, "*goog*")`.

### url_regexp_match

Test regular expression on `url`.
If expression is `^http:\/\/api.*` then it translates to `/^http:\/\/api.*/.test(url)`.

### Summary

| Type                  | Meaning             | Expression example          |
| --------------------- | ------------------- | --------------------------- |
| host_domain_only      | Exact domain        | `example.com`               |
| host_domain_subdomain | Domain + subdomains | `google.com`                |
| host_subdomain_only   | Subdomains only     | `service.local`             |
| url_shexp_match       | Shell wildcard      | `*api*`                     |
| url_regexp_match      | Full scale regexp   | `^https://.*\.internal/.*`  |

## Proxy rule

A proxy rule groups one or more conditions and assigns a proxy to them.
If **any** condition in the rule matches (logical OR), the associated proxy is returned.

## PAC

PAC defines the final FindProxyForURL() output.
Rules are evaluated in priority order. The first matching rule determines the proxy.
If no rule matches, the fallback proxy is returned (typically DIRECT).

It has the following properties:
- name (human-readable name)
- serve option (enables serving PAC)
- serve path
- save option (enables saving PAC file to disk)
- save path
- fallback proxy (a proxy returned if no conditions matched, usually DIRECT)
- list of proxy rules with priorities.

## Sample generated PAC file

```js
// sample
// some PAC

// Ban (invalid address)
var proxy2 = "PROXY 127.0.0.0:0";

// my proxy
var proxy3 = "HTTP 192.168.1.1:1080";

// Used as proxy if no rules matched
// No proxy
var proxy1 = "DIRECT";


// This function gets called every time a url is submitted
function FindProxyForURL(url, host) {
    var host_lc = host.toLowerCase();

    // ban
    if (/^(?:.*\.)?facebook\.com$/.test(host_lc)
        || /^(?:.*\.)?x\.com$/.test(host_lc)) return proxy2;

    // sample
    if ((host_lc == "bar.com")
        || /^(?:.*\.)?foo\.com$/.test(host_lc)
        || /^.*\.baz\.com$/.test(host_lc)
        || shExpMatch(url, "*goog*")
        || /^http:\/\/api.*/.test(url)) return proxy3;

    return proxy1;
}
```

# Tech details

Backend implemented in [D language](https://dlang.org/) with [vibe.d](https://vibed.org) as HTTP server.

Frontend implemented in [TypeScript](https://www.typescriptlang.org) using
- [Vite](https://vite.dev)
- [React](https://react.dev)
- [RTK Query](https://redux-toolkit.js.org/rtk-query/overview)
- [Material UI](https://mui.com/material-ui/)
- [Material React Table](https://www.material-react-table.com)

# How to build

## Docker (x86-64)

Docker image based on Ubuntu 24.04 and the latest version of [DMD](https://dlang.org/dmd-linux.html) compiler.

```bash
git clone https://github.com/RolandTaverner/pacwebadmin.git
cd pacwebadmin
docker build -t pacwebadmin .
docker run -p 5000:80 pacwebadmin
```

Open http://127.0.0.1:5000 in browser.

Also you can extract files from docker image using commands:
```bash
docker build -t pacwebadmin .
docker create --name pacwebadmin-ubuntu24 pacwebadmin
docker cp pacwebadmin-ubuntu24:/app /path/to/save/build/files
```

## Docker (AArch64)

Not supported yet. Need to create docker image with ldc or gdc compiler.

## Windows, Linux local build

Assuming dmd, dub, node and npm are installed and available in PATH.

```bash
git clone https://github.com/RolandTaverner/pacwebadmin.git
cd pacwebadmin
dub build --build=release
cd web-admin
npm install
npm run build
```

Output:
- `pacwebadmin/release/pacwebadmin[.exe]` - executable
- `pacwebadmin/web-admin/dist` - web stuff (index.html etc.)

## macOS local build

TODO

# How to install

## Ubuntu/systemd

You can build project using provided Dockerfile or manually.

### Build using Docker

Go to project root and run command

```bash
./install/ubuntu/create_install_from_docker.sh /tmp/pwa_dist
```

The following files will be created:

```
/tmp/pwa_dist
├── install
│   ├── dist
│   │   ├── assets
│   │   │   ├── index-7XOjUnRg.js
│   │   │   └── index-D4geO1r3.css
│   │   ├── index.html
│   │   └── vite.svg
│   ├── install.sh
│   ├── pacwebadmin
│   ├── remove.sh
│   └── update.sh
└── install.tar.gz
```

`install.tar.gz` contains archived `install` directory with its content. Copy `install.tar.gz` to target machine and unpack.

### Build locally

Copy files to target machine to some directory (for example, `install`) so directory structure will look like

```
./install/
├── dist                         // web stuff here
│   ├── assets
│   │   ├── index-D4geO1r3.css
│   │   └── index-DAonwM5C.js
│   ├── index.html
│   └── vite.svg
├── install.sh                   // install script here
└── pacwebadmin                  // executable here
```

### Install

Then execute commands

```bash
cd ./install
sudo ./install.sh
```

`install.sh` will do the following things:
- create user pacwebadmin (with group)
- copy pacwebadmin executable to /usr/bin/
- create directory structure at /var/lib/pacwebadmin
- create initial data file at /var/lib/pacwebadmin/data/data.json
- create log dir at /var/log/pacwebadmin
- create dir for www stuff at /var/www/pacwebadmin
- copy ./dist/* to /var/www/pacwebadmin
- create config file at /etc/pacwebadmin/pacwebadmin.conf
- create users file at /etc/pacwebadmin/users (admin (password admin) and user (password user))
- create systemd unit at /etc/systemd/system/pacwebadmin.service
- exec systemctl daemon-reload && systemctl enable pacwebadmin && systemctl start pacwebadmin

Everything except for executable and systemd unit will be chown'ed to `pacwebadmin:pacwebadmin`.
By default service will listen on port 5000. You can change port at `/etc/pacwebadmin/pacwebadmin.conf`.

# How to run

## Locally

Go to a project root.

Create directories
```bash
mkdir -p .local
mkdir -p .local/data
mkdir -p .local/log
mkdir -p .local/servecache
```

Create config file `.local/pacwebadmin.conf`:
```
bindAddresses = ::,0.0.0.0
port = 80
dataDir = ".local/data"
saveDir = ".local/save"
serveCacheDir = ".local/servecache"
servePath = "/pac/"
logDir = ".local/log"
wwwDir = "web-admin/dist"

# Uncomment if you want to see access log in console output
# accessLogToConsole = true

# Uncomment if you want to enable authorization
#authEnable = true
#authUsersFile = ".local/users"

# Uncomment if you have server key and certificate (this enables HTTPS)
# certificateChainFile = ".local/server.crt"
# privateKeyFile = ".local/server.key"
```

Create file `.local/users`: (if authEnable = true, user "admin", password "admin")
```
admin:8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918:rw
```

### Debug

Run at project root:
```bash
./debug/pacwebadmin --config ".local/pacwebadmin.conf"
```

### Release

Run at project root:
```bash
./release/pacwebadmin --config ".local/pacwebadmin.conf"
```

### Using dub

Run at project root:
```bash
dub run -- --config ".local/pacwebadmin.conf"
```

# Configuration

## Main configuration file

```
bindAddresses = ::,0.0.0.0
port = 80
dataDir = ".local/data"
saveDir = ".local/save"
serveCacheDir = ".local/servecache"
servePath = "/pac/"
logDir = ".local/log"
wwwDir = "web-admin/dist"
accessLogToConsole = false

# Auth options
authEnable = true
authUsersFile = ".local/users"

# HTTPS options
certificateChainFile = ".local/localhost.crt"
privateKeyFile = ".local/localhost.key"
# trustedCertificateFile = ""
```

If `authEnable = false` the UI will still show login dialog but any user/password will be accepted.

## Users configuration file

Each line describes user. Line consists of 3 parts divided by colon.

Format: `user:SHA256(password):access`
- user - user name
- password - password
- access - user access options, may be `r` - read, `w` - write and read, `rw` - write and read (now `rw` == `wr` == `w`).

For example, if you want to have user `admin` (password "admin") with `rw` access and `user` (password "user") with `r` access then `users` file should look like:

```
admin:8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918:rw
user:04f8996da763b7a969b1028ee3007569eaf3a635486ddab211d512c85b9df8fb:r
```

# Backend API description

See [BackendAPI.md](https://github.com/RolandTaverner/pacwebadmin/blob/master/BackendAPI.md)
