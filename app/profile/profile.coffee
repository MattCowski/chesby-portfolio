angular.module 'chesby.profile', []

#   .factory "Users", (FIREBASE_URL,$firebase) ->
#     ref = new Firebase(FIREBASE_URL+'/Users')
#     $firebase(ref).$asObject()
    
  .directive 'profile', ->
    {
      restrict: 'E'
      replace: true
      scope: true
      templateUrl: 'profile/profile.html'
      controller: ($scope) ->
        

      link: (scope, element, attrs, ctrl) ->
        return
    }