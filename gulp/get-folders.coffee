# Get all folders from a input directory path
#
module.exports = =>
  return (dir) ->
    fs.readdirSync(dir).filter (file) ->
      fs.statSync(path.join(dir, file)).isDirectory()
