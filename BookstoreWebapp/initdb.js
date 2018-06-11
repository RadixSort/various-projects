//init xmlrequests in node
//var request = require("xmlhttprequest").XMLHttpRequest;
//Initialized connection to products server
var http = require('http');
var serverProducts = '';
//lets require/import the mongodb native drivers.
var Db = require('mongodb').Db,
    MongoClient = require('mongodb').MongoClient,
    server = require('mongodb').Server,
    ReplSetServers = require('mongodb').ReplSetServers,
    ObjectID = require('mongodb').ObjectID,
    Binary = require('mongodb').Binary,
    GridStore = require('mongodb').GridStore,
    Grid = require('mongodb').Grid,
    Code = require('mongodb').Code;
    //BSON = require('mongodb').pure().BSON,
    //assert = require('assert');

var db = new Db('test', new server('localhost', 27017));

var options = {
	host: 'localhost',
	path: '/products',
	port: '5000',
	method: 'GET',
	headers: { 'Contest-Type': 'application/json' }

}

callback = function(response){
	var str = '';
	
	//concate all chunks of data from products server to str
	response.on('data', function (chunk){
		str += chunk;
	});

	//the whole response has been recieved
	response.on('end', function(){
		console.log('str: ' + str);
		serverProducts = str;
	});
	//the whole response has been recieved
	response.on('error', function(e){
		console.log('Error requesting products.' + e.message);
	});
}

http.request(options, callback).end();

db.open(function(err, db) {
  if (err) {
    console.log('Unable to connect to the mongoDB server. Error:', err);
  } else {
    //HURRAY!! We are connected. :)
    console.log('Connection established.');

    // do some work here with the database.
	var __products = db.collection('products');
	//__products.insert(serverProducts);
	var JSONproducts = JSON.parse(serverProducts);
	for(var obj in JSONproducts){

		var temp = JSONproducts[obj];
		temp["name"] = obj;
		var JSONproduct = temp;
		__products.insert(JSONproduct);
	}	

	var __orders = db.collection('orders');
	var JSONorders = {cart: '', total:''};
	__orders.insert(JSONorders);

	var __users = db.collection('users');
	var JSONusers = {token: ''};
	__users.insert(JSONusers);
	
	if (err) {
        console.log(err);
      } else {
      	console.log("Products Initiated.");
      }

    //Close connection
    db.close();
  }
});

