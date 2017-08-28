Description
-----------

[![Greenkeeper badge](https://badges.greenkeeper.io/j3k0/ganomede-registry.svg)](https://greenkeeper.io/)

Registry module:

 - maintains the list of running services.
 - takes care of pinging the services to check that they're still running.
 - use "bouncy" to proxy requests to the right host

Relations
---------

 - List of running services is holded in memory.
 - List of running services is discovered uing environment variables.

Proxy
-----

Accessible on port 8080 by default.

Registry's API
--------------

Accessible on port 8000 by default.

Background job
--------------

Registry will:

 * check services defined in environment variables matching `SERVICE_*_PORT`
 * request in HTTP their "/about" URI
 * expect a JSON body containing

```js
    {
        "type": "users",
        "version": "1.0.0",
        "startDate": "2015-01-23T13:38:48+02:00"
    }
```

 * request to `/{service-name}/{version}/...` will then be proxied to the appropriate service.
```js
    "/users/v1/login" // proxied to one of the "users" service instances.
```

# API

## /registry/v1/services [GET]

### parameters

    "type" (optional) filter by type (TODO)

### response [200] OK

    [
        {
            "type": "users",
            "version": "1.0.1",
            "host": "192.168.1.2",
            "port": 8000,
            "pingMs": 12
        },
        {
            "type": "invitations",
            "version": "1.0.3",
            "host": "192.168.1.4",
            "port": 8000,
            "pingMs": 15
        }
    ]

`pingMs` is in a value in milliseconds.
