require_relative '../lib/opulent.rb'
require 'pp'

a = 44

opulent = Opulent.new
puts opulent.render(:test, e: '123', b: 1){}
