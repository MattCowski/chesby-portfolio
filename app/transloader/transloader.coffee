angular.module 'upload',[
#   'ngRoute', 
  'angularFileUpload', 
  'firebase', 
]

.factory "UploadFiles", (FIREBASE_URL,$firebase) ->
  return (username) ->      
    ref = new Firebase(FIREBASE_URL+'/files').child(username)
    $firebase(ref).$asArray()



.controller 'FileCtrl', (FIREBASE_URL, $http, $location, $routeParams, Profile, $firebase, $scope, RouteLogin, $rootScope, Auth, Transloaderv5) ->    
  ref = new Firebase(FIREBASE_URL)
  assembly = $firebase(ref.child("files").child($scope.user.uid).child($routeParams.fileId))
  assemblyObj = assembly.$asObject()
  assemblyObj.$bindTo $scope, "assembly"
  # $scope.assembly = assemblyObj

  $scope.resetCanvas = ()->
    assembly.$set("drawing", assemblyObj[":original"])
    console.log "reset"

  $scope.actualCrop = (record, xyxy) =>
    Transloaderv5(record).actualCrop(xyxy)
  return

# .directive "fbfiles", ->
#   restrict: "E"
#   templateUrl: 'main/fb-files.html'
#   controller: "filesCtrl"


# .factory 'NodemailerLambda', () ->
# #   NodemailerLambda {'email':{'to': 'mattcowski@gmail.com', 'from': 'mattcowski@gmail.com', 'subject': 'uploaded image', 'text': 'User uploaded image'}, 'AUTH_TOKEN':$rootScope.user.token}, (err, emailResult) ->
# #       console.log err, emailResult
#   lambda = new AWS.Lambda({
#     region: "us-west-2",
#     accessKeyId: '',
#     secretAccessKey: ''
#     })
#   return (events, cb) ->
#     lambda.invoke
#       FunctionName: "nodemailer-production",
#       Payload: JSON.stringify(events)
#     , cb  

.factory 'TransloaderLambda', (AWSLambda) ->
  return (steps, cb) ->
#     return console.log AWSLambda["transloader"]
    lambda = new AWS.Lambda({
      region: "us-west-2",
      accessKeyId: '',
      secretAccessKey: AWSLambda["transloader"]
      })
    lambda.invoke
      FunctionName: "Transloader-production",
      Payload: JSON.stringify(steps)
    , cb

.factory 'Transloaderv5', (TwilioSMSLambda, TransloaderLambda, NodemailerLambda, FIREBASE_URL, BACKEND_URL,$timeout, $q, $http, UploadFiles, $upload, $rootScope, $firebase) ->
  return (record) -> 
    ref = new Firebase(FIREBASE_URL+"/files/").child($rootScope.user.uid)
    if record
      newRecord = $firebase(ref.child(record.$id))

    if record[':original']
      url = record[':original']
    else
      url = record.cropped
      console.log "No original to make thumb. trying cropped"

    newUrlSteps =
      thumb:
        robot: '/image/resize'
        use: ':original'
        resize_strategy: 'fillcrop'
        strip: 'true'
        format: 'jpg'
        width: 75
        height: 75
      store:
        use: ['thumb', ':original']
        path: "december/${previous_step.name}/${unique_prefix}/${file.id}.${file.ext}"
        acl: 'public-read'  

    thumbSteps =
      ':original':
        robot: "/http/import"
        url: url
      thumb:
        robot: '/image/resize'
        use: ':original'
        resize_strategy: 'fillcrop'
        strip: 'true'
        format: 'jpg'
        width: 75
        height: 75
      store:
        use: ['thumb']
        path: "december/${previous_step.name}/${unique_prefix}/${file.id}.${file.ext}"
        acl: 'public-read'

    croppedSteps =
      ':original':
        robot: "/http/import"
        url: url
      thumb:
        robot: '/image/resize'
        use: ':original'
        resize_strategy: 'fillcrop'
        strip: 'true'
        format: 'jpg'
        width: 75
        height: 75
      cropped: 
        robot: '/image/resize'
        use: ':original'
        width: 500
        height: 500
        resize_strategy: 'fillcrop'
        strip: 'true'
        format: 'jpg'
        text: [
          {
            "text": "site.com",
            "size": 18,
            "font": "Lato",
            "color": "#373737",
            "valign": "bottom",
            "align": "right"
          }
        ]
      store:
        use: ['thumb', 'cropped']
        path: "december/${previous_step.name}/${unique_prefix}/${file.id}.${file.ext}"
        acl: 'public-read'

    upload = (steps)->
      file = {} unless file = record[':originalFile']
      newRecord.$set('progress', 10)
