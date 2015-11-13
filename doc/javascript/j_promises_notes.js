// controller

angular.module('httpApp').controller('myCtrl', function($scope, myService){
    $scope.test = "Working"
    
    $scope.isLoading = true;
    var promise = myService.getStarship();
    
    promise.then(myService.getPilots)
            .then(function(starshipWithPilots){
        $scope.starship = starshipWithPilots;
    };
                  
//    promise.then(validateEmails)
//           .then(sendEmails)
//           .then(reportSuccess)
//           .then(askUserForResendOption)
//           .then(resendMoreEmails)
    
    
});


// service

angular.module('httpApp').service('myService', function($http, $q){
    
    var baseUrl = "http://swapi.co/api/starships/10/?format=json"
    
    this.getStarshipWithPilots = function(){
        
        var deferred = $q.defer();
        
        $http({
          method: 'GET',
          url: baseUrl
        }).then(function(response){
          var starship = response.data;
            
          var pilotObjs = [];
          var totalPilots = starship.pilots.length;
         
          starship.pilots.forEach(function(pilotUrl){
                $http({
                   method: 'GET',
                   url: pilotUrl
                }).then(function(pilotResponse){
                    pilotObjs.push(pilotResponse.data);
                    
                    if(pilotObjs.length === totalPilots){
                        starship.pilots = pilotObjs;
                        //order pilots alphabetically
                        deferred.resolve(starship);
                    }
                })
          })
            
        })
        
        
        return deferred.promise;
    }
    
    this.getStarship = function(){
        var deferred = $q.defer();
        
        $http({
          method: 'GET',
          url: baseUrl
        }).then(function(response){
          var starship = response.data;
          deferred.resolve(starship);
        })
        
        return deferred.promise;
    };
    
    this.getPilots = function (starship){
        var deferred = $q.defer();
        var arrayOfPilotUrls = starship.pilots;
        
          var pilotObjs = [];
          var totalPilots = arrayOfPilotUrls.length;
         
          arrayOfPilotUrls.forEach(function(pilotUrl){
                $http({
                   method: 'GET',
                   url: pilotUrl
                }).then(function(pilotResponse){
                    pilotObjs.push(pilotResponse.data);
                    
                    if(pilotObjs.length === totalPilots){
                        starship.pilots = pilotObjs;
                      //order pilots alphabetically
                        deferred.resolve(starship);
                    }
                })
          })
          
          return deferred.promise;
    }
});


