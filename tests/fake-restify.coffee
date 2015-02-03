# vim: ts=2:sw=2:et:

notImplemented = () ->
  throw new Error('NotImplemented')

class Res
  constructor: ->
    @status = 200
  send: (data) ->
    @body = data

class Server
  constructor: ->
    @routes =
      get: {}
      head: {}
      put: {}
      post: {}
      del: {}
  get: (url, callback) ->
    @routes.get[url] = callback
  head: (url, callback) ->
    @routes.head[url] = callback
  put: (url, callback) ->
    @routes.put[url] = callback
  post: (url, callback) ->
    @routes.post[url] = callback
  del: (url, callback) ->
    @routes.del[url] = callback

  request: (type, url, req, callback) ->
    @routes[type][url] req, @res = new Res,
      (data) =>
        if data
          @res.status = data.status || 500
          @res.send data
        callback? @res

class JsonClient
  constructor: (options) ->
    # This is not implemented options which are supported by real json client
    # (from http://mcavage.me/node-restify/#jsonclient)
    unsupportedOptions = [
      'accept', 'connectTimeout', 'requestTimeout', 'dtrace', 'gzip',
      'headers', 'log', 'retry', 'signRequest', 'userAgent', 'version']
    # If we find some that are not supported inside @options, throw an error.
    for key in Object.keys(options)
      if -1 != unsupportedOptions.indexOf(key)
        throw new Error('NotImplemented')

    this.baseUrl = options.url
    if not this.baseUrl
      throw new Error('NotImplemented')

    # Mocks
    # Collection of METHOD and pathes, could include function
    # or objects for replying to those calls.
    #
    # Callback must have same logic as restify's:
    # function(err, req, res, obj) {...}
    #
    # this.mocks = {}
    # this.mocks[METHOD][path] = function (payload, callback)
    # this.mocks[METHOD][path] = 'body' or {} or anything really

  _mockRespond: (method, path, payload, callback) ->
    if !this.mocks.hasOwnProperty(method)
      throw new Error('MethodNotSupported')

    if !this.mocks[method].hasOwnProperty(path)
      throw new Error('PathNotSupportedByMethod')

    if arguments.length == 3
      callback = payload
      payload = null

    mock = this.mocks[method][path]
    reply = (err, req, res, data) ->
      process.nextTick callback.bind(this, err, req, res, data)

    # TODO:
    # what is `this` bound to for restify-client callbacks?
    if mock instanceof Function
      # Bound mock() function to cient, so it can distinguish between them.
      args = if mock.length == 1 then [reply] else [payload, reply]
      mock.apply(this, args)
    else
      reply(null, {}, {}, mock)

  get: (path, callback) ->
    this._mockRespond('get', path, callback)

  head: notImplemented
  post: notImplemented
  put: notImplemented
  del: notImplemented

module.exports =
  createServer: -> new Server
  createJsonClientFn: (mocks) ->
    return (options) ->
      client = new JsonClient(options)
      client.mocks = mocks
      return client
