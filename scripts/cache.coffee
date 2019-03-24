# Description:
#   Clear CloudFront Cache
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot cache clear (dev|prod)
#

miyoz_cf_ids = {
  'dev': 'E3UZIMZSWN1GVY',
  'prod': 'E1MGXMGX3VH0WC'
  }

module.exports = (robot) ->
  robot.respond /cache clear (\w+)/i, (res) ->
    envName = res.match[1].toLowerCase()
    return res.send "#{envName} is not a valid environment for CloudFront" unless miyoz_cf_ids["#{envName}"]?
    @exec = require('child_process').exec
    command = "/usr/local/bin/aws configure set preview.cloudfront true ; /usr/local/bin/aws cloudfront create-invalidation --distribution-id " + miyoz_cf_ids["#{envName}"] + " --paths '/*' | logger"
    res.reply ":cash: Running away with all your cache!"
    @exec command, (error, stdout, stderr) ->
      res.send stdout
      if stderr
        res.send "ERROR (stderr): " + stderr
      if error
        res.send "ERROR (error)" + error
