(function() {
  var config;

  config = require('../config');

  exports.boxes = function(callback) {
    var client,
      _this = this;
    client = this.client.keyed();
    if (client == null) {
      return callback(errors.unauthorized());
    }
    return client.boxes.list(function(err, boxes) {
      var line, _i, _len, _ref;
      if (err != null) {
        return callback(err);
      }
      _ref = JSON.stringify(boxes, null, 2).split('\n');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        _this.log(line);
      }
      return callback();
    });
  };

  exports.versions = function(box, callback) {
    var box_config, client,
      _this = this;
    client = this.client.keyed();
    if (client == null) {
      return callback(errors.unauthorized());
    }
    if (typeof box === 'function') {
      callback = box;
      box_config = config(process.cwd() + '/.awesomebox');
      if (box_config.get('id') == null) {
        return callback(new Error('Please specify a box name'));
      }
      box = box_config.get('id');
    }
    return client.box(box).versions.list(function(err, versions) {
      var line, _i, _len, _ref;
      if (err != null) {
        return callback(err);
      }
      _ref = JSON.stringify(versions, null, 2).split('\n');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        _this.log(line);
      }
      return callback();
    });
  };

}).call(this);
