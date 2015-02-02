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
      if unsupportedOptions.indexOf(key)
        throw new Error('NotImplemented')

    this.baseUrl = options.url
    if not url
      throw new Error('NotImplemented')

    # Mocks
    # Collection of METHOD and pathes, could include function
    # or objects for replying to those calls.
    #
    # Callback must have same logic as restify's:
    # function(err, req, res, obj) {...}
    #
    # this.mocks[METHOD][path] = function (payload, callback)
    # this.mocks[METHOD][path] = 'body' or {} or anything really
    this._mocks = {
      get: {}
    }

  # Appends mock
  #
  # fn could be either function or
  #
  # new JsonClient().mock('get', '/status', function (payload, cb) {
  #   return cb(null, {}, {}, {ok: true});
  # });
  mock: (method, path, fn) ->
    method = method.toLowerCase().trim()

    if !this.mocks.hasOwnProperty(method)
      throw new Error('MethodNotSupported')

    this.mocks[method][path] = fn

  _mockRespond: (method, path, payload, callback) ->
    if !this.mocks.hasOwnProperty(method)
      throw new Error('MethodNotSupported')

    if !this.mocks.get.hasOwnProperty(path)
      throw new Error('PathNotSupportedByMethod')

    if arguments.length == 3
      callback = payload
      payload = null

    mock = this.mocks[method][path]
    reply (err, req, res, data) ->
      process.nextTick callback.bind(this, err, req, res, data)

    if mock instanceof Function
      if mock.length == 1 then mock(reply) else mock(payload, reply)
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
  createJsonClient: (options) -> new JsonClient(options)
