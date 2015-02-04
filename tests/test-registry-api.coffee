assert = require 'assert'
registryApi = require '../src/registry-api'
config = require '../config'

fakeRestify = require "./fake-restify"
server = fakeRestify.createServer()
endpointPath = "/#{config.routePrefix}/services"

describe 'registry-api', () ->
  before () ->
    registryApi.addRoutes(config.routePrefix, server)

  it 'should have GET and POST endpoints of format /`prefix`/services', () ->
    assert.ok server.routes.get[endpointPath]
    assert.ok server.routes.post[endpointPath]

  it 'should respond to GET with array of services that was pinged within
   last 10 seconds', () ->
    assert.ok null

  it 'should be able to add new service via POST', () ->
    assert.ok null

