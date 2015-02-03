# TODO:
# move out fakeService to separate module
# dont create fakeService at all and replace http client inside services.coffee?
# test multiple services?

assert = require 'assert'
restify = require 'restify'
services = require '../src/services'
fakeRestify = require './fake-restify'

delay = (ms, fn) -> setTimeout(fn, ms)
interval = (ms, fn) -> setInterval(fn, ms)
toInt = (val, base=10) -> parseInt(val, base)

HOST = 'localhost'
PORT = 1337
SIMULATED_PING = 20

serviceList = [
  {host: HOST, port: PORT},
  {host: HOST, port: PORT + 1}
]

fakeResponse =
  type: 'fake'
  version: '1.0.1'
  startDate: new Date()

nrequests = 0
readAllRan = false

mocks =
  get:
    # this is bound to fake client
    '/about': (callback) ->
      # dead service (PORT)
      if PORT == toInt this.baseUrl.slice(this.baseUrl.lastIndexOf(':') + 1)
        return callback(new restify.errors.InternalServerError(), {}, {})

      # ok service (PORT + 1)
      delay SIMULATED_PING, () ->
        ++nrequests
        callback(null, {}, {}, fakeResponse)

spyingSetInterval = (fn, ms) ->
  call = () ->
    readAllRan = true
    fn.apply(this, arguments)

  # run once
  setTimeout(call, 5)

describe  "services", () ->
  before (done) ->
    services.initialize
      setInterval: spyingSetInterval
      createJsonClient: fakeRestify.createJsonClientFn(mocks)
      linkedServices:
        get: () -> serviceList

    # TODO:
    # fix this waiting thing.

    # wait for 2 requests to happen:
    # 1 from initialize() and 1 from readAllAbout
    ival = interval 10, ->
      if nrequests == 2 && readAllRan
        clearInterval(ival)
        done()

  it "should not include dead services to output", () ->
    assert.equal services.all().length, 1

  it "should retrieve GET service info from /about path", () ->
    list = services.forPrefix('fake/v1')
    service = list[0]

    assert.equal list.length, 1
    assert.ok service.hasOwnProperty('pingMs')
    assert.ok service.pingMs >= SIMULATED_PING
    for val, key in fakeResponse
      assert.equal val, service[key]

