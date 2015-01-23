Description
-----------

Registry module:

 - maintains the list of running services.
 - takes care of pinging the services to check that they're still running.
 - use "bouncy" to proxy requests to the right host

Relations
---------

 - List of running services is holded in memory.
 - REDIS store (TODO later)

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
 * request in HTTP the "/about" URI
 * expect a JSON body containing

    {
        "type": "users",
        "version": "1.0.0",
        "startDate": "2015-01-23T13:38:48+02:00"
    }

# Services

## /registry/services [GET]

### parameters

    "type" (optional) filter by type

### response [200] OK

    [
        {
            "type": "users",
            "host": "192.168.1.2",
            "port": 8000,
            "pingMs": 12
        },
        {
            "type": "users",
            "host": "192.168.1.4",
            "port": 8000,
            "pingMs": 15
        }
    ]

`pingMs` is in a value in milliseconds.
