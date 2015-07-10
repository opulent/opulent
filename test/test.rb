require_relative '../lib/opulent.rb'
require 'pp'

opulent = Opulent.new
puts opulent.render_file('test.op', a: 2, b: 1){}
puts
pp opulent.nodes
