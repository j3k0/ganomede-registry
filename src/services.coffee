restify = require "restify"
log = require "./log"

services = null
createClient = null

# Create JSON clients for each linked service
ensureClients = () ->
  for s in services
    s.client = s.client || createClient
      url: "http://#{s.host}:#{s.port}"

initialize = (options={}) ->
  services = options.discoveredServices || []
  interval = options.setInterval || setInterval
  createClient = options.createJsonClient ||
    restify.createJsonClient.bind(restify)

  # Retrieve all services /about every 10 seconds
  ensureClients()
  readAllAbout()
  interval readAllAbout, 10e3

# Retrieve a service's /about
readAbout = (s) ->
  d0 = Date.now()
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
    s.pingEndDate = Date.now()
    s.pingMs = s.pingEndDate - d0

readAllAbout = ->
  for s in services
    readAbout s

module.exports =
  initialize: initialize
  all: -> s for s in services when s.type
  forPrefix: (prefix) -> s for s in services when s.prefix == prefix
  push: (x) ->
    services.push(x)
    ensureClients()

# vim: ts=2:sw=2:et:
