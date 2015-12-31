
// angular.module('bookings', [])
 
// .controller('bookingsController', function($scope) {
//     $scope.values = [];
//     $scope.price = 500;
//     $scope.timeSelection = {};
//     $scope.discounted = {0:true, 1:false};
//     $scope.available = {0:true, 1:false};
//     $scope.modifier = {0:10, 1:-14}
//     $scope.timeSlots = ["Any Time","8AM - 12PM", "12PM - 4PM"];
//     var createCal = function (days, startOffset) {
//       for(var i=0; i < days; i++){
//         var month = moment().add(i+startOffset, 'days').format("MMM");
//         var day = moment().add(i+startOffset, 'days').format("DD ddd");
// //         var weekday = moment().add(i+startOffset, 'days').format("MMM DD ddd");
//         $scope.values.push([month, day]);
//       };
//     };

//     createCal(28, 2);
//     $scope.selectedIndex = -1;
    
//     $scope.toggleSelect = function(ind){
//         if( ind === $scope.selectedIndex ){
//             $scope.selectedIndex = -1;
//         } else{
//             $scope.selectedIndex = ind;
//         }
//     }
    
//     $scope.getClass = function(ind){
//         if( ind === $scope.selectedIndex ){
// //             return "selected"
//             return "active";
//         } else{
//             return "";
//         }
//     }
       

// });