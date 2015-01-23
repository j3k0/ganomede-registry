linkedServices = []

findLinkedServices = (env) ->
  linkedServices = []
  for name,value of env
    match = name.match /SERVICE_.*_PORT/
    if match and match.index == 0
      http = value.replace "tcp://", "http://"
      a = value.split "/"
      if a.length > 2
        hostPort = a[2]
        a = hostPort.split ":"
        host = a[0]
        if a.length == 1
          port = 80
        else
          port = +a[1]
        linkedServices.push
          host: host
          port: port

linkedServices = findLinkedServices process.env

module.exports =
  get: -> linkedServices

  # exported for testing
  findLinkedServices: findLinkedServices

# vim: ts=2:sw=2:et:
