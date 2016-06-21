# Make the project by running all the build tasks
#
module.exports = (gulp, runsequence) =>
  return =>
    runsequence [
      'plugins-coffee'
      'plugins-sass'
    ], [
      'coffee'
      'sass'
      'scss'
      'fonts-copy'
      'icons-copy'
      'videos-copy'
      'imagemin'
    ], [
      'cssmin'
      'jsmin'
    ]
