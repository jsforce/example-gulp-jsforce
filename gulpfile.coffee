gulp = require "gulp"
zip = require "gulp-zip"
less = require "gulp-less"
streamify = require "gulp-streamify"
uglify = require "gulp-uglify"
minify = require "gulp-minify-css"
browserify = require "browserify"
source = require "vinyl-source-stream"
del = require "del"
through2 = require "through2"
jsforce = require "jsforce"

#
gulp.task "css", ->
  gulp.src "./src/styles/main.less"
    .pipe less()
    .pipe minify()
    .pipe gulp.dest "./build/css"

#
gulp.task "js", ->
  browserify
    entries: [ "./src/scripts/main.coffee" ]
    extensions: [ ".coffee" ]
  .bundle()
  .pipe source "main.js"
#  .pipe streamify uglify()
  .pipe gulp.dest "./build/js"

# 
gulp.task "statics", ->
  gulp.src [ "./src/**/*.html", "./src/images/**/*" ], base: "./src"
    .pipe gulp.dest "./build"

#
gulp.task "zip", [ "css", "js", "statics" ], ->
  gulp.src "./build/**/*"
    .pipe zip("MyApp.resource")
    .pipe gulp.dest "./pkg/staticresources"

#
gulp.task "clean", ->
  del [ "./build" ]

#
gulp.task "build", [ "zip" ]

###
# 
###
forceDeploy = (username, password) ->
  through2.obj (file, enc, callback) ->
    conn = new jsforce.Connection()
    conn.login username, password
    .then ->
      conn.metadata.deploy(file.contents).complete(details: true)
    .then (res) ->
      if res.details?.componentFailures
        console.error res.details?.componentFailures
        return callback(new Error('Deploy failed.'))
      callback()
    , (err) ->
      console.error(err)
      callback(err)

###
# Deploying package to Salesforce
###
gulp.task "deploy", ->
  gulp.src "./pkg/**/*", base: "."
    .pipe zip("pkg.zip")
    .pipe forceDeploy(process.env.SF_USERNAME, process.env.SF_PASSWORD)

#
gulp.task "watch", [ "build" ], ->
  gulp.watch "./src/**/*", [ "build" ]
  gulp.watch "./pkg/**/*", [ "deploy" ]

#
gulp.task "default", [ "build", "deploy" ]
