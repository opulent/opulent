require_relative '../lib/opulent.rb'
require 'pp'

a = '<div></div>'
opulent = Opulent.new
puts opulent.render_file('test.op', a: '<div></div>', b: 1){
  opulent.render_file('attributes.op')
}
puts
