(function() {
  var Synchronizer, async, syncr, walkabout;

  async = require('async');

  syncr = require('syncr');

  walkabout = require('walkabout');

  Synchronizer = (function() {

    function Synchronizer(client) {
      this.client = client;
    }

    Synchronizer.prototype.sync = function(box, root, progress, callback) {
      var delta, manifest, opts,
        _this = this;
      root = walkabout(root);
      opts = {};
      if (root.join('.awesomeboxignore').exists_sync()) {
        opts.ignore_file = root.join('.awesomeboxignore').absolute_path;
      } else {
        opts.ignore = ['node_modules', 'bin'];
      }
      box = this.client.box(box.id);
      manifest = null;
      delta = null;
      return async.waterfall([
        function(cb) {
          return syncr.create_manifest(root.absolute_path, opts, cb);
        }, function(m, cb) {
          manifest = m;
          return box.push({
            manifest: manifest
          }, cb);
        }, function(d, cb) {
          var files_to_send;
          delta = d;
          if (delta === true) {
            return callback();
          }
          files_to_send = delta.add.concat(delta.change);
          return async.eachSeries(files_to_send, function(path, send_cb) {
            var file_path;
            progress("Sending " + path + "...");
            file_path = root.join(path);
            return box.push({
              path: path,
              hash: manifest.files[path],
              branch: delta.branch,
              file: file_path.create_read_stream()
            }, function(err) {
              if (err != null) {
                progress("Sending " + path + "... Error: " + err.message);
                return send_cb(err);
              }
              progress("Sending " + path + "... Done");
              return send_cb();
            });
          }, cb);
        }
      ], function(err) {
        if (err != null) {
          return callback(err);
        }
        return box.push({
          done: true,
          branch: delta.branch,
          message: box.message
        }, callback);
      });
    };

    return Synchronizer;

  })();

  module.exports = Synchronizer;

}).call(this);
