# Optimize images for the web
#
module.exports = (gulp, plugins, paths) =>
  return =>
    # pngquant = require('imagemin-pngquant')
    # gifsicle = require('imagemin-gifsicle')
    # jpegtran = require('imagemin-jpegtran')

    gulp.src(paths.assets_src + paths.img + '**/*.{jpg,png,gif}')
      .pipe(plugins.cached('img'))
      .pipe(plugins.filelog())
      .pipe(plugins.imagemin(
        svgoPlugins: [ { removeViewBox: false } ]
        optimizationLevel: 3,
        progessive: true,
        interlaced: true
        # use: [pngquant(), gifsicle(), jpegtran()]
      ))
      .pipe gulp.dest(paths.assets_dist + paths.img)
