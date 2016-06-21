get_folders = require('./get-folders')

# Handle plugin preprocessing and copy them to the application assets folder
#
module.exports['opulent-page'] = (gulp, plugins, paths) =>
  return =>
    gulp.src(paths.views + '**/*.op')
      .pipe(plugins.cached('.op'))
      .pipe(plugins.filelog())
      .pipe(plugins.shell(['ruby render_page.rb <%= path(file.path) %>'],
        cwd: paths.fixtures
        templateData:
          path: (file) ->
            f = file.match(/\w+\/[0-9a-z\-\_]+\.op+$/g)
            return f[0]
      ))

# Handle plugin preprocessing and copy them to the application assets folder
#
module.exports['opulent-all'] = (gulp, plugins, paths) =>
  plugins.shell.task(['ruby render_all.rb'], cwd: paths.fixtures)

# Handle plugin preprocessing and copy them to the application assets folder
#
module.exports['generate-pages'] = (gulp, plugins, paths) =>
  plugins.shell.task(
    ['ruby generate_pages.rb'], cwd: paths.fixtures)
