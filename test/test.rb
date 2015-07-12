require_relative '../lib/opulent.rb'
require 'pp'

a = 4
opulent = Opulent.new
puts opulent.render_file('test.op', a: 2, b: 1){
  opulent.render_file('attributes.op')
}
puts
