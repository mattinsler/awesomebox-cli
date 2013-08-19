exports.login = (cb) ->
  @prompt.get
    properties:
      email:
        required: true
      password:
        required: true
        hidden: true
  , (err, data) =>
    return cb(err) if err?
    
    client = @client(data)
    client.me.get (err, user) =>
      return cb(err) if err?
      
      @login(user)
      
      @log('')
      @log "Welcome back! It's been way too long."
      
      cb()

exports.logout = (cb) ->
  @logout()
  @log "We're really sad to see you go. =-("
  cb()
