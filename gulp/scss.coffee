# Compile .scss file extension, sourcemap, write and minify
#
module.exports = (gulp, plugins, paths) =>
  # Handle Scss _partial files by compiling the base file in which they are
  # imported and used
  #
  scss_partial = (input) ->
    if input.basename[0] == '_'
      newdir = input.dirname.split('/')
      newpath = paths.assets_src + paths.scss + newdir[0] + '/' + newdir[0] + input.extname
      delete plugins.cached.caches[input.extname][require('path').resolve(newpath)]
    return

  return =>
    gulp.src(paths.assets_src + paths.sass + '**/*.scss')
      .pipe(plugins.rename(scss_partial))
      .pipe(plugins.cached('.scss'))
      .pipe(plugins.filelog())
      .pipe(plugins.sourcemaps.init())
      .pipe(plugins.sass(outputStyle: 'expanded').on('error', plugins.sass.logError))
      .pipe(plugins.autoprefixer())
      .pipe(plugins.sourcemaps.write('../' + paths.maps))
      .pipe(gulp.dest(paths.assets_src + paths.css))
      .pipe(plugins.ignore.exclude([ '**/*.map' ]))
      .pipe(plugins.cssmin())
      .pipe(plugins.rename(suffix: '.min'))
      .pipe(gulp.dest(paths.assets_dist + paths.css))
      .pipe(plugins.livereload())
