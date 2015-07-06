findLinkedServices = (env) ->
  linkedServices = []
  added = {}
  for name,value of env
    match = name.match /^SERVICE_.*_URL/
    if match and match.index == 0 and not added[value]
      url = value.split "/"
      if url.length > 4
        hostPort = url[2]
        hostPort = hostPort.split ":"
        host = hostPort[0]
        if hostPort.length == 1
          port = 80
        else
          port = +hostPort[1]
        linkedServices.push
          host: host
          port: port
          path: url[3] + "/" + url[4]
        # linkedServices.push url:value
        added[value] = true
  linkedServices

module.exports = findLinkedServices

# vim: ts=2:sw=2:et:
