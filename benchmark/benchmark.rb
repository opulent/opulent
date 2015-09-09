require 'benchmark'
require_relative '../lib/opulent'

# Choose the benchmark you want to run
BENCHMARK = :node

# How many times each command should be run
N = 1000

# Templating engine initialization
puts "BENCHMARK\n--\n"

case BENCHMARK
when :node
  case_folder = 'cases/node/'
  opulent = Tilt.new("#{case_folder}node.op")
  slim = Tilt.new("#{case_folder}node.slim")
  haml = Tilt.new("#{case_folder}node.haml")

  locals = {
    a: 3,
    b: 4,
    c: 5
  }

  op = Opulent.new :"#{case_folder}node"
  # op2 = Opulent.new :"#{case_folder}yield", def: op.def

  puts op.render(op, locals){}
  #
  # puts op.render(op, locals){
  #   op2.render(op, locals){}
  # }

  puts "\n\n"

  puts op.template
  puts "\n\n"

  Benchmark.bm do |x|
    x.report("haml") do
      N.times do
        haml.render(Object.new, locals){}
      end
    end
    x.report("opulent") do
      N.times do
        opulent.render(Object.new, locals){}
      end
    end
    x.report("slim") do
      N.times do
        slim.render(Object.new, locals){}
      end
    end
  end
end
