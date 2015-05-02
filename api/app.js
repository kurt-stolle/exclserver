"use strict";

var express = require('express');

var app = express();

app.set('view engine', 'html');
app.set('x-powered-by', false);

var index = require('./routes/index.js'),
  donate = require('./routes/donate.js'),
  servers = require('./routes/servers.js');

app.use('/servers', servers);
app.use('/donate', donate);
app.use('/', index);

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
