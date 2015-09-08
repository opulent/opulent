require 'benchmark'
require_relative '../lib/opulent'

# Choose the benchmark you want to run
BENCHMARK = :node

# How many times each command should be run
N = 0

# Templating engine initialization
puts "BENCHMARK\n--\n"

case BENCHMARK
when :node
  case_folder = 'cases/node/'
  opulent = Tilt.new("#{case_folder}node.op")
  opulent2 = Tilt.new("#{case_folder}yield.op", def: opulent.def)
  slim = Tilt.new("#{case_folder}node.slim")
  haml = Tilt.new("#{case_folder}node.haml")

  locals = {
    a: 3,
    b: 4,
    c: 5
  }

  scope = Object.new

  op = Opulent.new :"#{case_folder}node"
  op2 = Opulent.new :"#{case_folder}yield", def: op.def

  puts op.render(op, locals){
    op2.render(op, locals){}
  }

  puts op.render(Object.new, locals){
    op2.render(opulent, locals){}
  }

  puts "\n\n"

  #puts op.template
  puts "\n\n"

  Benchmark.bm do |x|
    x.report("haml") do
      N.times do
        haml.render(scope, locals){}
      end
    end
    x.report("opulent") do
      N.times do
        opulent.render(scope, locals){
          opulent.render(scope, locals){}
        }
      end
    end
    x.report("slim") do
      N.times do
        slim.render(scope, locals){}
      end
    end
  end
end
