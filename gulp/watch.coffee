# Watch for file changes
module.exports = (gulp, plugins, paths, livereload_port, make, static_site) =>
  return =>
    plugins.livereload.listen
      port: livereload_port

    gulp.watch paths.assets_src + paths.coffee + '**/*.coffee', [ 'coffee' ]
    gulp.watch paths.assets_src + paths.js + '**/*.js', ['jsmin']

    gulp.watch paths.assets_src + paths.sass + '**/*.scss', [ 'scss' ]
    gulp.watch paths.assets_src + paths.sass + '**/*.sass', [ 'sass' ]
    gulp.watch paths.assets_src + paths.css + '**/*.css', ['cssmin']

    gulp.watch paths.assets_src + paths.img + '**/*', [ 'imagemin' ]

    gulp.watch paths.assets_src + paths.fonts + '**/*', [ 'fonts-copy' ]
    gulp.watch paths.assets_src + paths.video + '**/*', [ 'videos-copy' ]
    gulp.watch paths.assets_src + paths.icon + '**/*', [ 'icons-copy' ]

    gulp.watch paths.plugins + '**/*.sass', [ 'plugins-sass' ]
    gulp.watch paths.plugins + '**/*.coffee', [ 'plugins-coffee' ]

    gulp.watch paths.views + '**/*.op', =>
      plugins.livereload.reload()
      return

    for key in make
      gulp.watch paths.plugins + "#{key}/**/*.coffee", [ 'plugins-make' ]

    if static_site
      gulp.watch [
        paths.views + 'layouts/**/*.op'
        paths.views + 'partials/**/*.op'
        paths.views + 'definitions/**/*.op'
        paths.fixtures + '*.yml'
      ], [ 'opulent-all' ]

      gulp.watch [
        paths.views + '**/*.op'
      ], [ 'opulent-page' ]

      gulp.watch [
        paths.fixtures + 'pages.yml'
      ], [ 'generate-pages' ]

    return
