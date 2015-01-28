restify = require "restify"
log = require "./log"

linkedServices = require "./linked-services"
all = linkedServices.get()

# Create JSON clients for each linked service
for s in all
  s.client = restify.createJsonClient
    url: "http://#{s.host}:#{s.port}"

# Retrieve a service's /about
readAbout = (s) ->
  d0 = +new Date
  s.client.get "/about", (err, req, res, obj) ->
    if err
      log.error err
      s.type = null
      s.pingMs = -1
      s.pingEndDate = -1
      return
    s.version = obj.version
    s.type = obj.type
    majorVersion = obj.version.split(".")[0]
    s.prefix = obj.type + "/v" + majorVersion
    s.pingEndDate = (+new Date)
    s.pingMs = s.pingEndDate - d0

readAllAbout = ->
  for s in linkedServices.get()
    readAbout s

# Retrieve all services /about every 10 seconds
readAllAbout
setInterval readAllAbout, 1000

module.exports =
  all: -> s for s in all when s.type
  forPrefix: (prefix) -> s for s in all when s.prefix == prefix
  push: (x) -> all.push x

# vim: ts=2:sw=2:et:
