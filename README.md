# PAC web admin (work in progress)
Web admin to manage proxy autoconfiguration (PAC) file

# Dev notes

```bash
dub run -- --config "pacwebadmin.conf.local"
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

`name` should not be empty.

### Get all

```bash
curl http://127.0.0.1:8080/api/category/all
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
curl http://127.0.0.1:8080/api/category/1
```

Response

```json
{
  "id": 1,
  "name": "fun"
}
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/category/create -H "Content-Type: application/json" -d '{"name": "category name"}'
```

Response

```json
{
  "id": 1,
  "name": "category name"
}
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/category/1/update -H "Content-Type: application/json" -d '{"name": "new category name"}'
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
curl -X DELETE http://127.0.0.1:8080/api/category/1
```

Response

```json
{
  "id": 1,
  "name": "category name"
}
```

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
curl http://127.0.0.1:8080/api/proxy/all
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
curl http://127.0.0.1:8080/api/proxy/1
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

```bash
curl -X POST http://127.0.0.1:8080/api/proxy/create -H "Content-Type: application/json" -d '{"type": "HTTP", "address": "127.0.0.1:1080", "description": "Proxy description"}'
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

```bash
curl -X PUT http://127.0.0.1:8080/api/proxy/1/update -H "Content-Type: application/json" -d '{"type": "HTTP", "address": "127.0.0.1:80", "description": "updated description"}'
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
curl -X DELETE http://127.0.0.1:8080/api/proxy/1
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
curl http://127.0.0.1:8080/api/condition/all
```

Response

```json
{
  "conditions": [
    {
      "id": 1,
      "type": "host_domain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "type": "host_domain",
      "expression": "memes.com",
      "category": {
        "id": 1,
        "name": "fun"
      }
    },
    {
      "id": 3,
      "type": "host_domain",
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
  "type": "host_domain",
  "expression": "google.com",
  "category": {
    "id": 2,
    "name": "work"
  }
}
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/condition/create -H "Content-Type: application/json" -d '{"type": "host_subdomain", "expression": "example.com", "categoryId": 1}'
```

Response

```json
{
  "id": 4,
  "type": "host_subdomain",
  "expression": "example.com",
  "category": {
    "id": 1,
    "name": "fun"
  }
}
```

### Update

```bash
 curl -X PUT http://127.0.0.1:8080/api/condition/1/update -H "Content-Type: application/json" -d '{"type": "host_subdomain", "expression": "example.com", "categoryId": 1}'
```

Response

```json
{
  "id": 1,
  "type": "host_subdomain",
  "expression": "example.com",
  "category": {
    "id": 1,
    "name": "fun"
  }
}
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/condition/1
```

Response

```json
{
  "id": 1,
  "type": "host_subdomain",
  "expression": "example.com",
  "category": {
    "id": 1,
    "name": "fun"
  }
}
```

## Proxy rules API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/proxyrule/all
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
          "type": "host_domain",
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
curl http://127.0.0.1:8080/api/proxyrule/1
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
      "type": "host_domain",
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
curl -X POST http://127.0.0.1:8080/api/proxyrule/create -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "name": "proxy group 1", "conditionIds": [1,2]}'
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
      "type": "host_domain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "type": "host_subdomain",
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

```bash
curl -X PUT http://127.0.0.1:8080/api/proxyrule/1/update -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "name": "proxy group updated", "conditionIds": [2]}'
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
      "type": "host_subdomain",
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
curl -X DELETE http://127.0.0.1:8080/api/proxyrule/1
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
      "type": "host_subdomain",
      "expression": "example.com",
      "category": {
        "id": 1,
        "name": "fun"
      }
    }
  ]
}
```

### Get conditions linked to proxy rules

```bash
curl http://127.0.0.1:8080/api/proxyrule/1/conditions
```

Response

```json
{
  "conditions": [
    {
      "id": 1,
      "type": "host_domain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "type": "host_subdomain",
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
curl -X POST http://127.0.0.1:8080/api/proxyrule/1/conditions/3
```

Returns updated conditions for proxy rules object.

```json
{
  "conditions": [
    {
      "id": 1,
      "type": "host_domain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "type": "host_subdomain",
      "expression": "example.com",
      "category": {
        "id": 1,
        "name": "fun"
      }
    },
    {
      "id": 3,
      "type": "host_domain",
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
curl -X DELETE http://127.0.0.1:8080/api/proxyrule/1/conditions/2
```

Returns updated conditions for proxy rules object.

```json
{
  "conditions": [
    {
      "id": 1,
      "type": "host_domain",
      "expression": "google.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 3,
      "type": "host_domain",
      "expression": "noexample.com",
      "category": {
        "id": 2,
        "name": "work"
      }
    }
  ]
}
```

