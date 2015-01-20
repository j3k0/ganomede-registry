Description
-----------

Registry module:

 - maintains the list of running services.
 - takes care of pinging the services to check that they're still running.

Relations
---------

 - List of running services is holded in memory. Each service is responsible to regulary check if he is still listed in the registry, re-register if not.

Registry's API
--------------

Accessible on port 8000 by default.

# Services

## /registry/services [POST]

### body (application/json)

    {
        "type": "users",
        "host": "192.168.1.2",
        "port": "8000",
        "pingURI": "/users/ping"
    }

## /registry/services [GET]

### parameters

    "type" (optional) filter by type

### response [200] OK

    [
        {
            "type": "users",
            "host": "192.168.1.2",
            "port": "8000",
            "pingMs": 12
        },
        {
            "type": "users",
            "host": "192.168.1.4",
            "port": "8000",
            "pingMs": 15
        }
    ]

`pingMs` is in a value in milliseconds.
