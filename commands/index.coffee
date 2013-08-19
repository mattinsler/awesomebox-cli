fs = require 'fs'

for file in fs.readdirSync(__dirname) when file[0] isnt '.' and file.indexOf('index.') isnt 0
  for k, v of require(__dirname + '/' + file)
    exports[k] = v
