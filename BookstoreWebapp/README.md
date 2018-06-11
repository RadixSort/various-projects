# Assignment5

In this assignment we will focus on building the backend for the bookstore. You can clone the code from https://github.com/erkartik91/cpen400/ (as given in the previous assignment) to setup your own server on your local machine.
You will need node.js to complete this assignment, so please install node.js if you haven't done so yet. 

## Tasks
1. **Setup mongoDB Database:** (3 points) You will need to install mongoDB on your laptop. You can find the instructions to install mongoDB [here](https://docs.mongodb.org/manual/installation/). You will need to create the following collections for this assignment. For each collection, you should provide an example of a document, so your document should look similar to the one below. For the products collection, populate it with **all the existing products defined in the previous assignments**. You can also store the product information available at https://cpen400a.herokuapp.com/products into your own database. Organize all the collection initialization into a **single JS script**. If your JS script is named "initdb.js", you can initialize the collections with the single command "load(initdb.js)" in the mongo shell.
  ```
  products
  {
    "_id" : ObjectId("564523c89a9b1a2a4ae35ebe"),
    "name" : "PC1",
    "price" : 32,
    "quantity" : 32,
    "image" : "pathToImage"
  }
  
  orders
  {
    "_id" : ObjectId("f40f3qjfasdfsafssasaadf2"),
    "cart" : "JsonStringForCartObject",
    "total" : 117
  }
  
  users
  {
    "_id" : ObjectId("2fewj90fjadkslsdkfnaldfa"),
    "token" : "Xoe2inasd"
  }
  
  ```
  
  Note that mongoDB will automatically create "_id" field(with unique value) for each documented created. You are free to add your own "id" field for each document if needed. There are many good mongoDB tutorials online, [here](https://docs.mongodb.org/manual/core/crud-introduction/) is one of them. For debug purposes, you can also install RoboMongo which provide an easy GUI.

2. **Fetch products from database:** (2 points) Follow [this](https://docs.mongodb.org/ecosystem/drivers/node-js/) tutorial on how to install nodejs driver for mongoDB. Once you have mongoDB connection setup correctly, you will need to create a GET endpoint /products to allow users to fetch all products from your database.

3. **Adding filters:** (3 points) Add price filters to your /products endpoint to allow users to retrieve all products between a specified price range (inclusive). You will need to carefully consider checking erroneous values in your filters - if an erroneous filter is supplied, an error response with an **appropriate HTTP error code** should be returned. If no filters are supplied to the GET products endpoint, all products should be returned in the response. If filters are supplied, a subset of the products should be returned according to the conditions. **This task should be completed on the server side only.** 

4. **Add Checkout functionality:** (3 points) You will need to create a POST endpoint /checkout in your application. The end point will accept a JSON formatted object (cart) and total as parameters that you will need to store in your orders table. The checkout should also update your products table. In addition to the server side changes, you will need to update the JavaScript code in your web application to make this POST request when the user clicks on the *checkout* button. Any alerts included in the last assignment may be removed. This task is only considered complete when you have the checkout functionality working completely full stack.

5. **BONUS (1 point): Add authentication to AJAX calls:** Till now, all the AJAX calls that you made to your server had no authentication. However, to prevent misuse of your backend, you need to add authentication to your ajax calls. Any call to fetch product list or checkout should be accompained with a valid token. You can add some entries in your user collection. You will then need to update both /products and /checkpoint endpoint to check for valid token in the request. For now, you can hard code the token from your user table in your JavaScript code. Alternatively, you can prompt the user for authentication details when the page first loads (optional). You will need to send a token as one of the parameters with the ajax calls to both fetch product list and checkout cart. When you receive the reruest, you need to validate that token passed in the request exists in the user collection. If there is no token or the token passed is invalid, you need to provide a response with error code 401.

6. **BONUS (0.5 points): Add filtering by product category:** In your front-end application, you have several product categories listed in your navigation menu on the left. Examples include "Clothing" and "Stationary". Implement a filter on your server application to return products belonging to a certain cateogry and display only those products on the client side when interfacing with the navigation menu. Pressing "All Items" should remove all filters. Please use your judgement on categorizing the products. You will only receive this credit if you implement this on **both the server and client.**

## Code Quality

(4 points) As this is your last assignment, please ensure that all code is clean and easy to read. You should be able to deliver this code on to a new web developer without written documentation. 
You should ensure that your JavaScript code follows the best practices around variable/function naming, variable placement, modularization (dividing long code blocks into smaller functions) and comments (your comments should explain why a design choice was taken, instead of how your code works). Please also ensure that no constants are hardcoded and no code is purposely commented out. Your solution will be assessed for code quality during marking.

## Submission instructions:

* Copy the code from your assignment 4
* Update the code to reflect the changes for this assignment.
* Create a branch called assignment-5.
* Make sure you push your changes before the due date - late submissions will not be accepted.
* For students in L1A, the assignment is due on Tuesday, November 29 at 11:59 PM.
* For students in L1B, the assignment is due on Thursday, December 1 at 11:59 PM.
* We will be downloading the code on the due date, any changes to the code after that point will not be considered for marking.

## Labs are mandatory on the week of assignment submission:

* If you can not attend the lab to demo your assignment for any reason, you need to notify Instructors on Piazza at least 24 hours prior to the start of your lab section. Otherwise, you will be recorded as no attendance and will have marks deducted.
