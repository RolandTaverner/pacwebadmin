# PAC web admin (work in progress)
Web admin to manage proxy autoconfiguration (PAC) file


## Categories API requests

curl http://127.0.0.1:8080/api/categories/all | jq

curl http://127.0.0.1:8080/api/categories/1 | jq

curl -X POST http://127.0.0.1:8080/api/categories/create -H "Content-Type: application/json" -d '{"id": 1, "name": "qwerty"}' | jq

curl -X PUT http://127.0.0.1:8080/api/categories/update -H "Content-Type: application/json" -d '{"id": 1, "name": "updated"}' | jq

curl -X DELETE http://127.0.0.1:8080/api/categories/1 | jq

## Proxies API requests

curl http://127.0.0.1:8080/api/proxies/all | jq

curl http://127.0.0.1:8080/api/proxies/1 | jq

curl -X POST http://127.0.0.1:8080/api/proxies/create -H "Content-Type: application/json" -d '{"id": 1, "hostAddress": "qwerty", "description": "desc", "builtIn": false}' | jq

curl -X PUT http://127.0.0.1:8080/api/proxies/update -H "Content-Type: application/json" -d '{"id": 1, "hostAddress": "qwerty updated", "description": "desc updated", "builtIn": true}' | jq

curl -X DELETE http://127.0.0.1:8080/api/proxies/1 | jq
