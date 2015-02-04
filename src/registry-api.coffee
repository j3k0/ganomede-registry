log = require "./log"
restify = require "restify"

services = null

validateBody = (req, res, next) ->
  ok = req.body && req.body.type && req.body.version && req.body.host &&
    req.body.port && req.body.pingURI

  if !ok
    err = new restify.InvalidContentError('invalid service data')
    log.error(err)
    return next(err)

  next()

get = (req, res, next) ->
  # only includes services that was pinged within last diff milliseconds.
  diff = Date.now() - 10e3
  res.send ((
    type: s.type
    version: s.version
    host: s.host
    port: s.port
    pingMs: s.pingMs) for s in services.all() when s.pingEndDate > diff)
  next()

post = (req, res, next) ->
  s = req.body
  existing = (
    x for x in services.all() when (
      s.host == x.host and s.port == x.port))

  if existing.length > 0
    log.info "service updated", s
    existing[0].type = s.type
    existing[0].version = s.version
    existing[0].pingURI = s.pingURI
    existing[0].pingMs = -1
    existing[0].pingStartDate = -1
    existing[0].pingEndDate = -1
  else
    log.info "service added", s
    services.push
      type: s.type
      version: s.version
      host: s.host
      port: s.port
      pingURI: s.pingURI
      pingMs: -1
      pingStartDate: -1
      pingEndDate: -1

  res.send ok:true
  next()

addRoutes = (prefix, server) ->
  if !services
    throw new Error('NotInitialized')

  server.get "/#{prefix}/services", get
  server.post "/#{prefix}/services", validateBody, post

initialize = (servicesList) ->
  services = servicesList || require('./services')

module.exports =
  initialize: initialize
  addRoutes: addRoutes

# vim: ts=2:sw=2:et:
