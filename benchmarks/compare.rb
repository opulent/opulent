require 'opulent'
require 'slim'

test_case = ARGV[0] ? ARGV[0] : "page"

opulent_code = File.read(File.dirname(__FILE__) + "/#{test_case}/view.op")
slim_code = File.read(File.dirname(__FILE__) + "/#{test_case}/view.op")

opulent = Opulent.new opulent_code
slim = Slim::Engine.new.call slim_code

puts "\n\n\nOPULENT -----"
puts opulent.template
puts "\n\n\nSLIM -----"
puts slim
