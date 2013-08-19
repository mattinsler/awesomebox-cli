chalk = require 'chalk'
errors = require '../errors'

exports.reserve = (cb) ->
  @prompt.get
    properties:
      email:
        required: true
  , (err, data) =>
    return cb(err) if err?
    
    client = @client()
    client.users.reserve data, (err, user) =>
      return cb(err) if err?
      @log('')
      @log "Awesome! We've reserved you a spot."
      @log "Sit tight and we'll send you an email when awesomebox is ready to go!"
      cb()

exports.redeem = (cb) ->
  @prompt.get
    properties:
      email:
        required: true
      reservation:
        required: true
  , (err, data) =>
    return cb(err) if err?
    
    client = @client()
    client.users.redeem data, (err, user) =>
      return cb(err) if err? and err.body?.error isnt 'Required field: password'
      
      @log('')
      @log "Great! We found your reservation."
      @log "You'll have to create a password now."
      @log('')
      
      @prompt.get
        properties:
          password:
            required: true
            hidden: true
      , (err, data2) =>
        return cb(err) if err?
        
        data.password = data2.password
        client.users.redeem data, (err, user) =>
          return cb(err) if err?
          
          @log('')
          @log 'Splendiforous!'
          @log "Well isn't this wonderful news! We invited you in and you came. Oh happy day!"
          @log('')
          @log 'Welcome to ' + chalk.blue.bold('awesomebox') + '!!!'
          @log('')
          @log "Now that you're a user, why don't you try creating a new box."
          @log "Just type #{chalk.cyan('awesomebox push')} from your project folder to get started."
          @log('')
          @log chalk.cyan('awesomebox push') + chalk.gray(" will create a new box on awesomebox.es and push a new")
          @log chalk.gray("version of your box up to the server.")
          
          @login(user)
          
          cb()

exports.me = (cb) ->
  client = @client.keyed()
  return cb(errors.unauthorized()) unless client?
  
  client.me.get (err, user) =>
    return cb(err) if err?
    @log(line) for line in JSON.stringify(user, null, 2).split('\n')
  
    cb()
