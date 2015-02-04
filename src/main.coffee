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

createProxyServer = -> proxy.createServer()

module.exports =
  initialize: initialize
  destroy: destroy
  addRoutes: addRoutes
  createProxyServer: createProxyServer
  log: log

# vim: ts=2:sw=2:et:
