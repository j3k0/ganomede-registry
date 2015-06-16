log = require "./log"
config = require '../config'
restify = require "restify"

services = null

get = (req, res, next) ->
  # only includes services that was pinged within last 10 seconds.
  diff = Date.now() - 10000 # config.pingInterval
  res.send ((
    type: s.type
    version: s.version
    config: s.config || null
    host: s.host
    port: s.port
    pingMs: s.pingMs) for s in services.all() when s.pingEndDate > diff)
  next()

# Check the API secret key validity
apiSecretMiddleware = (req, res, next) ->
  secret = req.body?.secret
  if !secret
    return sendError(new restify.InvalidContentError('invalid content'), next)
  if secret != process.env.API_SECRET
    return sendError(new restify.UnauthorizedError('not authorized'), next)

  # Make sure secret isn't sent in clear to the users
  delete req.body.secret
  next()

post = (req, res, next) ->
  bodyOk = req.body && req.body.type && req.body.version && req.body.host &&
    req.body.port && req.body.pingURI

  if !bodyOk
    err = new restify.InvalidContentError('invalid service data')
    log.error(err)
    return next(err)

  s = req.body
  existing = (
    x for x in services.all() when (
      s.host == x.host and s.port == x.port))

  if existing.length > 0
    log.info "service updated", s
    existing[0].type = s.type
    existing[0].version = s.version
    existing[0].config = s.config
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
      config: s.config
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
  server.post "/#{prefix}/services",
    apiSecretMiddleware, post

initialize = (options={}) ->
  services = options.services || require('./services')

module.exports =
  initialize: initialize
  addRoutes: addRoutes

# vim: ts=2:sw=2:et:
