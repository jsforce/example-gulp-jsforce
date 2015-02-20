gulp = require "gulp"
zip = require "gulp-zip"
less = require "gulp-less"
streamify = require "gulp-streamify"
uglify = require "gulp-uglify"
minify = require "gulp-minify-css"
browserify = require "browserify"
source = require "vinyl-source-stream"
del = require "del"
forceDeploy = require "gulp-jsforce-deploy"

# Building CSS files from LESS source
gulp.task "css", ->
  gulp.src "./src/styles/main.less"
    .pipe less()
    .pipe minify()
    .pipe gulp.dest "./build/css"

# Compile and bundle JS file from CoffeeScript source code
gulp.task "js", ->
  browserify
    entries: [ "./src/scripts/main.coffee" ]
    extensions: [ ".coffee" ]
  .bundle()
  .pipe source "main.js"
  .pipe streamify uglify()
  .pipe gulp.dest "./build/js"

# Copy all static files in src directory to temporary build directory
gulp.task "statics", ->
  gulp.src [ "./src/**/*.html", "./src/images/**/*" ], base: "./src"
    .pipe gulp.dest "./build"

# Zip all built files as a static resource file
gulp.task "zip", [ "css", "js", "statics" ], ->
  gulp.src "./build/**/*"
    .pipe zip("MyApp.resource")
    .pipe gulp.dest "./pkg/staticresources"

# Build
gulp.task "build", [ "zip" ]

# Cleanup built files
gulp.task "clean", ->
  del [ "./build" ]

###
# Deploying package to Salesforce
###
gulp.task "deploy", ->
  gulp.src "./pkg/**/*", base: "."
    .pipe zip("pkg.zip")
    .pipe forceDeploy
      username: process.env.SF_USERNAME
      password: process.env.SF_PASSWORD
      # loginUrl: "https://test.salesforce.com"
      # pollTimeout: 120*1000
      # pollInterval: 10*1000
      # version: '33.0'

#
gulp.task "watch", ->
  gulp.watch "./src/**/*", [ "build" ]
  gulp.watch "./pkg/**/*", [ "deploy" ]

# Default entry point
gulp.task "default", [ "build", "deploy" ]
