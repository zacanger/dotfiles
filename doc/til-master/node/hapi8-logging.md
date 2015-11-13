# Hapi 8.x Logging with Good
Good is used for logging via file/console.
```js
var Good = require('good');
var GoodFile = require('good-file');
var GoodConsole = require('good-console');
```

Implementation requires each reporter to be instantiated and added to the options.reporters.

```js
// example
var options = {};
var opsPath = path.join(__dirname, '..', 'logs', 'server', 'operations');
var errsPath = path.join(__dirname, '..', 'logs', 'server', 'errors');
var reqsPath = path.join(__dirname, '..', 'logs', 'server', 'requests');

// make sure above paths are created
var configWithPath = function(path) {
  return { path: path, extension: 'log', rotate: 'daily', format: 'YYYY-MM-DD-X', prefix:'epochtalk' };
};
var consoleReporter = new GoodConsole({ log: '*', response: '*' });
var opsReporter = new GoodFile(configWithPath(opsPath), { log: '*', ops: '*' });
var errsReporter = new GoodFile(configWithPath(errsPath), { log: '*', error: '*' });
var reqsReporter = new GoodFile(configWithPath(reqsPath), { log: '*', response: '*' });
options.reporters = [ consoleReporter, opsReporter, errsReporter, reqsReporter ];
server.register({ register: Good, options: options}, cb);
```
