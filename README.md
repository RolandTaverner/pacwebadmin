# PAC web admin (work in progress)
Web admin to manage proxy autoconfiguration (PAC) file

# Dev notes

```bash
dub run -- --config "pacwebadmin.conf.local"
```

## Categories API requests

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
      "hostAddress": "127.0.0.1:8080",
      "description": "some local proxy",
      "builtIn": false
    },
    {
      "id": 2,
      "hostAddress": "10.10.0.10:8080",
      "description": "another proxy",
      "builtIn": false
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
  "hostAddress": "127.0.0.1:8080",
  "description": "some local proxy",
  "builtIn": false
}
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/proxy/create -H "Content-Type: application/json" -d '{"hostAddress": "127.0.0.1:1080", "description": "Proxy description", "builtIn": false}'
```

Response

```json
{
  "id": 1,
  "hostAddress": "127.0.0.1:1080",
  "description": "Proxy description",
  "builtIn": false
}
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/proxy/1/update -H "Content-Type: application/json" -d '{"hostAddress": "127.0.0.1:80", "description": "updated description", "builtIn": false}'
```

Response

```json
{
  "id": 1,
  "hostAddress": "127.0.0.1:80",
  "description": "updated description",
  "builtIn": false
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
  "hostAddress": "127.0.0.1:1080",
  "description": "Proxy description",
  "builtIn": false
}
```

## Host rules API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/hostrule/all
```

Response

```json
{
  "hostRules": [
    {
      "id": 1,
      "hostTemplate": "example.com",
      "strict": true,
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "hostTemplate": "memes.com",
      "strict": false,
      "category": {
        "id": 1,
        "name": "fun"
      }
    }
  ]
}
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/hostrule/1
```

Response

```json
{
  "id": 1,
  "hostTemplate": "example.com",
  "strict": true,
  "category": {
    "id": 2,
    "name": "work"
  }
}
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/hostrule/create -H "Content-Type: application/json" -d '{"hostTemplate": "example.com", "strict": true, "categoryId": 1}'
```

Response

```json
{
  "id": 3,
  "hostTemplate": "example.com",
  "strict": true,
  "category": {
    "id": 1,
    "name": "fun"
  }
}
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/hostrule/1/update -H "Content-Type: application/json" -d '{"hostTemplate": "noexample.com", "strict": false, "categoryId": 2}'
```

Response

```json
{
  "id": 1,
  "hostTemplate": "noexample.com",
  "strict": false,
  "category": {
    "id": 2,
    "name": "work"
  }
}
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/hostrule/1
```

Response

```json
{
  "id": 1,
  "hostTemplate": "noexample.com",
  "strict": false,
  "category": {
    "id": 2,
    "name": "work"
  }
}
```

