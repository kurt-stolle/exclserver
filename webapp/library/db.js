"use strict";

module.exports=(require('mysql')).createConnection((JSON.parse((require("fs")).readFileSync('../config.json'))).mysql);
