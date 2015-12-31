

    
angular.module 'angular', [
  'upload',
  'auth',
  'templates',
  'ngRoute', 
  'chesby.messages',
  'chesby.admin',
  'chesby.profile',
  'chesby.bookings',
  'chesby.invoices'
  'angularVideoBg'
#   'ngAnimate', 
#   'firebase',  
#   'ngSanitize', 
#   'angularFileUpload', 
#   'ui.mask',
#   'ui.bootstrap.carousel' ,
  'ui.bootstrap.tpls',
#   'mgcrea.ngStrap.affix', 
  'mgcrea.ngStrap.helpers.dimensions',
  'mgcrea.ngStrap.aside', 
#   'ui.bootstrap.typeahead',
#   'ui.bootstrap.tabs',
  'ui.bootstrap.progressbar',
#   'ui.bootstrap.dropdown',
#   'ui.bootstrap.datepicker',
#   'ui.bootstrap.collapse',
#   'ui.bootstrap.buttons',
  'ui.bootstrap.accordion',
#   'mgcrea.ngStrap.popover',
#   'mgcrea.ngStrap.tooltip', 
  'mgcrea.ngStrap.modal', 
  'mgcrea.ngStrap.navbar', 
  'mgcrea.ngStrap.alert', 
]
  .constant('FIREBASE_URL', "https://chesby.firebaseio.com/")
  .constant('BACKEND_URL', 'http://node-js-100773.nitrousapp.com:8888/')
  
  .run ($rootScope, Auth, ChatMessages, $location) ->
    $rootScope.auth = Auth
    ChatMessages($rootScope.user.uid).checkUnread() if $rootScope.user



  .config ($routeProvider, $httpProvider, $locationProvider) ->
    $locationProvider.html5Mode(false)

    $routeProvider
      .when '/',
        templateUrl: "main/main.html"
        controller: "IndexCtrl"
      .when '/bookings',
        template: "<bookings>"
      .when '/invoices',
#         resolve: "currentAuth": ["Auth", (Auth) -> return Auth.$requireAuth()]          
        resolve: "currentAuth": ["Auth", (Auth) -> return Auth.$waitForAuth()]
        controller: ($scope, currentAuth) -> $scope.useruid = currentAuth.uid
        template: "<user-invoices useruid={{useruid}}>"
#         controller: ($scope, Auth) -> 
#           Auth.$onAuth (user) ->
#             $scope.useruid = user.uid if user
      .when '/invoice/:invoiceId',
        template: (params) -> " <invoice id="+params.invoiceId+">"
      .when '/admin',
        template: "<admin>"
      .when '/users',
        template: "<users>"
      .when '/user/:useruid',
        template: (params) -> "<profile useruid="+params.useruid+">"
      .when '/user/:useruid/invoices',
        template: (params) -> "<users></users> <user-invoices useruid="+params.useruid+">"
      .when '/user/:useruid/im',
        template: (params) -> "<users></users> <im-user useruid="+params.useruid+">"
      .when '/user/:useruid/message',
        template: (params) -> "<users></users> <message-user useruid="+params.useruid+">"
      .when '/messages',
        template: "<messages>"
      .when '/transloader',
        template: "<transloader>"
      .when '/profile',
        template: "<profile>"
      .when '/search',
        template: "<search>"
      .when '/faq',
        template: "<faq>"
      .otherwise
        redirectTo: '/'
        
  
  .factory "AWSLambda", (FIREBASE_URL,$firebase) ->
    ref = new Firebase(FIREBASE_URL+'/AWSLambda')
    $firebase(ref).$asObject()
    

    
  .factory "AWSLambdaPermissions", (FIREBASE_URL,$firebase) ->
    ref = new Firebase(FIREBASE_URL+'/AWSLambdaPermissions')
    $firebase(ref).$asObject()

  .controller "IndexCtrl", ($http, TwilioSMSLambda, AWSLambdaPermissions, Auth, $scope, $aside, $modal, NodemailerLambda, $rootScope, AWSLambda) ->

    $scope.delete = (accessKeyId) ->
      delete  $scope.AWSLambda[accessKeyId]
      
    $scope.AWSLambda = {}
    AWSLambda.$bindTo $scope, "AWSLambda"
    
    AWSLambdaPermissions.$bindTo $scope, "AWSLambdaPermissions"
    
    $scope.deleteUser = (uid) ->
      delete  $scope.AWSLambdaPermissions[uid]


    $scope.sendEmail = () ->
    #     issues to fix:
# - anyone can login and request email.
# - only allow 1 per 5 min. 10 max. 
# - only users on our site

      if $scope.user.uid
        console.log "nodemailer permission: "+AWSLambdaPermissions[$scope.user.uid]["nodemailer"]
        if AWSLambdaPermissions[$scope.user.uid]["nodemailer"]
          NodemailerLambda {'email':{'to': 'mattcowski@gmail.com', 'subject': 'with secret moved', 'text': 'from home'}}, (err, emailResult) ->
            console.log err, emailResult
            
    $scope.sendSMS = (message) ->
      TwilioSMSLambda {'message': message}, (err, smsResult) ->
        console.log err, smsResult


