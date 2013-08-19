chalk = require 'chalk'

exports.help = (cb) ->
  @logger.help chalk.underline('Boxes')
  @logger.help('')
  @logger.help chalk.cyan('awesomebox push')
  @logger.help chalk.gray("Push a new version of your box up to the server.")
  @logger.help('')
  @logger.help('')
  @logger.help('')
  @logger.help chalk.underline('Users')
  @logger.help('')
  @logger.help chalk.cyan('awesomebox login')
  @logger.help chalk.gray("Come on in! The water is great!")
  @logger.help('')
  @logger.help chalk.cyan('awesomebox logout')
  @logger.help chalk.gray("If you really need to go, then fine. You can go.")
  @logger.help('')
  @logger.help chalk.cyan('awesomebox reserve')
  @logger.help chalk.gray("Not a user yet? Want to be?")
  
  cb()