## Proxy rules API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/proxyrules/all
```

Response

```json
{
  "proxyRules": [
    {
      "id": 1,
      "proxy": {
        "id": 1,
        "hostAddress": "127.0.0.1:80",
        "description": "updated description",
        "builtIn": false
      },
      "enabled": true,
      "name": "proxy group 1",
      "hostRules": [
        {
          "id": 1,
          "hostTemplate": "google.com",
          "strict": true,
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
curl http://127.0.0.1:8080/api/proxyrules/1
```

Response

```json
{
  "id": 1,
  "proxy": {
    "id": 1,
    "hostAddress": "127.0.0.1:80",
    "description": "updated description",
    "builtIn": false
  },
  "enabled": true,
  "name": "proxy group 1",
  "hostRules": [
    {
      "id": 1,
      "hostTemplate": "google.com",
      "strict": true,
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
curl -X POST http://127.0.0.1:8080/api/proxyrules/create -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "name": "proxy group 1", "hostRuleIds": [1]}'
```

Response

```json
{
  "id": 1,
  "proxy": {
    "id": 1,
    "hostAddress": "127.0.0.1:8080",
    "description": "local proxy",
    "builtIn": false
  },
  "enabled": true,
  "name": "proxy group 1",
  "hostRules": [
    {
      "id": 1,
      "hostTemplate": "google.com",
      "strict": true,
      "category": {
        "id": 2,
        "name": "work"
      }
    }
  ]
}
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/proxyrules/1/update -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "name": "proxy group updated", "hostRuleIds": [2]}
```

Response

```json
{
  "id": 1,
  "proxy": {
    "id": 1,
    "hostAddress": "127.0.0.1:8080",
    "description": "local proxy",
    "builtIn": false
  },
  "enabled": true,
  "name": "proxy group updated",
  "hostRules": [
    {
      "id": 2,
      "hostTemplate": "memes.com",
      "strict": false,
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
curl -X DELETE http://127.0.0.1:8080/api/proxyrules/1
```

Response

```json
{
  "id": 3,
  "proxy": {
    "id": 1,
    "hostAddress": "127.0.0.1:8080",
    "description": "local proxy",
    "builtIn": false
  },
  "enabled": true,
  "name": "proxy group updated",
  "hostRules": [
    {
      "id": 2,
      "hostTemplate": "memes.com",
      "strict": false,
      "category": {
        "id": 1,
        "name": "fun"
      }
    }
  ]
}
```

### Get host rules linked to proxy rules

```bash
curl http://127.0.0.1:8080/api/proxyrules/1/hostrules
```

Response

```json
{
  "hostRules": [
    {
      "id": 1,
      "hostTemplate": "google.com",
      "strict": true,
      "category": {
        "id": 2,
        "name": "work"
      }
    }
  ]
}
```

### Add host rule to proxy rules

```bash
curl -X POST http://127.0.0.1:8080/api/proxyrules/1/hostrules/2
```

Returns updated host rules for proxy rules object.

```json
{
  "hostRules": [
    {
      "id": 1,
      "hostTemplate": "google.com",
      "strict": true,
      "category": {
        "id": 2,
        "name": "work"
      }
    },
    {
      "id": 2,
      "hostTemplate": "memes.com",
      "strict": false,
      "category": {
        "id": 1,
        "name": "fun"
      }
    }
  ]
}
```

### Delete host rule from proxy rules

```bash
curl -X DELETE http://127.0.0.1:8080/api/proxyrules/1/hostrules/2
```

Returns updated host rules for proxy rules object.

```json
{
  "hostRules": [
    {
      "id": 1,
      "hostTemplate": "google.com",
      "strict": true,
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
          "id": 1,
          "proxy": {
            "id": 1,
            "hostAddress": "127.0.0.1:8080",
            "description": "local proxy",
            "builtIn": false
          },
          "enabled": true,
          "name": "proxy group 1",
          "hostRules": [
            {
              "id": 1,
              "hostTemplate": "google.com",
              "strict": true,
              "category": {
                "id": 2,
                "name": "work"
              }
            }
          ]
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
      "id": 1,
      "proxy": {
        "id": 1,
        "hostAddress": "127.0.0.1:8080",
        "description": "local proxy",
        "builtIn": false
      },
      "enabled": true,
      "name": "proxy group 1",
      "hostRules": [
        {
          "id": 1,
          "hostTemplate": "google.com",
          "strict": true,
          "category": {
            "id": 2,
            "name": "work"
          }
        }
      ]
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
curl -X POST http://127.0.0.1:8080/api/pac/create -H "Content-Type: application/json" -d '{"name": "pac 1", "description": "PAC for something", "proxyRulesIds": [1], "serve": true, "servePath": "pac1.pac", "saveToFS": true, "saveToFSPath": "pac1.pac"}'`
```

Response

```json
{
  "id": 1,
  "name": "pac 1",
  "description": "PAC for something",
  "proxyRules": [
    {
      "id": 1,
      "proxy": {
        "id": 1,
        "hostAddress": "127.0.0.1:8080",
        "description": "local proxy",
        "builtIn": false
      },
      "enabled": true,
      "name": "proxy group 1",
      "hostRules": [
        {
          "id": 1,
          "hostTemplate": "google.com",
          "strict": true,
          "category": {
            "id": 2,
            "name": "work"
          }
        }
      ]
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
curl -X PUT http://127.0.0.1:8080/api/pac/1/update -H "Content-Type: application/json" -d '{"name": "updated pac 1", "description": "updated pac 1 desc", "proxyRulesIds": [2], "serve": false, "servePath": "updatedpac1.pac", "saveToFS": false, "saveToFSPath": "updatedpac1.pac"}'`
```

Response

```json
{
  "id": 1,
  "name": "updated pac 1",
  "description": "updated pac 1 desc",
  "proxyRules": [
    {
      "id": 2,
      "proxy": {
        "id": 1,
        "hostAddress": "127.0.0.1:8080",
        "description": "local proxy",
        "builtIn": false
      },
      "enabled": true,
      "name": "proxy group 1",
      "hostRules": [
        {
          "id": 1,
          "hostTemplate": "google.com",
          "strict": true,
          "category": {
            "id": 2,
            "name": "work"
          }
        },
        {
          "id": 2,
          "hostTemplate": "memes.com",
          "strict": false,
          "category": {
            "id": 1,
            "name": "fun"
          }
        }
      ]
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
      "id": 1,
      "proxy": {
        "id": 1,
        "hostAddress": "127.0.0.1:8080",
        "description": "local proxy",
        "builtIn": false
      },
      "enabled": true,
      "name": "proxy group 1",
      "hostRules": [
        {
          "id": 1,
          "hostTemplate": "google.com",
          "strict": true,
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

### Add proxy rules to PC

```bash
curl -X POST http://127.0.0.1:8080/api/pac/1/proxyrules/2
```

Returns updated proxy rules for PAC object.

```json
{
  "proxyRules": [
    {
      "id": 1,
      "proxy": {
        "id": 1,
        "hostAddress": "127.0.0.1:8080",
        "description": "local proxy",
        "builtIn": false
      },
      "enabled": true,
      "name": "proxy group 1",
      "hostRules": [
        {
          "id": 1,
          "hostTemplate": "google.com",
          "strict": true,
          "category": {
            "id": 2,
            "name": "work"
          }
        }
      ]
    },
    {
      "id": 2,
      "proxy": {
        "id": 1,
        "hostAddress": "127.0.0.1:8080",
        "description": "local proxy",
        "builtIn": false
      },
      "enabled": true,
      "name": "proxy group 1",
      "hostRules": [
        {
          "id": 1,
          "hostTemplate": "google.com",
          "strict": true,
          "category": {
            "id": 2,
            "name": "work"
          }
        },
        {
          "id": 2,
          "hostTemplate": "memes.com",
          "strict": false,
          "category": {
            "id": 1,
            "name": "fun"
          }
        }
      ]
    }
  ]
}
```

### Delete proxy rules from PC

```bash
curl -X DELETE http://127.0.0.1:8080/api/pac/1/proxyrules/2
```

Returns updated proxy rules for PAC object.

```json
{
  "proxyRules": [
    {
      "id": 1,
      "proxy": {
        "id": 1,
        "hostAddress": "127.0.0.1:8080",
        "description": "local proxy",
        "builtIn": false
      },
      "enabled": true,
      "name": "proxy group 1",
      "hostRules": [
        {
          "id": 1,
          "hostTemplate": "google.com",
          "strict": true,
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
