# Express task which we use to create a local server connection which serves
# static_site files on the port 4000
#
module.exports = (gulp, plugins, paths) =>
  return =>
    express = require('express')
    app = express()
    app.use require('connect-livereload')(port: 4002)
    app.use express.static(paths.application)
    app.listen 4000
    return