#       $http.put(BACKEND_URL+"api/transloadit/1/?template_id=3ff06ee0eec011e38d300b3da55cc2f7", {steps:steps}).success (response) =>
      TransloaderLambda {'query':{'template_id':'3ff06ee0eec011e38d300b3da55cc2f7'}, 'body':{'steps':steps}}, (err, data) ->
        console.log "err:" + err if err
        console.log JSON.parse(data.Payload)
        response = JSON.parse(data.Payload)

        
        $upload.upload
          url: 'http://api2.transloadit.com/assemblies'
          method: "POST"
          file: file
          data:
            params: response.params
            signature: response.signature
        .progress (evt) =>
          newRecord.$set 'progress', 30
          newRecord.$set 'status', "uploading..."
        .success (transloadit) =>
          {ok, assembly_id, assembly_url} = transloadit
          newRecord.$set 'assembly_url',transloadit.assembly_url
          newRecord.$set 'progress', 80
          check(assembly_url)
    #     #formDataAppender: function(formData, key, val){}  // customize how data is added to the formData. 
    #     # See #40#issuecomment-28612000 for sample code
    
    #     .progress (evt) ->
    #       console.log "progress: " + parseInt(100.0 * evt.loaded / evt.total) + "% file :" + evt.config.file.name
    #     .success (data, status, headers, config) ->
    #       console.log "file " + config.file.name + "is uploaded successfully. Response: " + data
    #     i++
    #   return
    #   #.error(...)
    #   #.then(success, error, progress); // returns a promise that does NOT have progress/abort/xhr functions
    #   #.xhr(function(xhr){xhr.upload.addEventListener(...)}) // access or attach event listeners to 
    #   #the underlying XMLHttpRequest

    notifyOfUpload = (url) ->
          #sms and email notification of upload
          NodemailerLambda {'email':{'to': 'mattcowski@gmail.com', 'from': 'mattcowski@gmail.com', 'subject': 'Image uploads', 'html': '$scope.user.uid'+" uploaded image <img src=\"#{url}\">"}}, (err, emailResult) ->
            console.log err, emailResult
          message =
            to: '+12245558453',
            body: 'New Upload',
            mediaUrl: url,
            from: '+18474570194'
          TwilioSMSLambda {'message': message}, (err, smsResult) ->
            console.log err, smsResult
          
            
    check = (assembly_url) ->
      $timeout(=>
        $http.get(assembly_url).success((transloadit) =>
          if transloadit.ok is "ASSEMBLY_COMPLETED"
            data = {}
            angular.forEach transloadit.results, (val, key) ->
              url = transloadit.results[key][0].url
              data[key] = url
              newRecord.$update(data)
#               notifyOfUpload(url)
            newRecord.$set 'status',"completed"
            newRecord.$set 'progress', 100
          else
            check(assembly_url)
          return
        )
      , 2000)
    return {
      croppedSteps: croppedSteps
      thumbSteps: thumbSteps
      upload: upload
      #for an existing record OR external url
      addThumb: -> upload(thumbSteps)
      actualCrop: (xyxy) -> 
        croppedSteps.cropped.crop = xyxy
        upload(croppedSteps)
      addCropped: -> upload(croppedSteps)
      #for uploads
      addFromUpload: () -> upload(newUrlSteps)
    }



.directive "filePickerModal", ->
  restrict: "E"
  template: """
  <button type="button" class="btn btn-primary" data-animation="am-fade-and-scale" data-template="transloader/modal.html" bs-modal="modal">Attach File(s)
  </button>
  """
  controller: "FilesCtrl"

.directive "fileUploader", ->
  restrict: "E"
  templateUrl: 'transloader/uploader.html'
  controller: "FilesCtrl"
  
.controller "FilesCtrl", (Auth, $scope, $rootScope, UploadFiles, Transloaderv5, $routeParams, $location) ->
  Auth.$onAuth (user) ->
    if user is null
      console.log "error: please sign in to use uploader module"
      return
    $scope.all = UploadFiles(user.uid)

  $scope.remove = (obj, type) ->
    delete obj[type]
    $scope.all.$save(obj)

  $scope.addFromUpload = (files) =>
    for file in files
      do (file) ->
        record = {':originalFile': file}
        $scope.all.$add(record).then (ref) ->
          record.$id = ref.key()
          Transloaderv5(record).addFromUpload()  

  $scope.addFromUrl = (url) =>
    record = {':original': url}
    $scope.all.$add(record).then (ref) ->
      record.$id = ref.key()
      Transloaderv5(record).addThumb()

  $scope.appendThumbToRecord = (record) =>
    Transloaderv5(record).addThumb()

  $scope.appendCroppedToRecord = (record, opts) =>
    Transloaderv5(record).addCropped(opts)
  $scope.actualCrop = (record, xyxy) =>
    Transloaderv5(record).actualCrop(xyxy)

  $scope.newMessage = {}

  $scope.insert = (assembly) ->
    console.log assembly
    $scope.newMessage.thumb = assembly.thumb
    $scope.newMessage.attachment = assembly[':original']

  $scope.select = (assembly) ->
    $scope.selectedAssembly = assembly

  $scope.onSelected = (record) ->
    $scope.addMessage({attachment: record[':original'], thumb: record.thumb, text: 'i attached a file'})


