assert = require 'assert'
restify = require 'restify'
registryApi = require '../src/registry-api'
config = require '../config'

fakeRestify = require "./fake-restify"
server = fakeRestify.createServer()
endpointPath = "/#{config.routePrefix}/services"

services = []

newService = () ->
  ++newService.counter
  return {
    type: "service#{newService.counter}"
    version: '1.0.0'
    host: 'localhost'
    port: 1000 + newService.counter
    pingURI: 'whatever'
  }

servicesEqual = (left, right) ->
  if left == right
    return true

  if left.length != right.length
    return false

  for item, idx in left
    for own key, val of item
      if val != right[idx][key]
        return false

  return true

addService = (s) ->
  server.request 'post', endpointPath, {body: s}
  return server.res.body

listServices = () ->
  server.request 'get', endpointPath
  return server.res.body

describe 'registry-api', () ->
  before () ->
    registryApi.initialize
      services:
        all: () -> services
        push: (s) -> services.push(s)

    registryApi.addRoutes(config.routePrefix, server)

  beforeEach () ->
    services = []
    newService.counter = 0
    assert.equal listServices().length, 0

  it 'should have GET and POST endpoints of format /`prefix`/services', () ->
    assert.ok server.routes.get[endpointPath]
    assert.ok server.routes.post[endpointPath]

  it 'GET for array of services that was pinged within last 10 seconds', () ->
    s = newService()
    addService(s)
    assert.equal listServices().length, 0 # not pinged yet, so shouldn't show up
    services[0].pingStartDate = Date.now() - 250 # fake pinging
    services[0].pingEndDate = Date.now() - 200
    services[0].pingMs = 50
    assert.ok servicesEqual([s], services) # should show up
    delete s.pingURI # this isn't included in GET results
    assert.ok servicesEqual([s], listServices())

  it 'POST adds new valid services to the list', () ->
    validServices = [newService(), newService(), newService()]
    badServices = [{}, undefined]

    for s in validServices
      assert.ok addService(s).ok == true

    # services should be equal to validServices
    # except that certain fields are set to -1
    s = services[1]
    assert.ok servicesEqual(validServices, services)
    assert.ok s.pingMs == s.pingStartDate == s.pingEndDate == -1

    for s in badServices
      assert.ok addService(s) instanceof restify.InvalidContentError

    # no bad services should be added
    assert.equal services.length, validServices.length
