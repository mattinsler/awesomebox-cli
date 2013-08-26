chalk = require 'chalk'

config = require './config'
errors = require './errors'
Commandment = require 'commandment'
AwesomeboxClient = require 'awesomebox.node'

module.exports = commands = new Commandment(name: 'awesomebox', command_dir: __dirname + '/commands')
awesomebox_config = config(require('osenv').home() + '/.awesomebox')

handle_error = (err) ->
  if errors.is_unauthorized(err)
    @logger.error('')
    @logger.error "Whoa there friend. You should probably login first."
    @logger.error('')
    return
  
  console.log err
  text = err.body?.error
  text ?= err.body
  text ?= err.message
  text ?= JSON.stringify(err, null, 2)
  
  @logger.error('')
  @logger.error(line) for line in text.split('\n')
  @logger.error('')


header = ->
  @logger.info 'Welcome to ' + chalk.blue.bold('awesomebox')
  @logger.info 'You are using v' + chalk.cyan(require('awesomebox/package').version)

footer = ->
  @logger.info chalk.green.bold('ok')


commands.before_execute (context, next) ->
  context.awesomebox_config = awesomebox_config
  
  context.client = (auth = {}) ->
    server = context.opts.server or context.awesomebox_config.get('server')
    auth.base_url = server if server?
    
    context.last_client = new AwesomeboxClient(auth)
  
  context.client.keyed = ->
    key = context.awesomebox_config.get('api_key')
    return null unless key?
    context.client(api_key: key)
  
  context.login = (user) ->
    user.server = context.last_client._rest_options.base_url
    context.awesomebox_config.set(user)
  
  context.logout = ->
    context.awesomebox_config.unset('api_key', 'email', 'server')
  
  next()

commands.before_execute (context, next) ->
  header.call(context)
  context.log('')
  next()

commands.after_execute (context, err, next) ->
  handle_error.call(context, err) if err?
  context.log('')
  footer.call(context)
  next()
