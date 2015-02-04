findLinkedServices = (env) ->
  linkedServices = []
  added = {}
  for name,value of env
    match = name.match /^SERVICE_.*_PORT$/
    if match and match.index == 0 and not added[value]
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
        added[value] = true
  linkedServices

module.exports = findLinkedServices

# vim: ts=2:sw=2:et:
