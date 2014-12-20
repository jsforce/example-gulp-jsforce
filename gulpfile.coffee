gulp = require "gulp"
zip = require "gulp-zip"
browserify = require "browserify"
source = require "vinyl-source-stream"
through2 = require "through2"
jsforce = require "jsforce"

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

gulp.task "build", ->
  browserify
    entries: [ "./src/scripts/hello-controller.coffee" ]
    extensions: [ ".coffee" ]
    standalone: 'stomitaAuraDev'
  .bundle()
  .pipe source "HelloComponentJavaScript.resource"
  .pipe gulp.dest "pkg/staticresources/"

gulp.task "deploy", ->
  gulp.src "pkg/**/*", base: "."
    .pipe zip('pkg.zip')
    .pipe forceDeploy(process.env.SF_USERNAME, process.env.SF_PASSWORD)

gulp.task "watch", ->
  gulp.watch "src/**/*", [ "build" ]
  gulp.watch "pkg/**/*", [ "deploy" ]

gulp.task "default", [ "build", "deploy" ]
