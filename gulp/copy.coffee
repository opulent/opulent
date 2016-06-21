# Copy all the files which won't be changed from the source folder to the
# distribution folder
#
module.exports.fonts = (gulp, plugins, paths) =>
  return =>
    gulp.src(paths.assets_src + paths.fonts + '**/*.*')
      .pipe(plugins.cached('fontcopy'))
      .pipe(plugins.filelog())
      .pipe gulp.dest(paths.assets_dist + paths.fonts)

module.exports.icons = (gulp, plugins, paths) =>
  return =>
    gulp.src(paths.assets_src + paths.icon + '**/*.*')
      .pipe(plugins.cached('icons'))
      .pipe(plugins.filelog())
      .pipe gulp.dest(paths.assets_dist + paths.icon)

module.exports.videos = (gulp, plugins, paths) =>
  return =>
    gulp.src(paths.assets_src + paths.video + '**/*.*')
      .pipe(plugins.cached('videos'))
      .pipe(plugins.filelog())
      .pipe gulp.dest(paths.assets_dist + paths.video)
