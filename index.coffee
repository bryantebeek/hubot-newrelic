# Description:
#   Display current app performance stats from New Relic
#
# Dependencies:
#   moment
#   request
#
# Configuration:
#   HUBOT_NEWRELIC_ACCOUNT_ID
#   HUBOT_NEWRELIC_API_KEY
#
# Commands:
#   hubot newrelic list apps - Returns summary application stats from New Relic
#   hubot newrelic list apps - Returns summary application stats from New Relic
#
# Author:
#   bryantebeek

moment = require "moment"
request = require "request"
Promise = require "bluebird"

module.exports = (robot) ->

  class NewRelic
    constructor: (@apiKey, @accountId) ->

    getApplications: ->
      request (@getRequestOptions path: "/applications.json" ), (error, response, body) ->
        data = JSON.parse(body)

    getServers: ->
      request (@getRequestOptions path: "/servers.json" ), (error, response, body) ->
        data = JSON.parse(body)

    getRequestOptions: (options) ->
      "url": "https://api.newrelic.com/v2/#{options.path}",
      "headers":
        "X-Api-Key": @apiKey






  reload = ->
    unless robot.brain.data.newrelic?
      robot.brain.data.newrelic = {}


      robot.brain.data.newrelic.applications = data.applications

      data = JSON.parse(body)
      robot.brain.data.newrelic.servers = data.servers

  reload()

  robot.respond /newrelic\s(list|show)\sapp(s|lications)/i, (message) ->
    for application in robot.brain.data.newrelic.applications
      status = colorWordToHex(application.health_status)
      last_reported_at = moment(application.last_reported_at).fromNow()
      message.send "*#{application.name}* - #{application.application_summary.response_time} ms - #{application.application_summary.throughput} rpm - #{application.application_summary.error_rate}% errors - #{status} @ #{last_reported_at} [https://rpm.newrelic.com/accounts/#{accountId}/applications/#{application.id}]"

  robot.respond /newrelic\s(list|show)\s(servers?|hosts?)/i, (message) ->
    for server in robot.brain.data.newrelic.servers
      last_reported_at = moment(server.last_reported_at).fromNow()
      message.send "*#{server.name}* @ #{last_reported_at} [https://rpm.newrelic.com/accounts/#{accountId}/servers/#{server.id}]"

  colorWordToHex = (word)->
    switch word
      when "green" then "#00FF00"
      when "orange" then "#FFA500"
      when "red" then "#FF0000"
      else "#FFFFFF"
