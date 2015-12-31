angular.module 'chesby.invoices', []
.directive 'userInvoices', ->
  {
    restrict: 'E'
    replace: true
    scope:
      useruid: '@'
    templateUrl: "invoices/user-invoices.html"
#     controllerAs: 'invoices'
    controller: 'InvoiceCtrl'
    link: (scope, element, attrs, ctrl) ->
      return
  }

# angular.module 'chesby.invoices'
.directive 'invoice', ->
  {
    restrict: 'E'
    replace: true
    scope: 
      id: '@'
    templateUrl: "invoices/invoice.html"
#     template: '<pre>invoice : {{Invoice}} </pre>'
#     controllerAs: 'invoice'
    controller: 'InvoiceCtrl'
    link: (scope, element, attrs, ctrl) ->
      return
  }
# .factory "Access", (FIREBASE_URL, $firebase) ->
#   return (useruid) ->
#     ref = new Firebase(FIREBASE_URL+'/Access/'+useruid+'/Invoices')
#     $firebase(ref).$asObject()

.controller "InvoiceCtrl", (FIREBASE_URL, $scope, $firebase, $location) ->  
  if $scope.useruid
#     $scope.Invoices = Access($scope.useruid)
    ref = new Firebase(FIREBASE_URL+'/Access/'+$scope.useruid+'/Invoices')
    $scope.Invoices = $firebase(ref).$asObject()
    
    $scope.createNewInvoice = ->
      $firebase(ref).$push().then (newRef) ->
        $location.path('/invoice/'+newRef.key())
        console.log('WARNING: /Access not set for user')

    $scope.forceCreateNewInvoice = ->
      ref = new Firebase(FIREBASE_URL+'/Access/'+$scope.useruid+'/Invoices')
      $firebase(ref).$push({edit:true, read:true})
      
      
  ref = new Firebase(FIREBASE_URL+'/Invoice')
#   $scope.Invoice = $firebase(ref.child($scope.id)).$asObject() if $scope.id
  $firebase(ref.child($scope.id)).$asObject().$bindTo($scope, "Invoice") if $scope.id
#       @Invoice = $scope = this
  $scope.deleteInvoiceItems = (key) ->
    delete  $scope.Invoice[key]

  ref = new Firebase(FIREBASE_URL+'/Header')
  $firebase(ref.child($scope.id)).$asObject().$bindTo($scope, "Header") if $scope.id