## PAC API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/pac/all
```

Response

```json
{
  "pacs": [
    {
      "id": 1,
      "name": "pac 1",
      "description": "PAC for something",
      "proxyRules": [
        {
          "proxyRule": {
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
                "type": "host_subdomain",
                "expression": "example.com",
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
      "saveToFS": true,
      "saveToFSPath": "pac1.pac"
    }
  ]
}
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/pac/1
```

Response

```json
{
  "id": 1,
  "name": "pac 1",
  "description": "PAC for something",
  "proxyRules": [
    {
      "proxyRule": {
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
            "type": "host_subdomain",
            "expression": "example.com",
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
  "saveToFS": true,
  "saveToFSPath": "pac1.pac"
}
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/pac/create -H "Content-Type: application/json" -d '{"name": "pac 1", "description": "PAC for something", "proxyRules": [{"proxyRuleId": 1, "priority":1}], "serve": true, "servePath": "pac1.pac", "saveToFS": true, "saveToFSPath": "pac1.pac"}'
```

Response

```json
{
  "id": 1,
  "name": "pac 1",
  "description": "PAC for something",
  "proxyRules": [
    {
      "proxyRule": {
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
            "type": "host_subdomain",
            "expression": "example.com",
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
  "saveToFS": true,
  "saveToFSPath": "pac1.pac"
}
```

### Update

```bash
curl -X POST http://127.0.0.1:8080/api/pac/1/update -H "Content-Type: application/json" -d '{"name": "pac 1 updated", "description": "updated PAC 1 desc", "proxyRules": [{"proxyRuleId": 1, "priority":1}, {"proxyRuleId": 2, "priority":2}], "serve": false, "servePath": "updatedpac1.pac", "saveToFS": false, "saveToFSPath": "updatedpac1.pac"}'
```

Response

```json
{
  "id": 1,
  "name": "pac 1 updated",
  "description": "updated PAC 1 desc",
  "proxyRules": [
    {
      "proxyRule": {
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
            "type": "host_subdomain",
            "expression": "example.com",
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
          "address": "127.0.0.1:80",
          "description": "updated description"
        },
        "enabled": true,
        "name": "proxy group 1",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 3,
            "type": "host_domain",
            "expression": "noexample.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          }
        ]
      },
      "priority": 2
    }
  ],
  "serve": false,
  "servePath": "updatedpac1.pac",
  "saveToFS": false,
  "saveToFSPath": "updatedpac1.pac"
}
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/pac/1
```

Response

```json
{
  "id": 1,
  "name": "pac 1",
  "description": "PAC for something",
  "proxyRules": [
    {
      "proxyRule": {
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
            "type": "host_subdomain",
            "expression": "example.com",
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
  "saveToFS": true,
  "saveToFSPath": "pac1.pac"
}
```

### Get proxy rules linked to PAC

```bash
curl http://127.0.0.1:8080/api/pac/1/proxyrules
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
          "address": "127.0.0.1:80",
          "description": "updated description"
        },
        "enabled": true,
        "name": "proxy group updated",
        "conditions": [
          {
            "id": 2,
            "type": "host_subdomain",
            "expression": "example.com",
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
 curl -X POST http://127.0.0.1:8080/api/pac/1/proxyrules/2?priority=2
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
          "address": "127.0.0.1:80",
          "description": "updated description"
        },
        "enabled": true,
        "name": "proxy group updated",
        "conditions": [
          {
            "id": 2,
            "type": "host_subdomain",
            "expression": "example.com",
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
          "address": "127.0.0.1:80",
          "description": "updated description"
        },
        "enabled": true,
        "name": "proxy group 1",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 3,
            "type": "host_domain",
            "expression": "noexample.com",
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
curl -X PATCH http://127.0.0.1:8080/api/pac/1/proxyrules/2?priority=10
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
          "address": "127.0.0.1:80",
          "description": "updated description"
        },
        "enabled": true,
        "name": "proxy group updated",
        "conditions": [
          {
            "id": 2,
            "type": "host_subdomain",
            "expression": "example.com",
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
          "address": "127.0.0.1:80",
          "description": "updated description"
        },
        "enabled": true,
        "name": "proxy group 1",
        "conditions": [
          {
            "id": 1,
            "type": "host_domain",
            "expression": "google.com",
            "category": {
              "id": 2,
              "name": "work"
            }
          },
          {
            "id": 3,
            "type": "host_domain",
            "expression": "noexample.com",
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
curl -X DELETE http://127.0.0.1:8080/api/pac/1/proxyrules/2
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
          "address": "127.0.0.1:80",
          "description": "updated description"
        },
        "enabled": true,
        "name": "proxy group updated",
        "conditions": [
          {
            "id": 2,
            "type": "host_subdomain",
            "expression": "example.com",
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
