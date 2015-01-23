log = require "./log"
bouncy = require "bouncy"
services = require "./services"
url = require "url"

createServer = ->
  server = bouncy (req, res, bounce) ->
    uri = url.parse(req.url).pathname
    uriArray = uri.split "/"
    if uriArray.length > 1
      serviceType = uriArray[1]
      service = services.forType serviceType
      if service
        server = service[(Math.random() * 999999) % service.length]
        bounce server.host, server.port
        return
    res.statusCode = 404
    res.end "no such service found"

module.exports =
  createServer: createServer

# vim: ts=2:sw=2:et:
