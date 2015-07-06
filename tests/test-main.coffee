assert = require "assert"
main = require "../src/main"

# linked services
findLinkedServices = require "../src/find-linked-services"

describe "findLinkedServices", ->
  return
  it "should find a list of host from env", () ->

    env =
      X: 12
      Y: "host"
      SERVICE_HELLO_URL: "invalid"
      SERVICE_WORLD_URL: "tcp://1.2.3.4:5000"
      SERVICE_1_URL: "tcp://4.3.2.1:5"
      NO_SERVICE_1_URL: "x"

    services = findLinkedServices env
    assert.equal 4, services.length
    assert.equal "tcp://1.2.3.4:5000", services[0].url
    assert.equal 5000, services[0].port
    assert.equal "4.3.2.1", services[1].host
    assert.equal 5, services[1].port

# vim: ts=2:sw=2:et:
