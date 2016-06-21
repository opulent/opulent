# Include gulp
gulp = require('gulp')
paths = require('./gulp/paths')()
plugins = require('gulp-load-plugins')()
runsequence = require('run-sequence')
express = require('express')

# LiveReload port for current application
livereload_port = 35729

# Collect plugins
collect_plugins = [
  'animus'
  'slidea'
  # 'revelate'
  # 'smoothscroll'
  # 'visuallax'
  # 'image-centered'
]

# Plugin concatentation settings
#
make_plugins = [
  'slidea'
]

static_site = true

gulp.task 'express', =>
  app = express()
  app.use(require('connect-livereload')())
  app.use(express.static(__dirname))
  app.listen(8000)
  return

# JS
gulp.task('coffee', require('./gulp/coffee')(gulp, plugins, paths));
gulp.task('jsmin', require('./gulp/js')(gulp, plugins, paths));

# CSS
gulp.task('sass', require('./gulp/sass')(gulp, plugins, paths));
gulp.task('scss', require('./gulp/scss')(gulp, plugins, paths));
gulp.task('cssmin', require('./gulp/css')(gulp, plugins, paths));

# Fonts
gulp.task('fonts-copy', require('./gulp/copy').fonts(gulp, plugins, paths));

# Icons
gulp.task('icons-copy', require('./gulp/copy').icons(gulp, plugins, paths));

# Videos
gulp.task('videos-copy', require('./gulp/copy').videos(gulp, plugins, paths));

# Images
gulp.task('imagemin', require('./gulp/images')(gulp, plugins, paths));

# Opulent
gulp.task('opulent-all', require('./gulp/opulent')['opulent-all'](gulp, plugins, paths));
gulp.task('opulent-page', require('./gulp/opulent')['opulent-page'](gulp, plugins, paths));
gulp.task('generate-pages', require('./gulp/opulent')['generate-pages'](gulp, plugins, paths));

# Plugins
gulp.task('plugins-coffee', require('./gulp/plugins').coffee(gulp, plugins, paths, collect_plugins));
gulp.task('plugins-sass', require('./gulp/plugins').sass(gulp, plugins, paths, collect_plugins));

gulp.task('plugins-make', require('./gulp/plugins').make(gulp, plugins, paths, make_plugins));

# Complete build
gulp.task('build', require('./gulp/build')(gulp, runsequence));
gulp.task('make', require('./gulp/build')(gulp, runsequence));

# Require Watch file
gulp.task('watch', require('./gulp/watch')(gulp, plugins, paths, livereload_port, make_plugins, static_site));

# Default task which is run using the 'gulp' command
gulp.task 'default', [
  'express'
  'watch'
]
