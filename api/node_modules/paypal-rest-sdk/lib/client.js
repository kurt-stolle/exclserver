/* Copyright 2015 PayPal */
"use strict";

var http = require('http');
var https = require('https');
var querystring = require('querystring');
var uuid = require('node-uuid');
var configuration = require('./configure');

/**
 * Wraps the http client, handles request parameters, populates request headers, handles response
 * @param  {String}   http_method        HTTP Method GET/POST
 * @param  {String}   path               url endpoint
 * @param  {Object}   data               Payload for HTTP Request
 * @param  {Object}   http_options_param Configuration parameters
 * @param  {Function} cb                 [description]
 */
var invoke = exports.invoke = function invoke(http_method, path, data, http_options_param, cb) {
    var client = (http_options_param.schema === 'http') ? http : https;

    var request_data = data;

    if (http_method === 'GET') {
        //format object parameters into GET request query string
        if (typeof request_data !== 'string') {
            request_data = querystring.stringify(request_data);
        }
        if (request_data) {
            path = path + "?" + request_data;
            request_data = "";
        }
    } else if (typeof request_data !== 'string') {
        request_data = JSON.stringify(request_data);
    }

    var http_options = {};

    if (http_options_param) {

        http_options = JSON.parse(JSON.stringify(http_options_param));

        if (!http_options.headers) {
            http_options.headers = {};
        }
        http_options.path = path;
        http_options.method = http_method;
        if (request_data) {
            http_options.headers['Content-Length'] = Buffer.byteLength(request_data, 'utf-8');
        }

        if (!http_options.headers.Accept) {
            http_options.headers.Accept = 'application/json';
        }

        if (!http_options.headers['Content-Type']) {
            http_options.headers['Content-Type'] = 'application/json';
        }

        if (http_method === 'POST' && !http_options.headers['PayPal-Request-Id']) {
            http_options.headers['PayPal-Request-Id'] = uuid.v4();
        }

        http_options.headers['User-Agent'] = configuration.userAgent;
    }

    var req = client.request(http_options);

    req.on('error', function (e) {
        console.log('problem with request: ' + e.message);
        cb(e, null);
    });

    req.on('response', function (res) {
        var response = '';
        res.setEncoding('utf8');

        res.on('data', function (chunk) {
            response += chunk;
        });

        res.on('end', function () {
            var err = null;

            try {
                //Set response to be parsed JSON object if data received is json
                //expect that content-type header has application/json when it
                //returns data
                if (res.headers['content-type'] === "application/json") {
                    response = JSON.parse(response);
                }
                //Set response to an empty object if no data was received
                if (response === '') {
                    response = {};
                }
                response.httpStatusCode = res.statusCode;

                //TURN NODE_ENV to development to get access to paypal-debug-id
                //for questions to merchant technical services. Similar convention
                //to express.js
                if (res.headers['paypal-debug-id'] !== undefined && process.env.NODE_ENV === 'development') {
                    console.log(res.headers['paypal-debug-id']);
                }
            } catch (e) {
                err = new Error('Invalid JSON Response Received');
                err.error = {
                    name: 'Invalid JSON Response Received, JSON Parse Error'
                };
                // response contains the full json description of the error
                // that PayPal returns and information link
                err.response = response;
                err.httpStatusCode = res.statusCode;
                response = null;
            }

            if (!err && (res.statusCode < 200 || res.statusCode >= 300)) {
                err = new Error('Response Status : ' + res.statusCode);
                err.response = response;
                err.httpStatusCode = res.statusCode;
                response = null;
            }
            cb(err, response);
        });
    });

    if (request_data) {
        req.write(request_data);
    }
    req.end();
};
