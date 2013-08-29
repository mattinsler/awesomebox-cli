config = require '../config'

exports.boxes = (callback) ->
  client = @client.keyed()
  return callback(errors.unauthorized()) unless client?
  
  client.boxes.list (err, boxes) =>
    return callback(err) if err?
    @log(line) for line in JSON.stringify(boxes, null, 2).split('\n')
  
    callback()

exports.versions = (box, callback) ->
  client = @client.keyed()
  return callback(errors.unauthorized()) unless client?
  
  if typeof box is 'function'
    callback = box
    box_config = config(process.cwd() + '/.awesomebox')
    return callback(new Error('Please specify a box name')) unless box_config.get('id')?
    box = box_config.get('id')
  
  client.box(box).versions.list (err, versions) =>
    return callback(err) if err?
    @log(line) for line in JSON.stringify(versions, null, 2).split('\n')

    callback()
