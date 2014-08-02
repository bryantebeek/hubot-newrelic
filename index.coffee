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
humanize = require "humanize"
NewRelic = require "./newrelic"

module.exports = (robot) ->

  accountId = process.env.HUBOT_NEWRELIC_ACCOUNT_ID
  apiKey = process.env.HUBOT_NEWRELIC_API_KEY

  reload = ->
    unless robot.brain.data.newrelic?
      robot.brain.data.newrelic = {}

    unless accountId? or apiKey?
      robot.logger.warning 'The HUBOT_NEWRELIC_ACCOUNT_ID and HUBOT_NEWRELIC_API_KEY environment variables are required.'

    client = new NewRelic accountId, apiKey

    client.getApplications().then (applications) ->
      robot.brain.data.newrelic.applications = applications

    client.getServers().then (servers) ->
      robot.brain.data.newrelic.servers = servers

  setInterval reload, 60000 # Reload every minute

  reload() # Initial reload so data is available

  robot.respond /newrelic\s(list|show)\sapp(s|lications)/i, (message) ->
    for application in robot.brain.data.newrelic.applications
      last_reported_at = moment(application.last_reported_at).fromNow()
      responseTime = "#{application.application_summary.response_time} Ms"
      throughput = "#{application.application_summary.throughput} Rpm"
      errorRate = "#{application.application_summary.error_rate}% Errors"
      message.send "(#{application.name}, #{application.health_status}) #{responseTime}, #{throughput}, #{errorRate} | #{last_reported_at} @ [https://rpm.newrelic.com/accounts/#{accountId}/applications/#{application.id}]"

  robot.respond /newrelic\s(list|show)\s(servers?|hosts?)/i, (message) ->
    for server in robot.brain.data.newrelic.servers
      last_reported_at = moment(server.last_reported_at).fromNow()
      cpu = "#{(Math.round(server.summary.cpu * 100))}% CPU"
      diskIo = "#{(Math.round(server.summary.disk_io * 100))}% Disk IO"
      memory = "#{server.summary.memory}% (#{humanize.filesize(server.summary.memory_used)} / #{humanize.filesize(server.summary.memory_total)})"
      fullestDisk = "#{server.summary.fullest_disk}% (#{humanize.filesize(server.summary.fullest_disk_free)} free)"
      message.send "(#{server.name}) #{cpu}, #{diskIo}, #{memory}, #{fullestDisk} | #{last_reported_at} @ [https://rpm.newrelic.com/accounts/#{accountId}/servers/#{server.id}]"
