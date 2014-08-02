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
#   hubot newrelic - Returns summary application stats from New Relic
#
# Author:
#   bryantebeek

moment = require "moment"
request = require "request"
schedule = require "node-schedule"

module.exports = (robot) ->
  accountId = process.env.HUBOT_NEWRELIC_ACCOUNT_ID
  apiKey = process.env.HUBOT_NEWRELIC_API_KEY

  setup = ->
    unless robot.brain.data.newrelic?
      robot.brain.data.newrelic = {}

    request { url: "https://api.newrelic.com/v2/applications.json", headers: { "X-Api-Key": apiKey } }, (error, response, body) ->
      data = JSON.parse(body)
      robot.brain.data.newrelic.applications = data.applications

    request { url: "https://api.newrelic.com/v2/servers.json", headers: { "X-Api-Key": apiKey } }, (error, response, body)->
      data = JSON.parse(body)
      robot.brain.data.newrelic.servers = data.servers

  setup()

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
