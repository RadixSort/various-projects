var cart = [];
var products = [];
var inactiveTime = 300;
var timeoutTracker;
var totalPrice = 0;
var amount = 0;
var Product = function(name, quantity, price, src){
	this.name = name;
	this.price = price;
	this.quantity = quantity
	this.src = src
};
var timeoutVal = document.getElementById("timeoutValue");
var ajaxCount = 0;
var tempProducts = [];
var checkOutSuccess = false;

// Deals with Show Cart Modal 
$(document).ready(function(){
	$("#myModal").hide();
});

function handleRemoveButton(){
	for(i in products){
		$('#list' + i.name).on('mouseenter', function () {
			if($.inArray(i.name, cart)){
				$("#" + i.name).show();
			}
			else{
				$("#" + i.name).hide();
			}
		});
		$('#list' + i.name).on('mouseleave', function () {
				$("#" + i.name).hide();
		});
	}
}


// appneds cart item and details to modal's table 
// TODO: Iterate through cart and add (+/-) buttons per unique item
function refreshModal(){
	$("#cartTable").empty();
	$("#cartTable").append('<tr><td>Product:</td><td>Quantity:</td><td>Price($):</td><td>Actions:</td></tr>');
	for (var i in cart) {
		for ( var j = 0; j < products.length; j++){
	        if (products[j].name == i){
	        	$("#cartTable").append('<tr><td>' + i + '</td><td>' + cart[i] + '</td><td>' + (products[j].price*cart[i]) + '</td><td> <button onclick="addToCart(\'' + i + '\');refreshModal();">+</button><button onclick="removeFromCart(\'' + i + '\'); refreshModal();">-</button></td></tr>');
				
			}
		}
	}
}

$("#showCart").click(function(){
	refreshModal();
	$("#myModal").show();
});

$("#closeCart").click(function(){
	$("#myModal").hide();
});


//functions
function initPage() {
	//initProducts();
	var value = $("#filterValue").val();
	console.log(value);
	getServerRequest(value);
	timer();
	refreshTotal();
}initPage();

function initPrices(){
	for ( var product in products){
		$("#" + products[product].name + "price").html("$" + products[product].price);
	}
}

function displayTimeout(timeout, content) {
	setTimeout(function() {
		window.alert(content);
	}, timeout);
}

function timer() {
	setInterval(function() {
		inactiveTime--;
		timeoutVal.innerHTML = inactiveTime;
		if (inactiveTime <= 0) {
			window.alert("Hey there!  Are you still planning to buy something?");
			inactiveTime = 300;
		}
	}, 1000);
}

function resetTime() {
	inactiveTime = 300;
}

function isEmpty(obj) {
	for (var key in obj) {
		if (obj.hasOwnProperty(key))
			return false;
	}
	return true;
}

function contains(a, obj) {
    for (var i = 0; i < a.length; i++) {
        if (a[i] === obj) {
            return true;
        }
    }
    return false;
}

function addToCart(productName) {
	resetTime();
	handleRemoveButton();
    var exists = false; 
        for ( var obj = 0; obj < products.length; obj++){
	        if (products[obj].name == productName){
	            if (products[obj].quantity > 0) {
					for(var i in cart){
						if(i == productName ){
								cart[i]++;
								exists = true;		
								break;
						}
					}	
					if(!exists){
						document.getElementById([productName]).style.display = "block";
						cart[productName] = 1;
					} 		
					products[obj].quantity--;
				}else{
					alert("This item is not in stock you cannot add it to your cart");
				}
			}
		}
	refreshTotal();
}

function removeFromCart(productName) {
	resetTime();
	handleRemoveButton();
	var exists = false;
	for ( var obj = 0; obj < products.length; obj++){
        if (products[obj].name == productName){
			for(var i in cart){
				if(productName == i){
					if(cart[i] == 1) {
						delete cart[i];
						document.getElementById([productName]).style.display = "none";
					}
					else{
						cart[i]--;
					}
					exists = true;
					products[obj].quantity++;
				}
			}
		}
	}
	if(!exists){
		alert("This Item Is Not In Your Cart!");
	}	
	refreshTotal();
}

function refreshTotal() {
	totalPrice = 0;     
	if (!isEmpty(cart)) {
		for (var i in cart) {
			for ( var j = 0; j < products.length; j++){
		        if (products[j].name == i){
		        	totalPrice += products[j].price * cart[i]
				}
			}
		}
	}   
	document.getElementById("showCart").innerHTML = 'Cost: $' + window.totalPrice;
	document.getElementById("modalTotalPrice").innerHTML = 'Total Cost: $' + window.totalPrice;
	return totalPrice;
}

/*
function initProducts(){
	var Box1 = new Product("Box1", 5, 10);
	var Box2 = new Product("Box2", 5, 5);
	var Clothes1 = new Product("Clothes1", 5, 20);
	var Clothes2 = new Product("Clothes2", 5, 30);
	var Jeans = new Product("Jeans", 5, 50);
	var Keyboard = new Product("Keyboard", 5, 20);
	var KeyboardCombo = new Product("KeyboardCombo", 5, 40);
	var Mice = new Product("Mice", 5, 20);
	var PC1 = new Product("PC1", 5, 350);
	var PC2 = new Product("PC2", 5, 400);
	var PC3 = new Product("PC3", 5, 300);
	var Tent = new Product("Tent", 5, 100);
	products.push(Box1, Box2, Clothes1, Clothes2, Jeans, Keyboard, KeyboardCombo, Mice, PC1, PC2, PC3, Tent);	
	//cart.push(Box1,Clothes2, Tent);
	//console.log(cart.indexOf(Box1));
}*/

