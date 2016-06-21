get_folders = require('./get-folders')

# Handle plugin preprocessing and copy them to the application assets folder
#
module.exports.coffee = (gulp, plugins, paths, collect_plugins) =>
  return =>
    for plugin in collect_plugins
      # plugins.merge get_folders(paths.plugins).map (folder) =>
      gulp.src(paths.plugins + "#{plugin}/coffee/#{plugin}/**/*.coffee")
        .pipe(plugins.cached('plugins-coffee'))
        .pipe(plugins.filelog())
        .pipe gulp.dest(paths.assets_src + paths.coffee + "#{plugin}/")

# Handle plugin preprocessing and copy them to the application assets folder
#
module.exports.sass = (gulp, plugins, paths, collect_plugins) =>
  return =>
    for plugin in collect_plugins
      # plugins.merge get_folders(paths.plugins).map (folder) =>
      gulp.src(paths.plugins + "#{plugin}/sass/#{plugin}/**/*.sass")
        .pipe(plugins.cached('plugins-sass'))
        .pipe(plugins.filelog())
        .pipe gulp.dest(paths.assets_src + paths.sass + "#{plugin}/")

# Handle plugin preprocessing and copy them to the application assets folder
#
module.exports.make = (gulp, plugins, paths, make) =>
  return =>
    for key in make 
      gulp.src(paths.plugins + "#{key}/coffee/#{key}/#{key}.coffee")
        .pipe(plugins.filelog())
        .pipe(plugins.sourcemaps.init())
        .pipe(plugins.include()).on('error', console.log)
        .pipe(plugins.coffee().on('error', console.log))
        .pipe(plugins.rename(prefix: 'pixevil.'))
        .pipe(plugins.sourcemaps.write('../' + paths.maps))
        .pipe(gulp.dest(paths.assets_src + paths.js + "#{key}/"))
        .pipe(plugins.ignore.exclude([ '**/*.map' ]))
        .pipe(plugins.uglify().on('error', console.log))
        .pipe(plugins.rename(suffix: '.min'))
        .pipe(gulp.dest(paths.assets_dist + paths.js + "#{key}/"))
        .pipe(plugins.livereload())
