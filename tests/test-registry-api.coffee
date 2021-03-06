assert = require 'assert'
restify = require 'restify'
registryApi = require '../src/registry-api'
config = require '../config'

fakeRestify = require "./fake-restify"
server = fakeRestify.createServer()
endpointPath = "/#{config.routePrefix}/services"

PING_INTERVAL = 1e3

services = []

newService = () ->
  ++newService.counter
  return {
    type: "service#{newService.counter}"
    version: '1.0.0'
    host: 'localhost'
    port: 1000 + newService.counter
    pingURI: 'whatever'
    config: null
  }

fakePing = (obj, ping=50, lastRun=PING_INTERVAL/2) ->
  now = Date.now()
  obj.pingStartDate = now - lastRun - ping
  obj.pingEndDate = now - lastRun
  obj.pingMs = ping

# @left and @right matters, since only keys of @left are checked
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

process.env.API_SECRET = "abcd1234"

addService = (s) ->
  server.request 'post', endpointPath,
    body:
      secret: process.env.API_SECRET
      type: s.type
      version: s.version
      config: s.config
      host: s.host
      port: s.port
      pintURI: s.pingURI
  return server.res.body

listServices = () ->
  server.request 'get', endpointPath
  return server.res.body

describe 'registry-api', () ->
  return
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

  it 'GET for array of services that was pinged within last X seconds', () ->
    # add, ping, retrieve
    s = newService()
    addService(s)
    assert.equal 1, services.length
    assert.equal 0, listServices().length # not pinged yet, so shouldn't show up
    fakePing(services[0]) # fake ping
    assert.ok servicesEqual([s], services) # should show up
    delete s.pingURI # this isn't included in GET results
    assert.ok servicesEqual([s], listServices())

    # add, ping but too long time ago, retrieve
    s2 = newService()
    addService(s2)
    assert.equal listServices().length, 1 # not pinged
    fakePing(services[1], 50, 2 * PING_INTERVAL) # was pinged too long time ago
    assert.ok servicesEqual([s, s2], services) # s2 is in services...
    delete s2.pingURI
    assert.ok servicesEqual([s], listServices()) # ...but not in /GET result

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

  it 'POST updates existing services', () ->
    # add new service
    s = newService()
    addService(s)
    fakePing(services[0])
    assert.equal listServices().length, 1

    # just make sure that we are not using the same object by reference
    # due to all mocking/faking buisness
    innerS = services[0]
    assert.notStrictEqual s, innerS

    # update it, expect it to be not pinged because of it
    oldType = s.type
    s.type = 'newtype'
    addService(s)
    assert.ok innerS.pingMs == innerS.pingStartDate == innerS.pingEndDate == -1
    assert.equal listServices().length, 0

    # no new services must show up
    assert.equal services.length, 1
    assert.strictEqual innerS, services[0]

    # fake ping and expect it to show up
    fakePing(innerS)
    assert.ok servicesEqual(listServices(), [innerS])
