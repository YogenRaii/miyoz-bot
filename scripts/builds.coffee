# Description:
#   Tag and build a project
#
# Dependencies:
#   "hubot-auth": "^2.1.0"
#
# Configuration:
#   None
#
# Commands:
#   build <FE|BE> b:<source branch> v:<version> e:<environment> (requires 'builder' role)
#
# Notes:
#   Requires user to be in hubot-auth role of 'builder'

module.exports = (robot) ->
  robot.hear /build (be|fe)(?: b:)?([0-9a-zA-Z.\/-]+)? v:(1.[0-9].[0-9]+) e:(dev|prod)/i, (msg) ->
    branchPattern = ///(?:b:)([0-9a-zA-Z.\/-]+)///i
    envPattern=///(?:e:)(dev|prod)///
    versionPattern=///(?:v:)(1.[0-9.-]+)///

    messageString = msg.match[0]

    bresult = messageString.match(branchPattern)
    eresult = messageString.match(envPattern)
    vresult = messageString.match(versionPattern)

    branch = if bresult then bresult[1] else 'develop'
    env = if eresult then eresult[1].toLowerCase() else msg.send "Please provide valid environment"
    ver = if vresult then vresult[1] else msg.send "Please provide valid version"

    project = msg.match[1].toLowerCase()
    role = 'builder'
    user = robot.brain.userForName(msg.message.user.name)
    if project is 'fe'
      return "Cannot build production for FE" if env is 'prod'

    return msg.reply "#{name} does not exist" unless user?
    unless robot.auth.hasRole(user, role)
      msg.reply "I can't do what you ask, you don't have sufficient permission..."
      msg.reply "#{msg.envelope.user.name} has roles " + robot.auth.userRoles(user) + "! Ask him to give you builder permission."
    else
      @exec = require('child_process').exec
      command = "#{process.env.BASE_PATH}/scripts/#{project}_build.sh -b #{branch} -e #{env} -v #{ver} -u #{msg.message.user.name}"
      msg.reply ":meeseeks: Ooooo yeah, caaaan doo!"
      @exec command, (error, stdout, stderr) ->
        msg.send stdout
        if stderr
          msg.send "ERROR (stderr): " + stderr
        if error
          msg.send "ERROR (error)" + error
