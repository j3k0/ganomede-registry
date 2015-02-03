# TODO:
# move out fakeService to separate module
# dont create fakeService at all and replace http client inside services.coffee?
# test multiple services?

assert = require 'assert'
services = require '../src/services'
fakeRestify = require './fake-restify'

delay = (ms, fn) -> setTimeout(fn, ms)
interval = (ms, fn) -> setInterval(fn, ms)

HOST = 'localhost'
PORT = 1337

serviceList = [
  host: HOST
  port: PORT,
]

fakeResponse =
  type: 'fake'
  version: '1.0.1'
  startDate: new Date()

nrequests = 0
readAllRan = false

mocks =
  get:
    '/about': (callback) ->
      ++nrequests
      callback(null, {}, {}, fakeResponse)

spyingSetInterval = (fn, ms) ->
  call = () ->
    readAllRan = true
    fn.apply(this, arguments)

  # run once
  setTimeout(call, 5)

describe  "services", () ->
  before () ->
    services.initialize
      setInterval: spyingSetInterval
      createJsonClient: fakeRestify.createJsonClientFn(mocks)
      linkedServices:
        get: () -> serviceList

  it "should retrieve GET service info from /about path", (done) ->
    # TODO:
    # fix this waiting thing.

    # wait for 2 requests to happen:
    # 1 from initialize() and 1 from readAllAbout
    ival = interval 10, ->
      if nrequests == 2 && readAllRan
        clearInterval(ival)
        test()

    test = ->
      assert.equal services.forPrefix('fake/v1').length, 1
      assert.equal services.all().length, 1

      service = services.all()[0]
      assert.ok service.hasOwnProperty('pingMs')
      assert.ok service.pingMs >= 0
      for val, key in fakeResponse
        assert.equal val service[key]

      done()