function getServerRequest(filter) {
	var xhr = new XMLHttpRequest();

	//xhr.open("GET", "https://assn4-400a.herokuapp.com/products", true);

	xhr.open("GET", "http://localhost:1337/api/products/" + filter, true);
	xhr.timeout = 1000;

	xhr.onload = function() {
		if (xhr.status == 200) {
			for (var i in products) {
				tempProducts[i] = products[i]
			}
			products = [];	
			console.log("Data Retrieved from Server")
			var serverProducts;
			serverProducts = JSON.parse(xhr.response);

			console.log("Paring Data");
			//update products[]
			for (var i in serverProducts) {
				var e = serverProducts[i];
				var p = new Product(e.name, e.quantity, e.price, e.url);
				//renew product list
				if(products.indexOf(p)>0){
					products.pop(p);
				}
			
				products.push(p);
	
			}
				var allProductIDs;
				allProductIDs = document.querySelectorAll('[id^=list]')

				$(allProductIDs).hide();
				
				for (var i = 0; i < allProductIDs.length; i++){
					for ( var j = 0; j < products.length; j++){
						//console.log(allProductIDs[i].id);
						//console.log(products[j].name);
						if (allProductIDs[i].id.includes(products[j].name)){
							$(allProductIDs[i]).show();
						}
					}
				}


			initPrices();
			
		} else if (xhr.status == 500 ){
			window.alert("Internal Server Error 500. Attempt:"+(ajaxCount+1)+"/5");
			if (ajaxCount < 5) {
				ajaxCount++;
				getServerRequest();
			} else {
				window.alert("Connection Failed After "+ajaxCount+" Attempts");
				ajaxCount = 0;
			}
		} else {
			window.alert("HTTP Request Failed; Status: " + xhr.status);
		}
	}

	xhr.ontimeout = function() {
		console.log("Timeout " + ajaxCount);
		if (ajaxCount < 5) {
			ajaxCount++;
			getServerRequest();
		} else {
			window.alert("Connection Failed After "+ajaxCount+" Attempts");
			ajaxCount = 0;
		}
	}
	
	xhr.onerror = function () {
		window.alert("Cannot connect to server");
	}
	
	xhr.send();
}

var checkOut = function() {
	var JSONcart = [];
	for(var i in cart){
		JSONcart.push({name: i, quantity: cart[i]});
	}
	console.log(JSONcart);
	var xhr = new XMLHttpRequest();
	xhr.open("POST", "http://localhost:1337/api/checkout", true);
	xhr.timeout = 1000;
	xhr.onload = function() {
		if (xhr.status == 200) {
			console.log(xhr.getResponseHeader("Content-type"));
					if(xhr.getResponseHeader("Content-type") == 'application/json; charset=utf-8'){
						var orderStatus = JSON.parse(xhr.responseText);
						console.log(orderStatus);
						if(orderStatus.cartValid == 'success'){
							alert("Order Successful! Your total is $" + totalPrice);
							cart = [];
							refreshTotal();
							getServerRequest();
							handleRemoveButton();
						}else{
							console.log(orderStatus.cartValid);
							alert("Order Unsuccessful, one or more items are out of stock.");
							
						}
					}
		}
		else if(xhr.status == 500){
			window.alert("Internal Server Error 500");
		}
	}
	xhr.ontimeout = function() {
		console.log("Timeout " + ajaxCount);
		if (ajaxCount < 5) {
			ajaxCount++;
			getServerRequest();
		} else {
			window.alert("Connection Failed After "+ajaxCount+" Attempts");
			ajaxCount = 0;
		}
	}
	xhr.onerror = function () {
		window.alert("Cannot connect to server");
	}
	xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
	xhr.send(JSON.stringify(JSONcart));
}

function getFilters(filter) {
	var xhr = new XMLHttpRequest();

	//xhr.open("GET", "https://assn4-400a.herokuapp.com/products", true);
	xhr.open("GET", "http://localhost:1337/api/products/" + filter, true);
	xhr.timeout = 1000;

	xhr.onload = function() {
		if (xhr.status == 200) {
			for (var i in products) {
				tempProducts[i] = products[i]
			}
			products = [];	
			console.log("Data Retrieved from Server")
			var serverProducts;
			serverProducts = JSON.parse(xhr.response);

			console.log("Paring Data");
			//update products[]
			for (var i in serverProducts) {
				var e = serverProducts[i];
				var p = new Product(e.name, e.quantity, e.price, e.url);
				//renew product list
				if(products.indexOf(p)>0){
					products.pop(p);
				}
			
				products.push(p);
	
			}
			initPrices();
			
		} else if (xhr.status == 500 ){
			window.alert("Internal Server Error 500. Attempt:"+(ajaxCount+1)+"/5");
			if (ajaxCount < 5) {
				ajaxCount++;
				getServerRequest();
			} else {
				window.alert("Connection Failed After "+ajaxCount+" Attempts");
				ajaxCount = 0;
			}
		} else {
			window.alert("HTTP Request Failed; Status: " + xhr.status);
		}
	}

	xhr.ontimeout = function() {
		console.log("Timeout " + ajaxCount);
		if (ajaxCount < 5) {
			ajaxCount++;
			getServerRequest();
		} else {
			window.alert("Connection Failed After "+ajaxCount+" Attempts");
			ajaxCount = 0;
		}
	}
	
	xhr.onerror = function () {
		window.alert("Cannot connect to server");
	}
	
	xhr.send();
}