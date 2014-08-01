ApiServer = require("apiserver")
IAPVerifier = require("iap_verifier")

Dotenv = require('dotenv')
Dotenv.load()

apiServer = new ApiServer(port: process.env.PORT)
apiServer.use ApiServer.payloadParser()

# modules
apiServer.addModule "1", "verificationModule",
  verify:
    get: (request, response) ->
      response.serveJSON
        message: "Please use POST to verify receipt"

    post: (request, response) ->
      request.resume()
      request.once "end", ->
        if request.parseError
          console.error request.parseError.message
          response.serveJSON(
            { message: request.parseError.message }
            { httpStatusCode: 400, httpStatusMessage: 'Bad request' }
          )
        else
          # request: { data: 'Base64 encodded receipt' }
          receipt = request.body.data

          client = new IAPVerifier(process.env.ITUNES_SHARED_SECRET, true)
          client.verifyReceipt receipt, isBase64 = true, (valid, msg, data) ->
            if valid
              response.serveJSON data
            else
              console.error("Invalid receipt: #{msg}, data: #{data}")
              response.serveJSON( null, {
                httpStatusCode: 422,
                httpStatusMessage: 'Unprocessable entity'
              })

# custom routing
apiServer.router.addRoutes [
  ["/verify", "1/verificationModule#verify"]
]

# events
apiServer.on("requestStart", (pathname, time) ->
  console.info ":: start    :: %s", pathname
).on("requestEnd", (pathname, time) ->
  console.info ":: end      :: %s in %dms", pathname, time
).on("error", (pathname, err) ->
  console.error ":: error    :: %s (%s)", pathname, err.message
).on "timeout", (pathname) ->
  console.error ":: timedout :: %s", pathname

apiServer.listen()
