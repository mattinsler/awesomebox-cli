(function() {
  var AwesomeboxClient, Commandment, awesomebox_config, chalk, commands, config, errors, footer, handle_error, header;

  chalk = require('chalk');

  config = require('./config');

  errors = require('./errors');

  Commandment = require('commandment');

  AwesomeboxClient = require('awesomebox.node');

  module.exports = commands = new Commandment({
    name: 'awesomebox',
    command_dir: __dirname + '/commands'
  });

  awesomebox_config = config(require('osenv').home() + '/.awesomebox');

  handle_error = function(err) {
    var line, text, _i, _len, _ref, _ref1;
    if (errors.is_unauthorized(err)) {
      this.logger.error('');
      this.logger.error("Whoa there friend. You should probably login first.");
      this.logger.error('');
      return;
    }
    console.log(err);
    text = (_ref = err.body) != null ? _ref.error : void 0;
    if (text == null) {
      text = err.body;
    }
    if (text == null) {
      text = err.message;
    }
    if (text == null) {
      text = JSON.stringify(err, null, 2);
    }
    this.logger.error('');
    _ref1 = text.split('\n');
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      line = _ref1[_i];
      this.logger.error(line);
    }
    return this.logger.error('');
  };

  header = function() {
    this.logger.info('Welcome to ' + chalk.blue.bold('awesomebox'));
    return this.logger.info('You are using v' + chalk.cyan(require('awesomebox/package').version));
  };

  footer = function() {
    return this.logger.info(chalk.green.bold('ok'));
  };

  commands.before_execute(function(context, next) {
    context.awesomebox_config = awesomebox_config;
    context.client = function(auth) {
      var server;
      if (auth == null) {
        auth = {};
      }
      server = context.opts.server || context.awesomebox_config.get('server');
      if (server != null) {
        auth.base_url = server;
      }
      return context.last_client = new AwesomeboxClient(auth);
    };
    context.client.keyed = function() {
      var key;
      key = context.awesomebox_config.get('api_key');
      if (key == null) {
        return null;
      }
      return context.client({
        api_key: key
      });
    };
    context.login = function(user) {
      user.server = context.last_client._rest_options.base_url;
      return context.awesomebox_config.set(user);
    };
    context.logout = function() {
      return context.awesomebox_config.unset('api_key', 'email', 'server');
    };
    return next();
  });

  commands.before_execute(function(context, next) {
    header.call(context);
    context.log('');
    return next();
  });

  commands.after_execute(function(context, err, next) {
    if (err != null) {
      handle_error.call(context, err);
    }
    context.log('');
    footer.call(context);
    return next();
  });

}).call(this);
