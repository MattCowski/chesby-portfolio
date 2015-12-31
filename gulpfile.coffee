gulp = require('gulp')
awspublish = require('gulp-awspublish')
gutil = require('gulp-util')
connect = require('gulp-connect')
gulpif = require('gulp-if')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
tplCache = require('gulp-angular-templatecache')
jade = require('gulp-jade')
less = require('gulp-less')
uglify = require 'gulp-uglify'
minifyCss = require('gulp-minify-css')
ngAnnotate = require('gulp-ng-annotate')
rename = require("gulp-rename")
dist = './public'
merge = require('merge-stream')
protractor = require('gulp-protractor').protractor
# var webdriver_standalone = require("gulp-protractor").webdriver_standalone;

gulp.task 'publish', ->
  # create a new publisher using S3 options
  # http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#constructor-property
  publisher = awspublish.create(params:{Bucket: 'chesby.com'})
  # define custom headers
  headers = 'Cache-Control': 'max-age=120, public'
  
#   gzip = gulp.src(['./public/**/*.js', './public/**/*.css']).pipe(awspublish.gzip())
#   plain = gulp.src([ 'public/**/*', '!public/**/*.js', '!public/**/*.css' ])
#   merge(gzip, plain)
  gulp.src('./public/**/*').pipe(awspublish.gzip())
  .pipe(publisher.publish(headers, {force: false}))
  .pipe(publisher.sync())
  #   .pipe(publisher.cache())
  .pipe(awspublish.reporter())
gulp.task 'appJS', ->
  # concatenate compiled .coffee files and js files
  # into build/app.js
  gulp.src([
    '!./app/**/*_test.js'
    '!./app/**/*_e2e.js'
    './app/**/*.js'
    '!./app/**/*_test.coffee'
    '!./app/**/*_e2e.coffee'
    './app/**/*.coffee'
  ])
  .pipe(gulpif(/[.]coffee$/, coffee(bare: true).on('error', gutil.log)))
  .pipe(ngAnnotate())
  .pipe(concat('app.js'))
  .pipe gulp.dest(dist)
  .pipe(uglify())
  .pipe(rename({extname: ".min.js"}))
  .pipe gulp.dest(dist)
  return
gulp.task 'e2e_testJS', ->
  # gulp.task('webdriver_standalone', webdriver_standalone);
  gulp.src([ './app/**/*_e2e.coffee' ]).pipe(gulpif(/[.]coffee$/, coffee(bare: true).on('error', gutil.log))).pipe(gulp.dest(dist)).pipe(protractor(
    configFile: 'protractor.config.js'
    args: [
      '--baseUrl'
      'http://localhost:9001'
    ])).on 'error', gutil.log
  return
gulp.task 'testJS', ->
  # Compile JS test files. Not compiled.
  gulp.src([
    './app/**/*_test.js'
    './app/**/*_test.coffee'
  ])
  .pipe(gulpif(/[.]coffee$/, coffee(bare: true).on('error', gutil.log)))
  .pipe gulp.dest(dist)
  return
gulp.task 'templates', ->
  # combine compiled Jade and html template files into 
  # build/template.js
  gulp.src([
    '!./app/index.jade'
    '!./app.index.html'
    './app/**/*.html'
    './app/**/*.jade'
  ])
  .pipe(gulpif(/[.]jade$/, jade().on('error', gutil.log)))
  .pipe(tplCache('templates.js', standalone: true))
  .pipe gulp.dest(dist)
  .pipe(uglify())
  .pipe(rename({extname: ".min.js"}))
  .pipe gulp.dest(dist)
  return
gulp.task 'appCSS', ->
  # concatenate compiled Less and CSS
  # into build/app.css
  gulp.src([
    './app/**/*.less'
    './app/**/*.css'
  ]).pipe(gulpif(/[.]less$/, less(paths: [ './bower_components/bootstrap/less' ]).on('error', gutil.log))).pipe(concat('app.css'))
  .pipe(minifyCss())
  .pipe gulp.dest(dist)
  return
