# PAC web admin

Web admin to manage and serve [Proxy Auto-Configuration (PAC) file(s)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file).

# Goal

Provide a simple and user-friendly tool for managing, generating, and serving PAC (Proxy Auto-Configuration) files without editing JavaScript PAC code manually.

It is suitable for small LANs, home networks with a dedicated server, or standalone machines.

# Current state

It basically works (see Roadmap).

# Roadmap

JWT-based authentication.

Advanced input validation at backend and frontend.

Polish UI.

Generated PAC file preview.

Install as Windows service.

# Key concepts

## Category

Just a human-readable label for Condition. For example: Work, Social, Thrash etc. Categories are only used for grouping/filtering conditions in the UI. They do not affect the generated PAC logic.

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

# Ubuntu/systemd

Build (locally or in docker and extract files).
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
- create config file at /etc/pacwebadmin.conf
- create systemd unit at /etc/systemd/system/pacwebadmin.service
- exec systemctl daemon-reload && systemctl enable pacwebadmin && systemctl start pacwebadmin

Everything except for executable and systemd unit will be chown'ed to `pacwebadmin:pacwebadmin`.
By default service will listen on port 5000. You can change port at `/etc/pacwebadmin.conf`.

# How to run

# Locally

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

# Uncomment if you have server key and certificate (this enables HTTPS)
# certificateChainFile = ".local/server.crt"
# privateKeyFile = ".local/server.key"
```

## Debug

Run at project root:
```bash
./debug/pacwebadmin --config ".local/pacwebadmin.conf"
```

## Release

Run at project root:
```bash
./release/pacwebadmin --config ".local/pacwebadmin.conf"
```

## Using dub

Run at project root:
```bash
dub run -- --config ".local/pacwebadmin.conf"
```

# Conditions

## Domain

- type = "host_domain_only"

Host equals to provided domain.

## Domain and subdomains

- type = "host_domain_subdomain"

Host equals to provided domain or is subdomain of provided domain.

## Subdomains only

- type = "host_subdomain_only"

Host is subdomain of provided domain.

## URL shell expression

- type = "url_shexp_match"

## URL regular expression

- type = "url_regexp_match"

# API

## Errors

In case of an error, the service returns the appropriate HTTP status code and a response similar to this:

```json
{
  "statusMessage": "error reason here"
}
```

## Categories API requests

`name` must be unique.

### Get all

```bash
curl http://127.0.0.1:8080/api/category/list
```

Response

```json
{
  "categories": [
    {
      "id": 1,
      "name": "fun"
    },
    {
      "id": 2,
      "name": "work"
    }
  ]
}
```

### Filter

```bash
curl -X POST http://127.0.0.1:8080/api/category/filter -H "Content-Type: application/json" -d '{"name": "or"}'
```

Response

```json
{
  "categories": [
    {
      "id": 2,
      "name": "work"
    },
    {
      "id": 3,
      "name": "new category name"
    }
  ]
}
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/category/list/1
```

Response

```json
{
  "id": 1,
  "name": "fun"
}
```

### Create

`name` must not be empty.

```bash
curl -X POST http://127.0.0.1:8080/api/category/list -H "Content-Type: application/json" -d '{"name": "category name"}'
```

Response

```json
{
  "id": 1,
  "name": "category name"
}
```

### Update

`name` must not be empty.

```bash
curl -X PUT http://127.0.0.1:8080/api/category/list/1 -H "Content-Type: application/json" -d '{"name": "new category name"}'
```

Response

```json
{
  "id": 1,
  "name": "new category name"
}
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/category/list/1
```

Response: HTTP 200 with empty body

## Proxies API requests

`type` must be one of
- DIRECT
- PROXY
- SOCKS
- SOCKS4
- SOCKS5
- HTTP
- HTTPS

`address` must not be empty except for `type` == DIRECT

### Get all

```bash
curl http://127.0.0.1:8080/api/proxy/list
```

Response

```json
{
  "proxies": [
    {
      "id": 1,
      "type": "HTTP",
      "address": "127.0.0.1:8080",
      "description": "local proxy"
    },
    {
      "id": 2,
      "type": "SOCKS",
      "address": "10.10.0.10:8080",
      "description": "dante"
    }
  ]
}
```

### Filter

```bash
curl -X POST http://127.0.0.1:8080/api/proxy/filter -H "Content-Type: application/json" -d '{"type": "HTT", "address": "127"}'
```

Response

```json
{
  "proxies": [
    {
      "id": 1,
      "type": "HTTP",
      "address": "127.0.0.1:8080",
      "description": "local proxy"
    }
  ]
}
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/proxy/list/1
```

Response

```json
{
  "id": 1,
  "type": "HTTP",
  "address": "127.0.0.1:8080",
  "description": "local proxy"
}
```

### Create

If `type` != DIRECT address must not be empty.

If `type` == DIRECT address must be empty.

```bash
curl -X POST http://127.0.0.1:8080/api/proxy/list -H "Content-Type: application/json" -d '{"type": "HTTP", "address": "127.0.0.1:1080", "description": "Proxy description"}'
```

Response

```json
{
  "id": 3,
  "type": "HTTP",
  "address": "127.0.0.1:1080",
  "description": "Proxy description"
}
```

### Update

If `type` != DIRECT provided or existing address must not be empty.

If any of `type`, `address` or `description` fields are not provided in request, corresponding values remain unchanged.

```bash
curl -X PUT http://127.0.0.1:8080/api/proxy/list/1 -H "Content-Type: application/json" -d '{"type": "HTTP", "address": "127.0.0.1:80", "description": "updated description"}'
```

Response

```json
{
  "id": 1,
  "type": "HTTP",
  "address": "127.0.0.1:80",
  "description": "updated description"
}
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/proxy/list/1
```

Response: HTTP 200 with empty body

## Conditions API requests

`type` must be one of
- host_domain_only
- host_domain_subdomain
- host_subdomain_only
- url_shexp_match
- url_regexp_match

`expression` must not be empty.

### Get all

```bash
curl http://127.0.0.1:8080/api/condition/list
```

Response

```json
{
  "conditions": [
    {
      "id": 1,
      "type": "host_domain_subdomain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "type": "host_domain_only",
      "expression": "memes.com",
      "category": {
        "id": 1,
        "name": "fun"
      }
    },
    {
      "id": 3,
      "type": "host_subdomain_only",
      "expression": "noexample.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    }
  ]
}
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/condition/1
```

Response

```json
{
  "id": 1,
  "type": "host_domain_subdomain",
  "expression": "google.com",
  "category": {
    "id": 2,
    "name": "work"
  }
}
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/condition/list -H "Content-Type: application/json" -d '{"type": "host_domain_only", "expression": "example.com", "categoryId": 1}'
```

Response

```json
{
  "id": 4,
  "type": "host_domain_only",
  "expression": "example.com",
  "category": {
    "id": 1,
    "name": "fun"
  }
}
```

### Update

If any of `type`, `expression` or `categoryId` fields are not provided in request, corresponding values remain unchanged.

```bash
 curl -X PUT http://127.0.0.1:8080/api/condition/list/1 -H "Content-Type: application/json" -d '{"type": "host_domain_subdomain", "expression": "example.com", "categoryId": 1}'
```

Response

```json
{
  "id": 1,
  "type": "host_domain_subdomain",
  "expression": "example.com",
  "category": {
    "id": 1,
    "name": "fun"
  }
}
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/condition/list/1
```

Response: HTTP 200 with empty body

## Proxy rules API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/proxyrule/list
```

Response

```json
{
  "proxyRules": [
    {
      "id": 1,
      "proxy": {
        "id": 1,
        "type": "HTTP",
        "address": "127.0.0.1:80",
        "description": "updated description"
      },
      "enabled": true,
      "name": "proxy group 1",
      "conditions": [
        {
          "id": 1,
          "type": "host_domain_subdomain",
          "expression": "google.com",
          "category": {
            "id": 2,
            "name": "work"
          }
        }
      ]
    }
  ]
}
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/proxyrule/list/1
```

Response

```json
{
  "id": 1,
  "proxy": {
    "id": 1,
    "type": "HTTP",
    "address": "127.0.0.1:80",
    "description": "updated description"
  },
  "enabled": true,
  "name": "proxy group 1",
  "conditions": [
    {
      "id": 1,
      "type": "host_domain_subdomain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    }
  ]
}
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/proxyrule/list -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "name": "proxy group 1", "conditionIds": [1,2]}'
```

Response

```json
{
  "id": 4,
  "proxy": {
    "id": 1,
    "type": "HTTP",
    "address": "127.0.0.1:80",
    "description": "updated description"
  },
  "enabled": true,
  "name": "proxy group 1",
  "conditions": [
    {
      "id": 1,
      "type": "host_domain_subdomain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "type": "host_domain_only",
      "expression": "example.com",
      "category": {
        "id": 1,
        "name": "fun"
      }
    }
  ]
}
```

### Update

If any of `proxyId`, `enabled`, `name` or `conditionIds` fields are not provided in request, corresponding values remain unchanged.

```bash
curl -X PUT http://127.0.0.1:8080/api/proxyrule/list/1 -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "name": "proxy group updated", "conditionIds": [2]}'
```

Response

```json
{
  "id": 1,
  "proxy": {
    "id": 1,
    "type": "HTTP",
    "address": "127.0.0.1:80",
    "description": "updated description"
  },
  "enabled": true,
  "name": "proxy group updated",
  "conditions": [
    {
      "id": 2,
      "type": "host_domain_only",
      "expression": "example.com",
      "category": {
        "id": 1,
        "name": "fun"
      }
    }
  ]
}
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/proxyrule/list/1
```

Response: HTTP 200 with empty body

### Get conditions linked to proxy rules

```bash
curl http://127.0.0.1:8080/api/proxyrule/list/1/conditions
```

Response

```json
{
  "conditions": [
    {
      "id": 1,
      "type": "host_domain_subdomain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "type": "host_domain_only",
      "expression": "example.com",
      "category": {
        "id": 1,
        "name": "fun"
      }
    }
  ]
}
```

### Add condition to proxy rules

```bash
curl -X POST http://127.0.0.1:8080/api/proxyrule/list/1/conditions/3
```

Returns updated conditions for proxy rules object.

```json
{
  "conditions": [
    {
      "id": 1,
      "type": "host_domain_subdomain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "type": "host_domain_only",
      "expression": "example.com",
      "category": {
        "id": 1,
        "name": "fun"
      }
    },
    {
      "id": 3,
      "type": "host_domain_only",
      "expression": "noexample.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    }
  ]
}
```

### Delete condition from proxy rules

```bash
curl -X DELETE http://127.0.0.1:8080/api/proxyrule/list/1/conditions/3
```

Response: HTTP 200 with empty body

## PAC API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/pac/list
```

Response

```json
{
  "pacs": [
    {
      "id": 1,
      "name": "pac 1",
      "description": "some PAC",
      "proxyRules": [
        {
          "proxyRule": {
            "id": 1,
            "proxy": {
              "id": 1,
              "type": "HTTP",
              "address": "127.0.0.1:8080",
              "description": "local proxy"
            },
            "enabled": true,
            "name": "some proxy group",
            "conditions": [
              {
                "id": 1,
                "type": "host_domain_only",
                "expression": "google.com",
                "category": {
                  "id": 2,
                  "name": "work"
                }
              },
              {
                "id": 2,
                "type": "host_domain_subdomain",
                "expression": "memes.com",
                "category": {
                  "id": 1,
                  "name": "fun"
                }
              }
            ]
          },
          "priority": 1
        }
      ],
      "serve": true,
      "servePath": "pac1.pac",
      "saveToFS": false,
      "saveToFSPath": "pac1.pac",
      "fallbackProxy": {
        "id": 4,
        "type": "DIRECT",
        "address": "",
        "description": "no proxy"
      }
    }
  ]
}
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/pac/list/1
```

Response

```json
{
  "id": 1,
  "name": "pac 1",
  "description": "some PAC",
  "proxyRules": [
    {
      "proxyRule": {
        "id": 1,
        "proxy": {
          "id": 1,
          "type": "HTTP",
          "address": "127.0.0.1:8080",
          "description": "local proxy"
        },
        "enabled": true,
        "name": "some proxy group",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain_only",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 2,
            "type": "host_domain_subdomain",
            "expression": "memes.com",
            "category": {
              "id": 1,
              "name": "fun"
            }
          }
        ]
      },
      "priority": 1
    }
  ],
  "serve": true,
  "servePath": "pac1.pac",
  "saveToFS": false,
  "saveToFSPath": "pac1.pac",
  "fallbackProxy": {
    "id": 4,
    "type": "DIRECT",
    "address": "",
    "description": "no proxy"
  }
}
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/pac/list -H "Content-Type: application/json" -d '{"name": "pac 2", "description": "PAC for something else", "proxyRules": [{"proxyRuleId": 1, "priority":1}], "fallbackProxyId": 3, "serve": true, "servePath": "pac2.pac", "saveToFS": true, "saveToFSPath": "pac2.pac"}'
```

Response

```json
{
  "id": 2,
  "name": "pac 2",
  "description": "PAC for something else",
  "proxyRules": [
    {
      "proxyRule": {
        "id": 1,
        "proxy": {
          "id": 1,
          "type": "HTTP",
          "address": "127.0.0.1:8080",
          "description": "local proxy"
        },
        "enabled": true,
        "name": "some proxy group",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain_only",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 2,
            "type": "host_domain_subdomain",
            "expression": "memes.com",
            "category": {
              "id": 1,
              "name": "fun"
            }
          }
        ]
      },
      "priority": 1
    }
  ],
  "serve": true,
  "servePath": "pac2.pac",
  "saveToFS": true,
  "saveToFSPath": "pac2.pac",
  "fallbackProxy": {
    "id": 3,
    "type": "PROXY",
    "address": "127.0.0.1:1080",
    "description": "Proxy description"
  }
}
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/pac/list/2 -H "Content-Type: application/json" -d '{"name": "pac 2 updated", "description": "PAC for something else updated", "proxyRules": [{"proxyRuleId": 2, "priority":1}], "fallbackProxyId": 2, "serve": false, "servePath": "pac2updated.pac", "saveToFS": false, "saveToFSPath": "pac2updated.pac"}'
```

Response

```json
{
  "id": 2,
  "name": "pac 2 updated",
  "description": "PAC for something else updated",
  "proxyRules": [
    {
      "proxyRule": {
        "id": 2,
        "proxy": {
          "id": 1,
          "type": "HTTP",
          "address": "127.0.0.1:8080",
          "description": "local proxy"
        },
        "enabled": true,
        "name": "proxy group 1",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain_only",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 3,
            "type": "host_subdomain_only",
            "expression": "ya.ru",
            "category": {
              "id": 2,
              "name": "work"
            }
          }
        ]
      },
      "priority": 1
    }
  ],
  "serve": false,
  "servePath": "pac2updated.pac",
  "saveToFS": false,
  "saveToFSPath": "pac2updated.pac",
  "fallbackProxy": {
    "id": 2,
    "type": "SOCKS",
    "address": "10.10.0.10:8080",
    "description": "dante"
  }
}
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/pac/list/2
```

Response: HTTP 200 with empty body

### Get proxy rules linked to PAC

```bash
curl http://127.0.0.1:8080/api/pac/list/1/proxyrules
```

Response

```json
{
  "proxyRules": [
    {
      "proxyRule": {
        "id": 1,
        "proxy": {
          "id": 1,
          "type": "HTTP",
          "address": "127.0.0.1:8080",
          "description": "local proxy"
        },
        "enabled": true,
        "name": "some proxy group",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain_only",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 2,
            "type": "host_domain_subdomain",
            "expression": "memes.com",
            "category": {
              "id": 1,
              "name": "fun"
            }
          }
        ]
      },
      "priority": 1
    }
  ]
}
```

### Add proxy rules to PAC

```bash
curl -X POST http://127.0.0.1:8080/api/pac/list/1/proxyrules/2?priority=2
```

Returns updated proxy rules for PAC object.

```json
{
  "proxyRules": [
    {
      "proxyRule": {
        "id": 1,
        "proxy": {
          "id": 1,
          "type": "HTTP",
          "address": "127.0.0.1:8080",
          "description": "local proxy"
        },
        "enabled": true,
        "name": "some proxy group",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain_only",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 2,
            "type": "host_domain_subdomain",
            "expression": "memes.com",
            "category": {
              "id": 1,
              "name": "fun"
            }
          }
        ]
      },
      "priority": 1
    },
    {
      "proxyRule": {
        "id": 2,
        "proxy": {
          "id": 1,
          "type": "HTTP",
          "address": "127.0.0.1:8080",
          "description": "local proxy"
        },
        "enabled": true,
        "name": "proxy group 1",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain_only",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 3,
            "type": "host_subdomain_only",
            "expression": "ya.ru",
            "category": {
              "id": 2,
              "name": "work"
            }
          }
        ]
      },
      "priority": 2
    }
  ]
}
```

### Set proxy rule priority in PAC


```bash
curl -X PATCH http://127.0.0.1:8080/api/pac/list/1/proxyrules/2?priority=10
```

Returns updated proxy rules for PAC object.

```json
{
  "proxyRules": [
    {
      "proxyRule": {
        "id": 1,
        "proxy": {
          "id": 1,
          "type": "HTTP",
          "address": "127.0.0.1:8080",
          "description": "local proxy"
        },
        "enabled": true,
        "name": "some proxy group",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain_only",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 2,
            "type": "host_domain_subdomain",
            "expression": "memes.com",
            "category": {
              "id": 1,
              "name": "fun"
            }
          }
        ]
      },
      "priority": 1
    },
    {
      "proxyRule": {
        "id": 2,
        "proxy": {
          "id": 1,
          "type": "HTTP",
          "address": "127.0.0.1:8080",
          "description": "local proxy"
        },
        "enabled": true,
        "name": "proxy group 1",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain_only",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 3,
            "type": "host_subdomain_only",
            "expression": "ya.ru",
            "category": {
              "id": 2,
              "name": "work"
            }
          }
        ]
      },
      "priority": 10
    }
  ]
}
```

### Delete proxy rules from PAC

```bash
curl -X DELETE http://127.0.0.1:8080/api/pac/list/1/proxyrules/2
```

Response: HTTP 200 with empty body
