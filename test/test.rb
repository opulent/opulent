require_relative '../lib/opulent.rb'
require 'pp'

opulent = Opulent.new
content = opulent.render_file('attributes.op'){}
puts opulent.render_file('test.op', a: 2, b: 1){ opulent.render_file('attributes.op'){} }
