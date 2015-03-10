/* Copyright 2015 PayPal */
"use strict";

var generate = require('../generate');
var api = require('../api');
var https = require('https');
var crypto = require('crypto');
var crc32 = require('buffer-crc32');

/**
 * Exposes REST endpoints for creating and managing webhooks
 * @return {Object} webhook functions
 */
function webhook() {
    var baseURL = '/v1/notifications/webhooks/';
    var operations = ['create', 'list', 'get', 'del', 'delete'];

    var ret = {
        baseURL: baseURL,
        replace: function replace(id, data, config, cb) {
            api.executeHttp('PATCH', this.baseURL + id, data, config, cb);
        },
        eventTypes: function eventTypes(id, config, cb) {
            api.executeHttp('GET', this.baseURL + id + '/event-types', {}, config, cb);
        }
    };
    ret = generate.mixin(ret, operations);
    return ret;
}

/**
 * Exposes REST endpoints for working with subscribed webhooks events
 *
 * https://developer.paypal.com/webapps/developer/docs/integration/direct/rest-webhooks-overview/#events
 * @return {Object} webhook event functions
 */
function webhookEvent() {
    var baseURL = '/v1/notifications/webhooks-events/';
    var operations = ['list', 'get'];

    function verifyPayload(key, msg, hash) {
        return crypto.createVerify('sha1WithRSAEncryption')
            .update(msg)
            .verify(key, hash, 'base64');
    }

    function verify(certURL, transmissionId, timeStamp, webhookId, eventBody, ppTransmissionSig, cb) {
        https.get(certURL, function (res) {
            var cert = '';
            res.on('error', function (e) {
                console.log('problem with request' + e.message);
                cb(e, null);
            });
            res.on('data', function (chunk) {
                cert += chunk;
            });
            res.on('end', function () {
                var err = null;
                var response = false;
                try {
                    var expectedSignature = transmissionId + "|" + timeStamp + "|" + webhookId + "|" + crc32.unsigned(eventBody);
                    response = verifyPayload(cert, expectedSignature, ppTransmissionSig);
                } catch (e) {
                    err = new Error("Error verifying webhook payload.");
                }
                cb(err, response);
            });
        });
    }

    var ret = {
        baseURL: baseURL,
        verify: verify,
        resend: function resend(id, config, cb) {
            api.executeHttp('POST', this.baseURL + id + '/resend', {}, config, cb);
        }
    };
    ret = generate.mixin(ret, operations);
    return ret;
}

/**
 * Exposes REST endpoint for listing available event types for webhooks
 * @return {Object} webhook event type functions
 */
function webhookEventType() {
    var baseURL = '/v1/notifications/webhooks-event-types/';
    var operations = ['list'];

    var ret = {
        baseURL: baseURL
    };
    ret = generate.mixin(ret, operations);
    return ret;
}

/**
 * Exposes the namespace for webhook and webhook event functionalities
 * 
 * https://developer.paypal.com/webapps/developer/docs/api/#notifications
 * @return {Object} notification functions
 */
function notification() {
    return {
        webhook: webhook(),
        webhookEvent: webhookEvent(),
        webhookEventType: webhookEventType()
    };
}

module.exports = notification;
