Dotenv = require('dotenv')
Dotenv.load()

Newrelic = require('newrelic')
IAPVerifier = require("iap_verifier")
Hapi = require('hapi')
Good = require('good')

db = require('./models')

server = new Hapi.Server(process.env.PORT);

server.route
  method: 'GET'
  path: '/'
  handler: (request, reply)->
    reply "iOS In-App Purchase verification service."

server.route
  method: 'GET'
  path: '/verify'
  handler: (request, reply)->
    reply { message: "Please use POST to verify receipt" }

server.route
  method: 'POST'
  path: '/verify'
  handler: (request, reply)->
    if receipt = request.payload.data
      client = new IAPVerifier(process.env.ITUNES_SHARED_SECRET, true)
      client.verifyReceipt receipt, isBase64 = true, (valid, msg, data) ->
        if valid
          db.Receipt.create({request_content: receipt, response_content: JSON.stringify(data)})
            .success ->
              server.log(['info'], "Receipt created")
          reply data
        else
          server.log(['warning'], "Invalid receipt: #{msg}, data: #{JSON.stringify(data)}")
          reply Hapi.error.badData('Invalid receipt')


server.pack.register Good, (err)->
  if err
    throw err

  db.sequelize.sync().complete (err)->
    if err
      throw err[0]
    else
      server.start ->
        server.log('info', "Server running at: #{server.info.uri}")
