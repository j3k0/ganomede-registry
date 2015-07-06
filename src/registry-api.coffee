log = require "./log"
config = require '../config'
restify = require "restify"

services = null

get = (req, res, next) ->
  # only includes services that was pinged within last 10 seconds.
  diff = Date.now() - 10000 # config.pingInterval
  # Can be cached for 10 seconds (by CDN)
  res.header 'Cache-Control', 'public, max-age=30'
  res.send ((
    type: s.type
    version: s.version
    config: s.config || null
    protocol: s.protocol
    host: s.host
    port: s.port
    path: s.path
    pingMs: s.pingMs) for s in services.all())
  next()

addRoutes = (prefix, server) ->
  if !services
    throw new Error('NotInitialized')

  server.get "/#{prefix}/services", get

initialize = (options={}) ->
  services = options.services || require('./services')

module.exports =
  initialize: initialize
  addRoutes: addRoutes

# vim: ts=2:sw=2:et:
