# .directive "fbLogin", () ->
#   restrict: "E"
#   templateUrl: 'main/fb-login.html'
#   controller: ($scope)->
#     return

angular.module 'chesby.messages',[
  'templates',
  'ngRoute', 
  'firebase',
#   'mgcrea.ngStrap.alert',
  'mgcrea.ngStrap.aside', 
  'mgcrea.ngStrap.modal', 

  'auth'
  'luegg.directives'
]

.factory "InstantMessages", ($rootScope, FIREBASE_URL, $firebase) ->
  InstantMessages = (senderId) ->
#     newItems = false
    ref = new Firebase(FIREBASE_URL)
    ref = ref.child('InstantMessages').child(senderId)
#     ref.on 'child_added', (message) ->
#       return if !newItems
#       message = message.val()
#       console.log(message.content)
#     ref.once 'value', (messages) ->
#       newItems = true
      
    return $firebase(ref).$asArray()
      
    
# .controller "Shells", ()->
#     vm = this
#     vm.users = [{messages: [{content:'foo', username:'BOB'}], username: 'user.uid'}, {messages: [{content:'foo', username:'JOE'}], username: 'JOE'}]
#     vm.sendMessage = (message, username) ->
#       if message and message != '' and username
#         vm.messages.push
#           'username': username
#           'content': message          
#     return      
.controller "Shell", (InstantMessages, Auth)->
    vm = this
    
    Auth.$onAuth (user) ->
      return unless user
      vm.messages = InstantMessages(user.uid)
      vm.username = user.uid

    vm.sendMessage = (message, username) ->
      if message and message != '' and username
        vm.messages.$add
          'username': username
          'content': message
          'timestamp': Firebase.ServerValue.TIMESTAMP
    return




.directive "impopup", () ->
  restrict: 'EA'
  templateUrl: 'messages/impopup.html'
  replace: true
  scope:
    messages: '='
    username: '='
    open: '='
    inputPlaceholderText: '@'
    submitButtonText: '@'
    title: '@'
    theme: '@'
    submitFunction: '&'
  controllerAs: 'vm'
  controller: ($scope) ->
    vm = this
    isHidden = true
    

    
    toggle = ->
      if isHidden
        vm.chatButtonClass = 'glyphicon-minus icon_minim'
        vm.panelStyle = 'display': 'block'
        isHidden = false
      else
        vm.chatButtonClass = 'glyphicon-plus icon_minim'
        vm.panelStyle = 'display': 'none'
        isHidden = true
      return

    vm.messages = $scope.messages
    vm.username = $scope.username
    vm.moment = moment
    vm.inputPlaceholderText = $scope.inputPlaceholderText
    vm.submitButtonText = $scope.submitButtonText
    vm.title = $scope.title
    vm.theme = 'chat-th-' + $scope.theme
    vm.writingMessage = ''

    vm.submitFunction = ->
      $scope.submitFunction() vm.writingMessage, vm.username
      vm.writingMessage = ''
      return

    vm.panelStyle = 'display': 'none'
    vm.chatButtonClass = 'glyphicon-plus icon_minim'
    vm.toggle = toggle
    
    readCount = 0
    $scope.$watchCollection 'messages', (newVal, oldVal)->
      return if (newVal.length <= readCount)
      toggle() if isHidden
#       readCount = newVal.length
    return
  link: (scope) ->
    if !scope.inputPlaceholderText
      scope.inputPlaceholderText = 'Write your message here...'
      if !scope.submitButtonText or scope.submitButtonText == ''
        scope.submitButtonText = 'Send'
        if !scope.title
          scope.title = 'Chat'
          return
  
.directive "messages", () ->
  restrict: "E"
  templateUrl: 'messages/messages.html'
  controller: ($scope, ChatMessages, $routeParams, Auth, $firebase, $timeout)->
#       # Show a basic aside from a controller
#     myAside = $aside(
#       title: 'My Title'
#       content: 'My Content'
#       show: true)
#     # Pre-fetch an external template populated with a custom scope
#     myOtherAside = $aside(
#       scope: $scope
#       template: 'aside/docs/aside.demo.tpl.html')
#     # Show when some event occurs (use $promise property to ensure the template has been loaded)
#     myOtherAside.$promise.then ->
#       myOtherAside.show()
#       return
#     return

    
    
    
    $scope.messages = {}
    $scope.moment = moment

    
    Auth.$onAuth (user) ->
      if user is null
        console.log "error: please sign in to use messages module"
        return
      $scope.messages = ChatMessages(user.uid).get()
    
      $scope.newMessage = {}
      $scope.addMessage = (newMessage) ->
        return  unless newMessage.text.trim().length
        newMessage.sent = false
        newMessage.type = 'web' # determine from uid
        newMessage.timestamp = Firebase.ServerValue.TIMESTAMP
        newMessage.from = $scope.user.uid #change to sender
        # $scope.messages.$add(newMessage).then () ->
  #       ChatMessages($routeParams.userId).create(newMessage).then ->
        ChatMessages(user.uid).create(newMessage).then ->
          $scope.newMessage = {}
        return
    return
  link: (scope, element, attrs, ctrl) ->
    return
  
.factory "ChatMessages", ($rootScope, FIREBASE_URL, $firebase) ->
    ref = new Firebase(FIREBASE_URL)
    ChatMessages = (senderId) ->
      checkUnread: () -> 
        ref.once "value", (snapshot) ->
          $rootScope.unreadMessages =  snapshot.numChildren()

      create: (message) ->
        $firebase(ref.child('messages').child(senderId)).$asArray().$add(message)
      get: () ->
        messages = $firebase(ref.child('messages').child(senderId)).$asArray()
        messages.$loaded().then () -> 
          # clear unread count
          # $rootScope.user.unreadMessages = 0
          $rootScope.unreadMessages =  null
        return messages
