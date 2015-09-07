require 'benchmark'
require_relative '../lib/opulent'

# Choose the benchmark you want to run
BENCHMARK = :node

# How many times each command should be run
N = 1000

a = 1
c = lambda do
  a + 1
end
puts c.call

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

  scope = Object.new

  op = Opulent.new
  puts op.render(:"#{case_folder}node", locals){}
  puts "\n\n"

  puts op.template
  puts "\n\n\n"

  Benchmark.bm do |x|
    x.report("haml") do
      N.times do
        # a = 1
        # Proc.new do |a|
        #   binding = nil
        #   a = 2
        #   b = 4
        #   Proc.new do |a|
        #     binding = nil
        #     a = 3
        #   end[]
        # end[]
        haml.render(scope, locals){}
      end
    end
    x.report("opulent") do
      N.times do
        # a = 1
        # def a1
        #   a = 2
        #   b = 4
        #   def a2
        #     a = 3
        #   end
        #   a2()
        # end
        # a1()

        opulent.render(scope, locals){}
      end
    end
    x.report("slim") do
      N.times do
        slim.render(scope, locals){}
      end
    end
  end
end
