var cheerlympics = angular.module('cheerlympics', ['ngRoute']);

cheerlympics.config(function($routeProvider) {
    $routeProvider 
        .when("/", {
            templateUrl: "home.html",
            controller: "CheerlympicsController"
        })
        .when("/home2", {
            templateUrl: "home2.html",
            controller: "CheerlympicsController"
        })
        .when("/edit", {
            templateUrl: "edit.html",
            controller: "EditController"
        })
});

cheerlympics.controller('CheerlympicsController',
    function CheerlympicsController($scope) {
        $scope.temp = "Hello2!"
    }
);

cheerlympics.controller('EditController', ['$scope', '$http',
    function EditController($scope, $http) {
        $scope.tool = '';

        $scope.help = false;

        $scope.text = {};

        $scope.text.line1 = 'Line 1';
        $scope.text.line2 = 'Line 2';

        $scope.color = "white";

        $scope.editing = true;

        $scope.flag = "";

        $scope.anim = "";

        $scope.sound = "None";

        $scope.sounds = [{name: "None"}, {name: "Applause"}, {name: "Horn"}, { name: "Cheering"}];

        $http.get('js/countries.json')
            .then(function(res){
                $scope.countries = res.data.countries.country;                
            });

        $scope.setTool = function(newTool) {
            if($scope.tool === newTool) {
                $scope.tool = '';
            } else {
                $scope.tool = newTool;
            }
        }

        $scope.toggleHelp = function() {
            $scope.setTool('');
            $scope.help = !$scope.help;
        }

        $scope.isSet = function(toolName) {
            return $scope.tool === toolName;
        }

        $scope.isSoundSelected = function(sound) {
            if($scope.sound === sound) {
                return "sound-selected"
            }
        }

        $scope.setSound = function(sound) {
            $scope.sound = sound;
            $scope.tool = '';
                                           
            if(sound == "Applause") {
                var audio = new Audio('audio/applause.mp3');
                audio.play();
            }
            else if(sound == "Horn") {
                var audio = new Audio('audio/horn.mp3');
                audio.play();
            }
            else if(sound == "Cheering") {
                var audio = new Audio('audio/cheering.mp3');
                audio.play();
            }
        }
                                           
        $scope.playSound = function() {
            if($scope.sound == "Applause") {
                var audio = new Audio('audio/applause.mp3');
                audio.play();
            }
            else if($scope.sound == "Horn") {
                var audio = new Audio('audio/horn.mp3');
                audio.play();
            }
            else if($scope.sound == "Cheering") {
                var audio = new Audio('audio/cheering.mp3');
                audio.play();
            }
        }

        $scope.setColor = function(color) {
            $scope.color = color;
            $scope.tool = '';
        }

        $scope.setFlag = function(flag) {
            $scope.flag = flag;
            $scope.tool = '';
        }

        $scope.setAnim = function(anim) {
            $scope.anim = anim;
            $scope.tool = '';
        }

        $scope.isEdit = function() {
            return $scope.editing;
        }

        $scope.togglePlay = function() {
            console.log($scope.editing);
            $scope.editing = !$scope.editing;
        }

        $scope.getFlagClass = function(code) {
            return "flag-icon-"+code.toLowerCase();
        }

        $scope.getFlagAndColorClass = function() {
            return $scope.getFlagClass($scope.flag) + " " + $scope.color
        }

        $scope.isSingleLine = function() {
            if(($scope.text.line1 === "" || typeof($scope.text.line1) === undefined) && $scope.text.line2 === "") {
                return false;
            }

            return true;
        }
    }
]);
