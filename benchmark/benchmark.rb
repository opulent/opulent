require 'benchmark'
require_relative '../lib/opulent'
require 'slim'
require 'haml'

# Choose the benchmark you want to run
BENCHMARK = :node

# How many times each command should be run
N = 1000

# Templating engine initialization
puts "BENCHMARK"
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

  scope = Object.new

  Benchmark.bm do |x|
    x.report("haml") do
      N.times do
        haml.render(scope, locals) do end
      end
    end
    x.report("opulent") do
      N.times do
        opulent.render(scope, locals) do end
      end
    end
    x.report("slim") do
      N.times do
        slim.render(scope, locals) do end
      end
    end
  end
end
