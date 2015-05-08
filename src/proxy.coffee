log = require "./log"
bouncy = require "bouncy"
services = require "./services"
url = require "url"
config = require "../config"

crossdomain_xml = '<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy
  SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <site-control permitted-cross-domain-policies="all"/>
  <allow-access-from domain="*" secure="false"/>
  <allow-http-request-headers-from domain="*" headers="*" secure="false"/>
</cross-domain-policy>
'

createServer = ->

  server = bouncy (req, res, bounce) ->

    uri = url.parse(req.url).pathname
    reqlog = log.child url:req.url
    uriArray = uri.split "/"
    if uriArray.length > 2
      serviceType = uriArray[1] + "/" + uriArray[2]
      service = services.forPrefix serviceType
      if service and service.length > 0
        if service.length == 1
          s = service[0]
        else
          s = service[Math.floor(Math.random() * service.length)]
        reqlog.info "bouncing to " + s.host + ":" + s.port
        bounce s.host, s.port,
          headers:
            Connection: "close"
        return
      if serviceType == config.routePrefix
        reqlog.info "bouncing to local port " + config.port
        bounce config.port,
          headers:
            Connection: "close"
        return
    if uri == '/crossdomain.xml'
      reqlog.info "delivering crossdomain.xml"
      res.statusCode = 200
      res.setHeader("Content-Type", "application/xml")
      res.write crossdomain_xml
      res.end()
    reqlog.warn "404"
    res.statusCode = 404
    res.end "no such service found"

module.exports =
  createServer: createServer

# vim: ts=2:sw=2:et:
