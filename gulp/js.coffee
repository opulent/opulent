# Minify found js files
#
module.exports = (gulp, plugins, paths) =>
  return =>
    gulp.src(paths.assets_src + paths.js + '**/*.js')
      .pipe(plugins.cached('.js'))
      .pipe(plugins.filelog())
      .pipe(plugins.uglify())
      .pipe(plugins.rename(suffix: '.min'))
      .pipe gulp.dest(paths.assets_dist + paths.js)
