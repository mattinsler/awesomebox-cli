async = require 'async'
syncr = require 'syncr'
walkabout = require 'walkabout'

class Synchronizer
  constructor: (@client) ->
    
  sync: (box, root, progress, callback) ->
    root = walkabout(root)
    opts = {}
    if root.join('.awesomeboxignore').exists_sync()
      opts.ignore_file = root.join('.awesomeboxignore').absolute_path
    else
      opts.ignore = ['node_modules', 'bin']
    
    box = @client.box(box.id)
    manifest = null
    delta = null
    
    async.waterfall [
      (cb) -> syncr.create_manifest(root.absolute_path, opts, cb)
      
      (m, cb) =>
        manifest = m
        box.push(manifest: manifest, cb)
      
      (d, cb) =>
        delta = d
        return callback() if delta is true
        
        files_to_send = delta.add.concat(delta.change)
        async.eachSeries files_to_send, (path, send_cb) =>
          progress("Sending #{path}...")
          file_path = root.join(path)
          
          box.push {path: path, hash: manifest.files[path], branch: delta.branch, file: file_path.create_read_stream()}, (err) =>
            if err?
              progress("Sending #{path}... Error: #{err.message}")
              return send_cb(err)
            progress("Sending #{path}... Done")
            send_cb()
        , cb
    ], (err) =>
      return callback(err) if err?
      box.push(done: true, branch: delta.branch, callback)

module.exports = Synchronizer
