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

### Get by id

```bash
curl http://127.0.0.1:8080/api/category/1
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/category/create -H "Content-Type: application/json" -d '{"name": "category name"}'
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/category/1/update -H "Content-Type: application/json" -d '{"name": "updated"}'
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/category/1
```

## Proxies API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/proxy/all
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/proxy/1
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/proxy/create -H "Content-Type: application/json" -d '{"hostAddress": "127.0.0.1:1080", "description": "Proxy description", "builtIn": false}'
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/proxy/1/update -H "Content-Type: application/json" -d '{"hostAddress": "127.0.0.1:1080", "description": "Proxy description", "builtIn": false}'
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/proxy/1
```

## Host rules API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/hostrule/all
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/hostrule/1
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/hostrule/create -H "Content-Type: application/json" -d '{"hostTemplate": "example.com", "strict": true, "categoryId": 1}'
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/hostrule/1/update -H "Content-Type: application/json" -d '{"hostTemplate": "noexample.com", "strict": false, "categoryId": 2}'
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/hostrule/1
```

## Proxy rules API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/proxyrules/all
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/proxyrules/1
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/proxyrules/create -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "name": "proxy group 1", "hostRuleIds": [1]}'
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/proxyrules/1/update -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "name": "proxy group 1", "hostRuleIds": [1]}'
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/proxyrules/1
```

### Get host rules linked to proxy rules

```bash
curl http://127.0.0.1:8080/api/proxyrules/1/hostrules
```

### Add host rule to proxy rules

```bash
curl -X POST http://127.0.0.1:8080/api/proxyrules/1/hostrules/2
```

### Delete host rule from proxy rules

```bash
curl -X DELETE http://127.0.0.1:8080/api/proxyrules/1/hostrules/2
```

## PAC API requests

### Get all

```bash
curl http://127.0.0.1:8080/api/pac/all
```

### Get by id

```bash
curl http://127.0.0.1:8080/api/pac/1
```

### Create

```bash
curl -X POST http://127.0.0.1:8080/api/pac/create -H "Content-Type: application/json" -d '{"name": "pac1", "description": "desc", "proxyRulesIds": [1], "serve": true, "servePath": "pac1.pac", "saveToFS": true, "saveToFSPath": "pac1.pac"}'`
```

### Update

```bash
curl -X PUT http://127.0.0.1:8080/api/pac/1/update -H "Content-Type: application/json" -d '{"name": "updated pac1", "description": "updated desc", "proxyRulesIds": [1], "serve": false, "servePath": "updatedpac1.pac", "saveToFS": false, "saveToFSPath": "updatedpac1.pac"}'`
```

### Delete

```bash
curl -X DELETE http://127.0.0.1:8080/api/pac/1
```

### Get proxy rules linked to PAC

```bash
curl http://127.0.0.1:8080/api/pac/1/proxyrules
```

### Add proxy rules to PC

```bash
curl -X POST http://127.0.0.1:8080/api/pac/1/proxyrules/2
```

### Delete proxy rules from PC

```bash
curl -X DELETE http://127.0.0.1:8080/api/pac/1/proxyrules/2
```
