(function() {
  var async, nopt;

  async = require('async');

  nopt = require('commandment/node_modules/nopt');

  exports.__default__ = function(cb) {
    var awesomebox, opts, server, _ref, _ref1, _ref2, _ref3,
      _this = this;
    awesomebox = this.get('awesomebox');
    opts = nopt({
      watch: Boolean,
      'hunt-port': Boolean,
      port: Number,
      open: Boolean
    }, {
      p: '--port'
    }, process.argv);
    if ((_ref = opts.watch) == null) {
      opts.watch = true;
    }
    if ((_ref1 = opts['hunt-port']) == null) {
      opts['hunt-port'] = true;
    }
    if (process.env.PORT != null) {
      if ((_ref2 = opts.port) == null) {
        opts.port = Number(process.env.PORT);
      }
    }
    if ((_ref3 = opts.open) == null) {
      opts.open = true;
    }
    server = new awesomebox.Server(opts);
    return server.start().then(function() {
      var host, port, _ref4;
      _this.log('Listening on port', server.address.port);
      if (opts.open === true) {
        host = (_ref4 = server.address.address) === '0.0.0.0' || _ref4 === '127.0.0.1' ? 'localhost' : server.address.address;
        port = server.address.port;
        return require('open')("http://" + host + ":" + port + "/");
      }
    })["catch"](function(err) {
      var line, _i, _len, _ref4;
      _ref4 = err.stack.split('\n');
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        line = _ref4[_i];
        _this.error(line);
      }
      return process.exit(1);
    });
  };

}).call(this);
