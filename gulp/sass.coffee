# Compile .sass file extension, sourcemap, write and minify
#
module.exports = (gulp, plugins, paths) =>
  # Handle Sass _partial files by compiling the base file in which they are
  # imported and used
  #
  sass_partial = (input) ->
    if input.basename[0] == '_'
      newdir = input.dirname.split('/')
      newpath = paths.assets_src + paths.sass + newdir[0] + '/' + newdir[0] + input.extname
      delete plugins.cached.caches[input.extname][require('path').resolve(newpath)]
    return

  return =>
    gulp.src(paths.assets_src + paths.sass + '**/*.sass')
      .pipe(plugins.rename(sass_partial))
      .pipe(plugins.cached('.sass'))
      .pipe(plugins.filelog())
      .pipe(plugins.sourcemaps.init())
      .pipe(plugins.sass( 
        outputStyle: 'expanded'
        indentedSyntax: true).on('error', plugins.sass.logError))
      .pipe(plugins.autoprefixer())
      .pipe(plugins.sourcemaps.write('../' + paths.maps))
      .pipe(gulp.dest(paths.assets_src + paths.css))
      .pipe(plugins.ignore.exclude([ '**/*.map' ]))
      .pipe(plugins.cssmin())
      .pipe(plugins.rename(suffix: '.min'))
      .pipe(gulp.dest(paths.assets_dist + paths.css))
      .pipe(plugins.livereload())
