log = require "./log"
restify = require "restify"

services = require "./services"

sendError = (err, next) ->
  log.error err
  next err

get = (req, res, next) ->
  now = +(new Date)
  res.send ((
    type: s.type
    version: s.version
    host: s.host
    port: s.port
    pingMs: s.pingMs) for s in services.all() when s.pingEndDate > now - 10000)
  next()

post = (req, res, next) ->
  s = req.body
  if !s
    err = new restify.InvalidContentError "invalid service data"
    return sendError err, next
  if !s.type
    err = new restify.InvalidContentError "invalid service data"
    return sendError err, next
  if !s.version
    err = new restify.InvalidContentError "invalid service data"
    return sendError err, next
  if !s.host
    err = new restify.InvalidContentError "invalid service data"
    return sendError err, next
  if !s.port
    err = new restify.InvalidContentError "invalid service data"
    return sendError err, next
  if !s.pingURI
    err = new restify.InvalidContentError "invalid service data"
    return sendError err, next
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
  server.get "/#{prefix}/services", get
  server.post "/#{prefix}/services", post

initialize = (servicesList) ->
  services = servicesList || require('./services')

module.exports =
  initialize: initialize
  addRoutes: addRoutes

# vim: ts=2:sw=2:et:
