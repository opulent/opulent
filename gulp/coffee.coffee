# Handle Coffee _partial files by compiling the base file in which they are
# imported and used
#
coffee_partial = (input) ->
  if input.basename[0] == '_'
    newdir = input.dirname.split('/')
    newpath = paths.assets_src + paths.coffee + newdir[0] + '/' + newdir[0] + input.extname
    delete plugins.cache.caches[input.extname][require('path').resolve(newpath)]
  return

# Compile .coffee file extension, sourcemap, write and minify
#
module.exports = (gulp, plugins, paths) =>
  return =>
    gulp.src(paths.assets_src + paths.coffee + '**/*.coffee')
      .pipe(plugins.cached('.coffee'))
      .pipe(plugins.filelog())
      .pipe(plugins.sourcemaps.init())
      .pipe(plugins.coffee().on('error', console.log))
      .pipe(plugins.sourcemaps.write('../' + paths.maps))
      .pipe(gulp.dest(paths.assets_src + paths.js))
      .pipe(plugins.ignore.exclude([ '**/*.map' ]))
      .pipe(plugins.uglify().on('error', console.log))
      .pipe(plugins.rename(suffix: '.min'))
      .pipe(gulp.dest(paths.assets_dist + paths.js))
      .pipe(plugins.livereload())
