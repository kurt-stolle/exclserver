var express = require('express');
var routes = require('./routes/index');

var app = express();

app.set('view engine', 'html');
app.set('x-powered-by', false);

app.use('/', routes);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.send(String(err.status || 500) + ": " + err.message)
});

module.exports = app;
