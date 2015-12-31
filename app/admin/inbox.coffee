app = angular.module('inbox', [])
#       app.config(function () {/*...*/});
app.factory 'InboxFactory', ($q, $http, $location) ->
  'use strict'
  exports = {}
  exports.messages = []
  exports.goToMessage = (id) ->
    if angular.isNumber(id)
      # $location.path('inbox/email/' + id)
    else
    return

  exports.deleteMessage = (id, index) ->
    @messages.splice index, 1
    return

  exports.getMessages = ->
    deferred = $q.defer()
    $http.get('json/emails.json').success((data) ->
      exports.messages = data
      deferred.resolve data
      return
    ).error (data) ->
      deferred.reject data
      return
    deferred.promise

  exports
app.directive 'inbox', ->
  {
    restrict: 'E'
    replace: true
    scope: true
    #         templateUrl: 'js/directives/inbox.tmpl.html'
    template: '<pre>inbox here</pre>'
    controllerAs: 'inbox'
    controller: (InboxFactory) ->
      @messages = []

      @goToMessage = (id) ->
        InboxFactory.goToMessage id
        return

      @deleteMessage = (id, index) ->
        InboxFactory.deleteMessage id, index
        return

      InboxFactory.getMessages().then angular.bind(this, ->
        @messages = InboxFactory.messages
        return
      )
      return
    link: (scope, element, attrs, ctrl) ->
      ###
      by convention we do not $ prefix arguments to the link function
      this is to be explicit that they have a fixed order
      ###
      return
  }
app.controller 'InboxCtrl', ($scope, InboxFactory) ->
  #          InboxFactory.getMessages()
  #             .success(function(jsonData, statusCode) {
  #                console.log('The request was successful!', statusCode, jsonData);
  #                // Now add the Email messages to the controller's scope
  #                $scope.emails = jsonData;
  #          });
  return
