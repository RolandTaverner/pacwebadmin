# PAC web admin (work in progress)
Web admin to manage proxy autoconfiguration (PAC) file


## Categories API requests

`curl http://127.0.0.1:8080/api/category/all | jq`

`curl http://127.0.0.1:8080/api/category/1 | jq`

`curl -X POST http://127.0.0.1:8080/api/category/create -H "Content-Type: application/json" -d '{"name": "qwerty"}' | jq`

`curl -X PUT http://127.0.0.1:8080/api/category/1/update -H "Content-Type: application/json" -d '{"name": "updated"}' | jq`

`curl -X DELETE http://127.0.0.1:8080/api/category/1 | jq`

## Proxies API requests

`curl http://127.0.0.1:8080/api/proxy/all | jq`

`curl http://127.0.0.1:8080/api/proxy/1 | jq`

`curl -X POST http://127.0.0.1:8080/api/proxy/create -H "Content-Type: application/json" -d '{"hostAddress": "qwerty", "description": "desc", "builtIn": false}' | jq`

`curl -X PUT http://127.0.0.1:8080/api/proxy/1/update -H "Content-Type: application/json" -d '{"hostAddress": "qwerty updated", "description": "desc updated", "builtIn": true}' | jq`

`curl -X DELETE http://127.0.0.1:8080/api/proxy/1 | jq`

## Host rules API requests

`curl http://127.0.0.1:8080/api/hostrule/all | jq`

`curl http://127.0.0.1:8080/api/hostrule/1 | jq`

`curl -X POST http://127.0.0.1:8080/api/hostrule/create -H "Content-Type: application/json" -d '{"hostTemplate": "example.com", "strict": true, "categoryId": 1}' | jq`

`curl -X PUT http://127.0.0.1:8080/api/hostrule/1/update -H "Content-Type: application/json" -d '{"hostTemplate": "noexample.com", "strict": false, "categoryId": 2}' | jq`

`curl -X DELETE http://127.0.0.1:8080/api/hostrule/1 | jq`

## Proxy rules API requests

`curl http://127.0.0.1:8080/api/proxyrules/all | jq`

`curl http://127.0.0.1:8080/api/proxyrules/1 | jq`

`curl -X POST http://127.0.0.1:8080/api/proxyrules/create -H "Content-Type: application/json" -d '{"proxyId": 1, "enabled": true, "hostRuleIds": [1]}' | jq`

`curl -X PUT http://127.0.0.1:8080/api/proxyrules/1/update -H "Content-Type: application/json" -d '{"hostTemplate": "noexample.com", "strict": false, "categoryId": 2}' | jq`

`curl -X DELETE http://127.0.0.1:8080/api/proxyrules/1 | jq`

`curl http://127.0.0.1:8080/api/proxyrules/1/hostrules | jq`

`curl -X POST http://127.0.0.1:8080/api/proxyrules/1/hostrules/2 | jq`

`curl -X DELETE http://127.0.0.1:8080/api/proxyrules/1/hostrules/2 | jq`
