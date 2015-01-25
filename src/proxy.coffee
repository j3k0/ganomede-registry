log = require "./log"
bouncy = require "bouncy"
services = require "./services"
url = require "url"
config = require "../config"

createServer = ->
  server = bouncy (req, res, bounce) ->
    uri = url.parse(req.url).pathname
    uriArray = uri.split "/"
    if uriArray.length > 1
      serviceType = uriArray[1]
      service = services.forType serviceType
      if service and service.length > 0
        s = service[Math.floor(Math.random() * service.length)]
        bounce s.host, s.port
        return
      if serviceType == config.routePrefix
        bounce config.port
        return
    res.statusCode = 404
    res.end "no such service found"

module.exports =
  createServer: createServer

# vim: ts=2:sw=2:et:
