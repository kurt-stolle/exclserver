"use strict";

var mysql = require('mysql');

// CREATE DB CONNECTION
var db = mysql.createConnection({
  host     : '192.95.30.86',
  user     : 'exclserver',
  password : '#x6eQ56m593r83b5mky2YvbeP64E2MyQP',
  database : 'exclserver',
  port     : 3306
});

// EXPORT
module.exports=db;
