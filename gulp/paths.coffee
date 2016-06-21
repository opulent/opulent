# Application Paths
#
module.exports = =>
  paths = {}
  paths.maps = 'maps/'
  paths.assets_src = 'src/'
  paths.assets_dist = 'assets/'
  paths.sass = 'sass/'
  paths.css = 'css/'
  paths.coffee = 'coffee/'
  paths.js = 'js/'
  paths.fonts = 'fonts/'
  paths.video = 'video/'
  paths.icon = 'icon/'
  paths.img = 'img/'
  paths.plugins = '../plugins/'
  paths.views = 'views/'
  paths.fixtures = 'fixtures/'

  paths.livereload = ['pixevil', 'rock-slider', 'opulent']

  return paths
