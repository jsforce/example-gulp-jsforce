$ = require "jquery"
moment = require "moment"
$ ->
  $(".result")
    .html '<h1>Current datetime : <span class="datetime"></span></h1>'
    .find ".datetime"
    .text moment().format("MMMM Do YYYY, h:mm:ss a")
