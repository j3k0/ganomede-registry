linkedServices = require "./linked-services"

all = []

forType = (type) ->
  s for s in all when s.type == type

module.exports =
  all: -> all
  forType: forType
  push: (x) -> all.push x

# vim: ts=2:sw=2:et:
