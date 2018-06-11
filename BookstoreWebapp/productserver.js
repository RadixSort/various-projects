var express = require('express')
var app = express()

app.set('port', (process.env.PORT || 5000))
app.use(express.static(__dirname + '/public'))

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

app.get('/products', function(request, response) {

  response.header("Access-Control-Allow-Origin", "*");
  response.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  var option = getRandomInt(0,5);
  if (option < 4) {
    var products = {
      'KeyboardCombo' : {
        price : getRandomInt(25,35),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/KeyboardCombo.png'
      },
      'Mice' : {
        price : getRandomInt(5,7),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/Mice.png'
      },
      'PC1' : {
        price : getRandomInt(300,350),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/PC1.png'
      },
      'PC2' : {
        price : getRandomInt(350,400),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/PC2.png'
      },
      'PC3' : {
        price : getRandomInt(330,380),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/PC3.png'
      },
      'Tent' : {
        price : getRandomInt(30,40),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/Tent.png'
      },
      'Box1' : {
        price : getRandomInt(5,7),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/Box1.png'
      },
      'Box2' : {
        price : getRandomInt(5,7),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/Box2.png'
      },
      'Clothes1' : {
        price : getRandomInt(20,30),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/Clothes1.png'
      },
      'Clothes2' : {
        price : getRandomInt(20,30),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/Clothes2.png'
      },
      'Jeans' : {
        price : getRandomInt(30,40),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/Jeans.png'
      },
      'Keyboard' : {
        price : getRandomInt(15,25),
        quantity : getRandomInt(0,10),
        url : 'https://cpen400a.herokuapp.com/images/Keyboard.png'
      }
    };

    response.json(products);
  } else if (option == 4) {
    response.status(500).send("An error occurred, please try again");
  }
})

app.listen(app.get('port'), function() {
  console.log("Node app is running at localhost:" + app.get('port'))
})