gulp.task 'libJS', ->
  # concatenate vendor JS into build/lib.js
  gulp.src([
#     './bower_components/lodash/dist/lodash.js'
#     './bower_components/jquery/dist/jquery.js'
#     './bower_components/bootstrap/dist/js/bootstrap.js'
    './bower_components/ng-file-upload/angular-file-upload-shim.js'
#     './bower_components/angular/angular.js'
#     './bower_components/angular-mocks/angular-mocks.js'
    './bower_components/ng-file-upload/angular-file-upload.js'
    './bower_components/angular-cookies/angular-cookies.js'
    './bower_components/angular-animate/angular-animate.js'
    './bower_components/angular-sanitize/angular-sanitize.js'
    './bower_components/angular-route/angular-route.js'
#     './bower_components/angularfire/dist/angularfire.min.js'
#     './bower_components/firebase/firebase.js'
#     './bower_components/firebase-util/firebase-util.js'
#     './bower_components/firebase-simple-login/firebase-simple-login.js'
#     './bower_components/ng-token-auth/dist/ng-token-auth.js'
#     './bower_components/jquery-ui/ui/jquery-ui.js'
    './bower_components/angular-motion/dist/angular-motion.js'
    './bower_components/angular-strap/dist/angular-strap.js'
    './bower_components/angular-strap/dist/angular-strap.tpl.js'
    './bower_components/angular-bootstrap/ui-bootstrap-tpls.js'
    './bower_components/angular-ui-utils/ui-utils.js'
    './bower_components/angular-ui-utils/mask.js'
    './bower_components/angularjs-scroll-glue/src/scrollglue.js'
    '../authentication/public/app.js'
    '../authentication/public/templates.js'
  ])
  .pipe(concat('lib.js'))
  .pipe gulp.dest(dist)
  .pipe(uglify())
  .pipe(rename({extname: ".min.js"}))
  .pipe gulp.dest(dist)
  return
gulp.task 'libCSS', ->
  # concatenate vendor css into build/lib.css
  gulp.src([
    '!./bower_components/**/*.min.css'
    './bower_components/**/*.css'
  ]).pipe(concat('lib.css')).pipe(minifyCss()).pipe gulp.dest(dist)
  return
gulp.task 'index', ->
  gulp.src([
    './app/index.jade'
    './app/index.html'
  ]).pipe(gulpif(/[.]jade$/, jade().on('error', gutil.log))).pipe gulp.dest(dist)
  return
gulp.task 'watch', ->
  # reload connect server on built file change
  gulp.watch [
    dist + '/**/*.html'
    dist + '/**/*.js'
    dist + '/**/*.css'
  ], (event) ->
    gulp.src(event.path).pipe connect.reload()
  # watch files to build
  gulp.watch [
    './app/**/*.coffee'
    '!./app/**/*_test.coffee'
    '!./app/**/*_e2e.coffee'
    './app/**/*.js'
    '!./app/**/*_test.js'
    '!./app/**/*_e2e.js'
  ], [ 'appJS' ]
  gulp.watch [
    './app/**/*_test.coffee'
    './app/**/*_test.js'
  ], [ 'testJS' ]
  gulp.watch [
    './app/**/*_e2e.coffee'
    './app/**/*_e2e.js'
  ], [ 'e2e_testJS' ]
  gulp.watch [
    '!./app/index.jade'
    '!./app/index.html'
    './app/**/*.jade'
    './app/**/*.html'
  ], [ 'templates' ]
  gulp.watch [
    './app/**/*.less'
    './app/**/*.css'
  ], [ 'appCSS' ]
  gulp.watch [
    './app/index.jade'
    './app/index.html'
  ], [ 'index' ]
  return

gulp.task 'connect', connect.server(
  root: [ dist ]
  port: 4000
  livereload: port: 1337
  middleware: (connect, o) ->
    [ do ->
      url = require('url')
      proxy = require('proxy-middleware')
      options = url.parse('http://localhost:9001/api/')
      options.route = '/api'
      proxy options
    ]
)
gulp.task 'default', [
  'connect'
  'appJS'
  'testJS'
  'templates'
  'appCSS'
  'index'
  'libJS'
  'libCSS'
  'watch'
]