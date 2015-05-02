"use strict";


var express = require('express'),
  paypal = require('paypal-rest-sdk'),
  mysql = require('mysql'),
  db = require('../library/db.js');

// CONFIG
var host='https://es2-api.casualbananas.com'; // Local IP address or DNS name.
var community_name="Casual Bananas";
paypal.configure({
  'mode': 'live',
  'client_id': 'AejZo6UZ8k173xayK0qk1hBuUdY67YmzyTwZ6iM6G0wSIf1LzVgmuH9yIEak6dkWHqFh3oriStak5qyt',
  'client_secret': 'EPzgf8XX42pY0i9eeAbmqoK2ZaDBRLzVj8vDIx6JsGkerS5Nq-4sehpx6O5yB1oT9Vk_Rd6ZWbf_uQph'
});

// DB SETUP
db.query("CREATE TABLE IF NOT EXISTS `es_donations` (`id` int unsigned not null AUTO_INCREMENT, paid bool, claimed bool, name varchar(255), email varchar(255), steamid varchar(255), amount int unsigned, ip varchar(255), payment_id varchar(255), payer_id varchar(255), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;",function(){
  console.log("Successfully setup donation tables.");
});


// INIT ROUTER
var router = express.Router();

/* GET paypal donation start */
router.get('/', function(req, res, next){
  var amt=Number(req.query.amt);
  var sid=String(req.query.sid);

  if ( !amt || isNaN(amt) || amt <= 0 || !sid ) {
    next(new Error("Internal server error. No valid SteamID or donation amount provided."));
    return;
  }

  amt=Math.ceil(amt);

  var reward=amt * 1000;

  var create_payment_json = {
      "intent": "sale",
      "payer": {
          "payment_method": "paypal"
      },
      "redirect_urls": {
          "return_url": host+"/donate/return",
          "cancel_url": host+"/donate/cancel"
      },
      "transactions": [{
          "item_list": {
              "items": [{
                  "name": "1000 Bananas (digital goods)",
                  "sku": "bananas",
                  "price": "1.00",
                  "currency": "USD",
                  "quantity": amt
              }]
          },
          "amount": {
              "currency": "USD",
              "total": String(amt)+".00"
          },
          "description": String(reward)+" Bananas (digital goods) for SteamID "+sid+" on all "+community_name+" game servers."
      }]
  };

  paypal.payment.create(create_payment_json, function (error, payment) {
      if (error) {
          next(new Error("Internal server error. No connection with PayPal API possible."));
          return;
      } else {
          db.query("INSERT INTO `es_donations` (steamid,amount,ip,payment_id) VALUES(?,?,?,?);",[sid,amt,req.connection.remoteAddress,payment.id],function(error){
            if (error) {
                return;
            }
          });

          for (var i=0; i < payment.links.length; i++){
            var link=payment.links[i];
            if(link.rel=="approval_url"){
              res.redirect(link.href);
              break;
            }
          }
      }
  });
});

/* GET paypal donation cancelled */
router.get('/cancel',function(req,res,next){
  res.send('Order cancelled. You may now close this window.');
});

/* GET paypal donation return */
router.get('/return',function(req,res,next){
  var payer_id=req.query.PayerID;
  var payment_id=req.query.paymentId;
  if (!payer_id || !payment_id){
    next(new Error("Internal server error. PayPal did not return valid arguments."));
    return;
  }

  paypal.payment.execute(payment_id, { "payer_id": payer_id }, function(error, payment){
    if(error){
      next(new Error("Internal server error. No connection with PayPal API possible."));
      return;
    } else {
      var payer_info=payment.payer.payer_info;
      db.query("UPDATE `es_donations` SET paid = 1, claimed = 0, email = ?, payer_id = ?, name = ? WHERE payment_id = ?;",[payer_info.email,payer_info.payer_id,(payer_info.first_name+" "+payer_info.last_name),payment_id],function(error){
        if (error) {
            return;
        }
      });
      res.send('Donation successful! You may now close this window.');
    }
  });
});

module.exports = router;
