restify = require "restify"
log = require "./log"
config = require '../config'

services = null
createClient = null
pingInterval = null

# Create JSON clients for each linked service
ensureClients = () ->
  for s in services
    log.info "createClient",
      url: "http://#{s.host}:#{s.port}"
    s.client = s.client || createClient
      url: "http://#{s.host}:#{s.port}"

initialize = (options={}) ->
  services = options.discoveredServices || []
  interval = options.setInterval || setInterval
  pingInterval = options.pingInterval || config.pingInterval
  createClient = options.createJsonClient ||
    restify.createJsonClient.bind(restify)

  # Retrieve all services /about every @pingInterval milliseconds
  ensureClients()
  readAllAbout()
  interval readAllAbout, pingInterval

# Disable ping for 10 seconds
disable = (s) ->
  s.client = null
  setTimeout ->
    s.client = s.client || createClient
      url: "http://#{s.host}:#{s.port}"
  , 10000

# Retrieve a service's /about
readAbout = (s) ->
  if !services
    throw new Error('NotInitialized')

  # Skip
  if !s.client
    return

  d0 = Date.now()
  s.client.get "/about", (err, req, res, obj) ->
    if err
      log.error err,
        host:s.host
        port:s.port
      # If a service can't be found, it means there's a connection
      # issue between this registry and the linked service.
      #
      # Option 1: shut this registry off.
      # throw new Error(err)
      #
      # Option 2: Disable for the outside
      # s.type = null
      # s.pingMs = -1
      # s.pingEndDate = -1
      disable s
      #
      # Option 3: Do not disable for the outside... Let be optimistic!
      # Some failed requests shouldn't fully disable the
      # service. Maybe it was just temporary.
      return
    s.version = obj.version
    s.type = obj.type
    s.config = obj.config
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
