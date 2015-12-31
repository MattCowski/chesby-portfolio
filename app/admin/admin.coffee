angular.module 'chesby.admin', []

  .factory "Users", (FIREBASE_URL,$firebase) ->
    ref = new Firebase(FIREBASE_URL+'/Users')
    $firebase(ref).$asObject()
    
  .directive 'users', ->
    {
      restrict: 'E'
      replace: true
      scope: true
      templateUrl: 'admin/users.html'
      controller: ($scope, Users) ->
        
        Users.$bindTo $scope, "Users"

        $scope.delete = (accessKeyId) ->
          delete  $scope.Users[accessKeyId]

      link: (scope, element, attrs, ctrl) ->
        return
    }

  .directive 'admin', ->
    {
      restrict: 'E'
      replace: true
#       scope: true
      scope:
        useruid: '@'
      templateUrl: 'admin/admin.html'
      controllerAs: 'admin'
      controller: ($scope, AppConfigKeys) ->
        
        $scope.appConfigKeys = {}
        AppConfigKeys.$bindTo $scope, "appConfigKeys"

        @messages = []

        @goToMessage = (id) ->
          InboxFactory.goToMessage id
          return

        @deleteMessage = (id, index) ->
          InboxFactory.deleteMessage id, index
          return

  # #       InboxFactory.getMessages().then angular.bind(this, ->
  # #         @messages = InboxFactory.messages
  # #         return
  # #       )
        return
      link: (scope, element, attrs, ctrl) ->
        return
    }
  .directive 'editUser', ->
    {
      restrict: 'E'
      replace: true
      scope: true
      templateUrl: 'admin/edit-user.html'
  #     controllerAs: 'admin'
      controller: 'MainCtrl'
      link: (scope, element, attrs, ctrl) ->
        return
    }

  .directive 'messageUser', ->
    {
      restrict: 'E'
      replace: true
      scope: true
      templateUrl: 'admin/message-user.html'
  #     controllerAs: 'admin'
      controller: ($scope, Messages) ->
        $scope.messages = Messages($scope.phoneId)
        $scope.call = ->
          console.log "calling..."
          $http.get 'http://forceful-meteor-77-208197.use1.nitrousbox.com:8888/request-call/?to='+$scope.phoneId+'&from=', {from:'this user', to: $scope.phoneId}

      link: (scope, element, attrs, ctrl) ->
        return
    }
  .directive 'imUser', ->
    {
      restrict: 'E'
      replace: true
      scope: 
        useruid: '@'
      templateUrl: 'admin/im-user.html'
      controller: ($scope, InstantMessages) ->  
        $scope.instantmessages = InstantMessages($scope.useruid)
          
      link: (scope, element, attrs, ctrl) ->
        return
    }


  .factory "Presence", (FIREBASE_URL, $firebase) ->
    ref = new Firebase(FIREBASE_URL)
    ref.child('.info/connected')
    .on "value", (snap) ->
      console.log 'user presence: '+snap.val()
#       if snap.val() is true

  .factory "Messages", (FIREBASE_URL, $firebase) ->
    ref = new Firebase(FIREBASE_URL)
    (phoneId) -> 
      Messages = $firebase(ref.child('talk').child(phoneId)).$asArray()
      
#   .factory "InstantMessages", (FIREBASE_URL, $firebase) ->
#     ref = new Firebase(FIREBASE_URL)
#     (userid) -> 
#       InstantMessages = $firebase(ref.child('InstantMessages').child(userid)).$asArray()
      
  .factory "Contact", (FIREBASE_URL, $firebase) ->
    ref = new Firebase(FIREBASE_URL)
    (phoneId) -> 
      usersRef = new Firebase('https://chesby.firebaseio.com/Users')
      usersRef.child(phoneId).set(phoneId)
      $firebase(ref.child('contacts').child(phoneId)).$asObject()

  .factory "AppConfigKeys", (FIREBASE_URL,$firebase) ->
    ref = new Firebase(FIREBASE_URL+'/AppConfigKeys')
    $firebase(ref).$asObject()

  .controller "MainCtrl", (Messages, $scope, $location, $routeParams, $http, Presence, Contact, InstantMessages) ->


    # ngmodel for admin num and twilio callback app also
#     users table

    $scope.saveContact = ()->
      $scope.contact.$save().then ->
        console.log "saved"

    
#     $scope.phoneId = 'simplelogin:1'
    $scope.$watch "phoneId", (newVal, oldVal) ->
      $scope.contact = Contact($scope.phoneId)

  .directive 'faq', ->
    {
      restrict: 'E'
      replace: true
      scope: 
        useruid: '@'
      templateUrl: 'main/faq.html'
      controller: ($scope, $location) ->                
        $scope.search = $location.search()

        $scope.faqs = [
          title: "What do I need to buy?"
          content: 'You should buy the tile and grout. We supply the glue and sealer.'
          tags: ['backsplash', 'all']
        ,
          title: 'Sanded or un-sanded grout?'
          content: 'Sanded grout is used in most cases. Even when dealing with glass, we tend to mix in at least a little bit of sanded to help fortify the grout. The sand in the sended grout helps prevent cracks and pin-holes that tend to show when using only unsanded. As professionals, we don\'t put as much pressure on the float as DIY\'ers do when grouting, which will cause scratches. Store representatives assume customers are newbies or DIY\'ers and usually advise using non-sanded to avoid liability.'
          tags: ['backsplash', 'all']
        ]
        $scope.slides = [
          image:'http://transloaditkts.s3.amazonaws.com/december/cropped/12/ddfdb0801e11e499d50b6421041b3b/12ddfdb0801e11e499d50b6421041b3b.jpg'
          text:'Get a quote today with our online calculator.'
          title: 'Top Rated'
          routes: ['all', 'floor']
        ,
          image:'http://transloaditkts.s3.amazonaws.com/december/cropped/2e/62ab30801e11e4bdd59f6ab837b280/2e62ab30801e11e4bdd59f6ab837b280.jpg'
          text:'ne calculator.'
          title: 'Top Rated'
        ,
          image:'http://transloaditkts.s3.amazonaws.com/december/cropped/31/98f700801e11e4af7813679034d6cf/3198f700801e11e4af7813679034d6cf.jpg'
          text:'Get a quote today with our online calculator.'
          title: 'Top Rated'
          routes: ['all', 'floor']

        ]
        $scope.pros = [
          name: "Bob Smith"
          pic: "http://transloaditkts.s3.amazonaws.com/december/cropped/0b/7d8c207e9d11e48907cfda4055278a/0b7d8c207e9d11e48907cfda4055278a.jpg"
          content: 'You should buy the tile and grout. We supply the glue and sealer.'
          phone: '+18475551234'
          company: 'FooBar Inc.'
          keywords: ['backsplash installer', 'tile installer']
          negKeywords: []
        , 
          name: "Mike S."
          pic: "http://transloaditkts.s3.amazonaws.com/december/cropped/0b/7d8c207e9d11e48907cfda4055278a/0b7d8c207e9d11e48907cfda4055278a.jpg"
          content: 'I am a pro.'
          phone: '+18475551234'
          company: 'FooBar Inc.'
          keywords: ['flooring installer', 'tile installer']
          negKeywords: []
        ]

          
      link: (scope, element, attrs, ctrl) ->
        return
    }
      
