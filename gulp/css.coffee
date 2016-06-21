# Minify found css files
#
module.exports = (gulp, plugins, paths) =>
  return =>
    gulp.src(paths.assets_src + paths.css + '**/*.css')
      .pipe(plugins.cached('.css'))
      .pipe(plugins.filelog())
      .pipe(plugins.cssmin())
      .pipe(plugins.rename(suffix: '.min'))
      .pipe gulp.dest(paths.assets_dist + paths.css)
