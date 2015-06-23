log = require "./log"
pingApi = require "./ping-api"
registryApi = require "./registry-api"
proxy = require "./proxy"
services = require "./services"
findLinkedServices = require './find-linked-services'

addRoutes = (prefix, server) ->
  log.info "adding routes"

  # Platform Availability
  pingApi.addRoutes prefix, server

  registryApi.addRoutes prefix, server

initialize = (callback) ->
  log.info "initializing backend"
  registryApi.initialize()
  services.initialize
    discoveredServices: findLinkedServices(process.env)
  callback?()

destroy = ->
  log.info "destroying backend"

createProxyServer = ->
  server = null
  return {
    listen: (port, cb) ->
      # Give some time for all services to be pinged
      setTimeout ->
        proxy.createServer()
        server.listen port, cb
      , 5000
    close: ->
      if server
        server.close()
  }

module.exports =
  initialize: initialize
  destroy: destroy
  addRoutes: addRoutes
  createProxyServer: createProxyServer
  log: log

# vim: ts=2:sw=2:et:
