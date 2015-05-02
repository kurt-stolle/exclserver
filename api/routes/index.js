"use strict";

var express = require('express');

// INIT ROUTER
var router = express.Router();


/* GET home page. */
router.get('/', function(req, res, next) {
  res.send('ExclServer API running!');
});

module.exports = router;