.factory 'TwilioSMSLambda', (AWSLambda) ->
  return (events, cb) ->
    lambda = new AWS.Lambda({
      region: "us-west-2",
      accessKeyId: 'AKIAIUWYHNMIN5ZESSEQ',
      secretAccessKey: AWSLambda["nodemailer"]
      })
    lambda.invoke
      FunctionName: "twiliosms-production",
      Payload: JSON.stringify(events)
    , cb  
     

.factory 'NodemailerLambda', (AWSLambda) ->
  return (events, cb) ->
    lambda = new AWS.Lambda({
      region: "us-west-2",
      accessKeyId: 'AKIAIUWYHNMIN5ZESSEQ',
      secretAccessKey: AWSLambda["nodemailer"]
      })
    lambda.invoke
      FunctionName: "nodemailer-production",
      Payload: JSON.stringify(events)
    , cb  
     
      
# .factory "Messages", (FIREBASE_URL, $firebase) ->
#     ref = new Firebase(FIREBASE_URL)
#     Messages = (userId) ->
#       get: (userId) ->
#         defer = $q.defer()
#         $firebase(ref.child("user_rooms").child(userId)).$asArray().$loaded().then (data) ->
          
#           defer.resolve messages
#           return

#         defer.promise
#     Messages
      
      

.controller "DropdownCtrl", ($scope) ->
  # DropdownCtrl = ($scope) ->
  $scope.items = [
    "The first choice!"
    "And another choice for you."
    "but wait! A third!"
  ]
  $scope.status = isopen: false
  $scope.toggled = (open) ->
    console.log "Dropdown is now: ", open
    return

  $scope.toggleDropdown = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    $scope.status.isopen = not $scope.status.isopen
    return

  return

.factory "Auth", ($modal, $firebase, FIREBASE_URL, $firebaseAuth, $rootScope, $timeout, $location) ->
  ref = new Firebase(FIREBASE_URL)
  auth = $firebaseAuth(ref)
  
  Auth =
    user: null
    unauth: -> 
      console.log "unauth"
      @$unauth()
      @user = null
    $unauth: auth.$unauth
    $onAuth: auth.$onAuth
    $waitForAuth: auth.$waitForAuth
    $authWithCustomToken: auth.$authWithCustomToken
    $authWithPassword: auth.$authWithPassword
    $createUser: auth.$createUser
    popup: =>
        loginModal = $modal({template: 'auth/modalLogin.html', show: false})
        if !Auth.user
          console.log "opeing"
          loginModal.$promise.then(loginModal.show)
          
        Auth.$onAuth (user) =>
          if user
            console.log "closing"
            loginModal.$promise.then(loginModal.hide)

    createProfile: (user) ->
      profileData =
        md5_hash: user.md5_hash or ''
        roleValue: 10
      
      profileRef = $firebase(ref.child('profile').child(user.uid))  
      angular.extend(profileData, $location.search())
      return profileRef.$update(profileData)
  
  auth.$onAuth (user) ->
    if user
      Auth.user = {}
      angular.copy(user, Auth.user)
      Auth.user.profile = $firebase(ref.child('profile').child(Auth.user.uid)).$asObject()
      $rootScope.user = Auth.user
      # ref.child('profile/'+Auth.user.uid+'/online').set(true)
      # ref.child('profile/'+Auth.user.uid+'/online').onDisconnect().set(Firebase.ServerValue.TIMESTAMP)
      # ref.child('profile/'+Auth.user.uid+'/connections').push(true)
      # ref.child('profile/'+Auth.user.uid+'/connections').onDisconnect().remove()
      # ref.child('profile/'+Auth.user.uid+'/connections/lastDisconnect').onDisconnect().set(Firebase.ServerValue.TIMESTAMP)

    else
      if Auth.user and Auth.user.profile
        Auth.user.profile.$destroy()
      angular.copy({}, Auth.user)
      $rootScope.user = Auth.user



    # ref.child('.info/connected').on 'value', (snap) ->
    #   if snap.val() is true
    #     user = Auth.user.uid or 'unknown'
    #     ref.child('connections').push(user)
    #     ref.child('connections').onDisconnect().remove()

  return Auth
.controller "TypeaheadCtrl", ($scope, $http) ->
  # TypeaheadCtrl = ($scope, $http) ->
  $scope.selected = undefined
  $scope.asyncSelected = undefined
  
  $scope.getDistance = (val) ->
    # https://developers.google.com/maps/documentation/distancematrix/
    $http.get "http://maps.googleapis.com/maps/api/distancematrix/json?origins=Seattle&destinations=San+Francisco&mode=driving&&sensor=false"
    .then (response) ->
      $scope.maps = response
  # $scope.getDistance()
  # Any function returning a promise object can be used to load values asynchronously
  $scope.getLocation = (val) ->
    $http.get("http://maps.googleapis.com/maps/api/geocode/json",
      params:
        address: val
        sensor: false
    ).then (response) ->
      # $scope.maps = response
      # addresses = []
      return response.data.results.map (item)->
        return item.formatted_address
      # angular.forEach res.data.results, (item) ->
      #   addresses.push item.formatted_address
      #   return

      # addresses

.directive 'disableNgAnimate', ['$animate', ($animate)->
  restrict: 'A'
  link: (scope, element)-> $animate.enabled false, element
]

