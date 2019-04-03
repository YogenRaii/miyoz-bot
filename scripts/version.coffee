# Description:
#   Fetch the current QCollect API Versions
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   ver (dev|prod)
#

qcollect_api_urls = {
  'local': 'http://localhost:8082'
  'dev': 'http://dev-api.qlocate.com:8080',
  'prod': 'http://api.qlocate.com:8080'
  }

qcollect_ui_urls = {
  'local': 'http://dev.qlocate.com'
  'dev': 'http://dev.qlocate.com',
  'prod': 'http://qlocate.com'
  }

options =
  rejectUnauthorized: false

module.exports = (robot) ->
  robot.hear /^ver (\w+)/i, (res) ->
    envName = res.match[1].toLowerCase()
    return res.send "#{envName} is not a valid environment for UI" unless qcollect_ui_urls["#{envName}"]?
    return res.send "#{envName} is not a valid environment for the API" unless qcollect_api_urls["#{envName}"]?
    robot.http(qcollect_api_urls["#{envName}"] + "/api/v0.1/version", options)
      .get() (err, response, body) ->
        if response.statusCode isnt 200
          res.send 'API be like http://httpcats.herokuapp.com/' + response.statusCode + '.jpg'
          return
        versionString = JSON.parse(body)
        res.send "API is at " + versionString.version
    robot.http(qcollect_ui_urls["#{envName}"] + "/version.txt", options)
      .get() (err, response, body) ->
        if response.statusCode isnt 200
          res.send 'UI be like http://httpcats.herokuapp.com/' + response.statusCode + '.jpg'
          return
        res.send "UI is at " + body

