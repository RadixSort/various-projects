var express = require('express');
var path = require('path');
var bodyParser = require('body-parser');
var app = express();

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
app.use(bodyParser.json())

app.set('port', (process.env.PORT || 1337));
app.use(express.static(__dirname + '/client'));

app.use("/styles",  express.static(__dirname + '/client/css'));
app.use("/scripts", express.static(__dirname + '/client/js'));
app.use("/images",  express.static(__dirname + '/client/images'));

app.get('/', function(request, response) {
	response.sendFile( path.join( __dirname, 'client', 'index.html' ));
 
});

app.get('/api/products/:filter', function(request, response) {
	db.open(function(err, db) {
		var JSONproducts;
		var filter = request.params.filter;
		console.log(request.params.filter);
		if (err) {
			console.log('Unable to connect to the mongoDB server. Error:', err);
	  	} else {
	    //HURRAY!! We are connected. :)
	    console.log('Connection established.');

	    // do some work here with the database.
	   
	    getProducts(filter,function(data){
	    	//console.log(data[0]);
	    	JSONproducts = JSON.stringify(data);
	    	//console.log(JSONproducts);
	    	//console.log(JSONproducts);
	    	response.setHeader('Content-Type', 'application/json');
			response.send(JSONproducts);
		});
		if (err) {
	        console.log(err);
	      } else {
	      	console.log("Success.");
	    
	      }

	    //Close connection
	    db.close();
	  }
	});
});

app.post('/api/checkout', function(request, response) {
	response.header("Access-Control-Allow-Origin", "*");
    response.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");

	db.open(function(err, db) {
		if (err) {
			console.log('Unable to connect to the mongoDB server. Error:', err);
	  	} else {

		    var cart = request.body;
		    var cartdiff = JSON.stringify(cart);
		    var cartdiff = JSON.parse(cartdiff);
		    var valid = true;
		    var total = 0;
		    getCheckoutProducts(function(data){
		    	console.log(data);
		    	console.log(cart);
		    	for(var i in cart){
		    		for(var j in data){
		    			if(data[j].name == cart[i].name){
		    				if(data[j].quantity < cart[i].quantity){
								valid = false;	
		    				}
		    				else{
		    					cartdiff[i].quantity = parseInt(data[j].quantity) - parseInt(cart[i].quantity);
		    					total = total + (parseInt(cart[i].quantity) * parseInt(data[j].price));

		    				}
		    				
		    			}
		    		}
		    	}
		    
		    	if(valid){
		    		
			    	var __orders = db.collection('orders');
					var JSONorders = {cart: cart, total: total};
					__orders.insert(JSONorders);

					console.log(cartdiff);
		    	for(var i in cartdiff){

		    		
		    		db.collection('products').findAndModify(
					  {name: cartdiff[i].name}, 
					  [['_id','asc']],  
					  {$set: {quantity: cartdiff[i].quantity}},
					  {}, 
					  function(err, object) {
					      if (err){
					          console.warn(err.message);  // returns error if no matching object found
					      }else{
					      	db.close();
					        console.dir(object);
					      }
					  });
		    	}
		    	response.send({cartValid: 'success'});
			}
			else{
				response.send({cartValid: 'failed'});
				db.close();
			}
		   
			});
		    
		    //Close connection
	  	}
	});
});

app.listen(app.get('port'), function() {
  console.log("Node app is running at localhost:" + app.get('port'))
});

function getProducts(filter, callback){	
	var __products = db.collection('products');
		// Peform a simple find and return all the documents
		console.log(filter);
      		var cast = Number(filter);

      		var __query = {price: {$gt: cast}}; 
      		__products.find(__query).toArray(function(err, res) {
	      			if(err){
	      			console.log("Unable to get products.");
	      		}
	      		else{
	      			console.dir(res);
      				var obj = res;
					callback(obj);
      			}	
			});
}

function getCheckoutProducts(callback){	
	var __products = db.collection('products');
		// Peform a simple find and return all the documents
	      	__products.find().toArray(function(err, res) {
	      			if(err){
	      			console.log("Unable to get products.");
	      		}
	      		else{
      				var obj = res;
					callback(obj);
      			}	
			});
      
}
