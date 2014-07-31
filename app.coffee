ApiServer = require("apiserver")
IAPVerifier = require("iap_verifier")

apiServer = new ApiServer(port: 8080)
apiServer.use ApiServer.payloadParser()

# modules
apiServer.addModule "1", "verificationModule",
  verify:
    get: (request, response) ->
      response.serveJSON
        id: request.querystring.id
        verbose: request.querystring.verbose
        method: "GET"

    post: (request, response) ->
      request.resume()
      request.once "end", ->
        if request.parseError
          console.error request.parseError.message
          response.serveJSON
            error: "Ivalid request foramt"
            message: request.parseError.message
        else
          # request: { data: 'Base64 encodded receipt' }
          receipt = request.body.data

          # TODO: This can be found on the itunes connect page for the applications' in app purchases.
          itunes_shared_secret = ""
          client = new IAPVerifier(itunes_shared_secret, true)
          client.verifyReceipt receipt, isBase64 = true, (valid, msg, data) ->
            if valid
              response.serveJSON data
            else
              console.error("Invalid receipt: #{msg}, data: #{data}")
              response.serveJSON(
                { }
                { httpStatusCode: 422, httpStatusMessage: 'Unprocessable entity' }
              )

# custom routing
apiServer.router.addRoutes [
  ["/verify", "1/verificationModule#verify"]
]

# events
apiServer.on("requestStart", (pathname, time) ->
  console.info " ☉ :: start    :: %s", pathname
).on("requestEnd", (pathname, time) ->
  console.info " ☺ :: end      :: %s in %dms", pathname, time
).on("error", (pathname, err) ->
  console.info " ☹ :: error    :: %s (%s)", pathname, err.message
).on "timeout", (pathname) ->
  console.info " ☂ :: timedout :: %s", pathname

apiServer.listen()
