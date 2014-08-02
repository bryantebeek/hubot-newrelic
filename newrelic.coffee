request = require "request"
Promise = require "bluebird"

class NewRelic
  constructor: (@accountId, @apiKey) ->

  getApplications: ->
    new Promise (resolve, reject) =>
      request (@getRequestOptions path: "/applications.json" ), (error, response, body) ->
        resolve JSON.parse(body)?.applications

  getServers: ->
    new Promise (resolve, reject) =>
      request (@getRequestOptions path: "/servers.json" ), (error, response, body) ->
        resolve JSON.parse(body)?.servers

  getRequestOptions: (options) ->
    "url": "https://api.newrelic.com/v2/#{options.path}",
    "headers":
      "X-Api-Key": @apiKey

module.exports = NewRelic
