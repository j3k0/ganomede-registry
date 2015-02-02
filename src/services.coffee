restify = require "restify"
log = require "./log"

linkedServices = null # custom service finder
interval = null # custom setInterval
all = [] # linkedServices.get()

initialize = (options) ->
  options = options || {}
  linkedServices = options.linkedServices || require "./linked-services"
  interval = options.interval || setInterval

  # Create JSON clients for each linked service
  all = linkedServices.get()
  for s in all
    s.client = restify.createJsonClient
      url: "http://#{s.host}:#{s.port}"

  # Retrieve all services /about every 10 seconds
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
  for s in linkedServices.get()
    readAbout s

module.exports =
  initialize: initialize
  all: -> s for s in all when s.type
  forPrefix: (prefix) -> s for s in all when s.prefix == prefix
  push: (x) -> all.push x

# vim: ts=2:sw=2:et:
