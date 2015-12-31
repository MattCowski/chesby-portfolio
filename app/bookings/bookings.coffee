angular.module 'chesby.bookings', []
.directive 'bookings', ->
  {
    restrict: 'E'
    replace: true
    scope: true
    templateUrl: "bookings/bookings.html"
    controller: 'bookingsAdminController'

    link: (scope, element, attrs, ctrl) ->
      return
  }



.controller 'bookingsAdminController', (Bookings, $scope) ->
  $scope.price = 500
#   $scope.user = 
#     uid: 'user444'
  $scope.moment = moment
  $scope.bookings = {}
  $scope.calDates = {}
  Bookings.$bindTo $scope, "bookings"

  $scope.timeSlots = [
    'Any Time'
    '8AM - 12PM'
    '12PM - 4PM'
  ]

  createCal = (days, startOffset) ->
    while days -= 1
      dayId = moment().add(days+startOffset, 'days').format("YYYY-MM-DD")
      $scope.calDates[dayId] = $scope.bookings[dayId] or {}
      
  Bookings.$loaded().then ->
    createCal(14, 3);

  $scope.requestAppointment = () ->
    k = $scope.selectedKey
    $scope.bookings[k] = $scope.calDates[k]
    $scope.bookings[k].uid = $scope.user.uid
    
  $scope.delete = (k) ->
    delete $scope.bookings[k]
    
  $scope.toggleSelect = (k) ->
    $scope.selectedKey = k

  $scope.getClass = (k) ->
    if k == $scope.selectedKey
      'active'
    else
      ''

.factory "Bookings", (FIREBASE_URL,$firebase) ->
#   return (username) ->      
    ref = new Firebase(FIREBASE_URL+'/bookings')
    $firebase(ref).$asObject()
