# Run LiveReload server
#
module.exports = (gulp, plugins, paths) =>
  return =>
    plugins.livereload.listen()

    for application in paths.livereload
      # gulp.watch application + '/assets/**/*.css', =>
      #   plugins.livereload.reload()
      #   return

      gulp.watch application + '/views/**/*.op', =>
        plugins.livereload.reload()
        return

    return
