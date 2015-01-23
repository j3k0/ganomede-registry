assert = require "assert"
main = require "../src/main"

# linked services
linkedServices = require "../src/linked-services"

describe "findLinkedServices", ->
  it "should find a list of host from env", () ->

    env =
      X: 12
      Y: "host"
      SERVICE_HELLO_PORT: "invalid"
      SERVICE_WORLD_PORT: "tcp://1.2.3.4:5000"
      SERVICE_1_PORT: "tcp://4.3.2.1:5"
      NO_SERVICE_1_PORT: "x"

    services = linkedServices.findLinkedServices env
    assert.equal 2, services.length
    assert.equal "1.2.3.4", services[0].host
    assert.equal 5000, services[0].port
    assert.equal "4.3.2.1", services[1].host
    assert.equal 5, services[1].port

# vim: ts=2:sw=2:et:
