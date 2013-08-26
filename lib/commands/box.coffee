chalk = require 'chalk'
errors = require '../errors'
config = require '../config'
Synchronizer = require '../synchronizer'

exports.save = (callback) ->
  client = @client.keyed()
  return cb(errors.unauthorized()) unless client?
  
  box_config = config(process.cwd() + '/.awesomebox')
  
  get_box = (cb) =>
    box = box_config.get('id', 'name')
    unless box.id? and box.name?
      @log "It doesn't look like you've created a box for this project yet."
      return no_box(cb)
    
    client.box(box.id).get (err, box) =>
      if err?
        return cb(err) unless err.status_code is 404
        
        @log "Sorry, it looks like the box for this project no longer exists."
        @log('')
        return no_box(cb)
      
      cb(null, box)
  
  create_box = (cb) =>
    @prompt.get
      properties:
        name:
          required: true
    , (err, data) =>
      return cb(err) if err?
      
      client.boxes.create data, (err, box) =>
        return cb(err) if err?
        box_config.set(box)
        
        @log('')
        @log "Great! Now that you've created a box, we'll save your code to it."
        @log('')
        
        cb(null, box)
  
  no_box = (cb) =>
    client.boxes.list (err, boxes) =>
      return cb(err) if err?
      
      if boxes.length is 0
        @log "Let's fix that. Name your new box."
        @log('')
        create_box(cb)
      else
        @log "Are you saving a box that already exists? Maybe one of these?"
        @log('')
        
        x = 0
        @log "#{++x}) #{b.name}" for b in boxes
        @log "#{++x}) Create a new box"
        @prompt.get
          properties:
            box:
              required: true
              type: 'number'
              conform: (v) ->
                v > 0 and v <= boxes.length + 1
        , (err, data) =>
          return cb(err) if err?
          
          @log('')
          
          if data.box <= boxes.length
            box = boxes[data.box - 1]
            box_config.set(box)
            return cb(null, box)
          
          @log "OK cool. Let's get that new box setup for you."
          @log('')
          create_box(cb)
  
  get_message = (cb) =>
    @log 'Leave a message to remind yourself of the changes you made.'
    @log('')
    @prompt.get
      properties:
        message:
          required: false
    , (err, data) =>
      return cb(err) if err?
      
      @log('')
      cb(null, data.message)
  
  save_code_to_box = (box, cb) =>
    get_message (err, message) =>
      return cb(err) if err?
      box.message = message
      
      @log "Preparing to save #{box.name}..."
      @log('')
      
      synchronizer = new Synchronizer(client)
      synchronizer.sync box, process.cwd(), (msg) =>
        @log msg
      , (err, version) =>
        return cb(err) if err?
        unless version?
          @log "All of your files are up to date. Horay!"
        else
          @log('')
          @log "All done saving #{box.name}!"
          @log "We've created new version " + chalk.cyan(version) + ' for you.'
        cb()
  
  get_box (err, box) ->
    return callback(err) if err?
    save_code_to_box(box, callback)


exports.load = (box_name, box_version, callback) ->
  if typeof box_name is 'function'
    callback = box_name
    box_name = null
    box_version = null
  else if typeof box_version is 'function'
    callback = box_version
    box_version = null
  
  client = @client.keyed()
  return callback(errors.unauthorized()) unless client?
  
  get_box = (name, cb) =>
    return no_box(cb) unless name?
    
    client.box(name).get (err, box) =>
      return cb(err) if err?
      return cb(null, box) if box?
      
      @log "Hmm, doesn't look like you have a box with that name."
      @lob('')
      no_box(cb)
  
  no_box = (cb) =>
    client.boxes.list (err, boxes) =>
      return cb(err) if err?
      
      if boxes.length is 0
        @log "Doesn't look like you have any boxes to load."
        callback()
      else
        @log "Want to load one of these?"
        @log('')
        
        x = 0
        @log "#{++x}) #{b.name}" for b in boxes
        @prompt.get
          properties:
            box:
              required: true
              type: 'number'
              conform: (v) ->
                v > 0 and v <= boxes.length
        , (err, data) =>
          return cb(err) if err?
          
          @log('')
          
          cb(null, boxes[data.box - 1])
  
  get_box box_name, (err, box) =>
    return cb(err) if err?
    console.log box
  
  # box_config = config(process.cwd() + '/.awesomebox')
  

# exports.init = (cb) ->
#   cfg = config(process.cwd() + '/.awesomebox')
#   if cfg.get('id')?
#     @log 'The current directory is already an awesomebox project'
#     return cb()
#   
#   @log 'Initializing current directory as an awesomebox project'
#   
#   cfg.set(id: 1)
#   
#   cb()