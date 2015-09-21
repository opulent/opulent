require_relative '../lib/opulent.rb'
require 'pp'

locals = {
  a: 3,
  b: 4,
  c: 5
}

op = Opulent.new :test

puts op.render(op, locals){}
