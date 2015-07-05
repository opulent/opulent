require 'benchmark'
require_relative '../lib/opulent.rb'

code = File.read 'test.op'
engine = Opulent.new

# Benchmark.bm do |x|
#   x.report do
#     1000.times do
#       engine.render code
#     end
#   end
# end

engine.render(code, test: "hello"){}
