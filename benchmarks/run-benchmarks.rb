#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

W = 5000
N = 100000

require 'benchmark'
require 'benchmark/ips'

require 'tilt'
require '../lib/opulent'
require 'erubis'
require 'erb'
require 'haml'
require 'slim'

require_relative 'context'

class Benchmarks
  def initialize(test_case)
    @benches = Hash.new { |h, k| h[k] = [] }

    test_case = "page" unless test_case

    @opulent_code = File.read(File.dirname(__FILE__) + "/#{test_case}/view.op")
    @erb_code = File.read(File.dirname(__FILE__) + "/#{test_case}/view.erb")
    @haml_code = File.read(File.dirname(__FILE__) + "/#{test_case}/view.haml")
    @slim_code = File.read(File.dirname(__FILE__) + "/#{test_case}/view.slim")

    init_compiled_benches
    init_tilt_benches
    init_parsing_benches
  end

  def init_compiled_benches
    haml_pretty = Haml::Engine.new(@haml_code, format: :html5, escape_attrs: false)
    haml_ugly   = Haml::Engine.new(@haml_code, format: :html5, ugly: true, escape_attrs: false)

    context = Context.new

    haml_pretty.def_method(context, :run_haml_pretty)
    haml_ugly.def_method(context, :run_haml_ugly)
    context.instance_eval %{
      def run_opulent_ugly; #{Opulent.new(@opulent_code).template}; end
      def run_erb; #{ERB.new(@erb_code).src}; end
      def run_erubis; #{Erubis::Eruby.new(@erb_code).src}; end
      def run_fast_erubis; #{Erubis::FastEruby.new(@erb_code).src}; end
      def run_slim_pretty; #{Slim::Engine.new(pretty: true).call @slim_code}; end
      def run_slim_ugly; #{Slim::Engine.new.call @slim_code}; end
    }

    bench(:compiled, 'opulent')     { context.run_opulent_ugly }
    bench(:compiled, 'erb')         { context.run_erb }
    bench(:compiled, 'erubis')      { context.run_erubis }
    bench(:compiled, 'fast erubis') { context.run_fast_erubis }
    bench(:compiled, 'slim pretty') { context.run_slim_pretty }
    bench(:compiled, 'slim ugly')   { context.run_slim_ugly }
    bench(:compiled, 'haml pretty') { context.run_haml_pretty }
    bench(:compiled, 'haml ugly')   { context.run_haml_ugly }
  end

  def init_tilt_benches
    tilt_opulent     = Opulent::Template.new() { @opulent_code }
    tilt_erb         = Tilt::ERBTemplate.new { @erb_code }
    tilt_erubis      = Tilt::ErubisTemplate.new { @erb_code }
    tilt_haml_pretty = Tilt::HamlTemplate.new(format: :html5) { @haml_code }
    tilt_haml_ugly   = Tilt::HamlTemplate.new(format: :html5, ugly: true) { @haml_code }
    tilt_slim_pretty = Slim::Template.new(pretty: true) { @slim_code }
    tilt_slim_ugly   = Slim::Template.new { @slim_code }

    context = Context.new

    bench(:tilt, 'opulent')     { tilt_opulent.render(context) }
    bench(:tilt, 'erb')         { tilt_erb.render(context) }
    bench(:tilt, 'erubis')      { tilt_erubis.render(context) }
    bench(:tilt, 'slim pretty') { tilt_slim_pretty.render(context) }
    bench(:tilt, 'slim ugly')   { tilt_slim_ugly.render(context) }
    bench(:tilt, 'haml pretty') { tilt_haml_pretty.render(context) }
    bench(:tilt, 'haml ugly')   { tilt_haml_ugly.render(context) }
  end

  def init_parsing_benches
    context  = Context.new
    context_binding = context.instance_eval { binding }

    bench(:parsing, 'opulent')     { Opulent.new(@opulent_code).render(context) }
    bench(:parsing, 'erb')         { ERB.new(@erb_code).result(context_binding) }
    bench(:parsing, 'erubis')      { Erubis::Eruby.new(@erb_code).result(context_binding) }
    bench(:parsing, 'fast erubis') { Erubis::FastEruby.new(@erb_code).result(context_binding) }
    bench(:parsing, 'slim pretty') { Slim::Template.new(pretty: true) { @slim_code }.render(context) }
    bench(:parsing, 'slim ugly')   { Slim::Template.new { @slim_code }.render(context) }
    bench(:parsing, 'haml pretty') { Haml::Engine.new(@haml_code, format: :html5).render(context) }
    bench(:parsing, 'haml ugly')   { Haml::Engine.new(@haml_code, format: :html5, ugly: true).render(context) }
  end

  def run
    @benches.each do |group_name, group_benches|
      puts "\nRunning #{group_name} benchmarks\n\n"

      puts "Warming up -------------------------------------"
      Benchmark.bm do |x|
        group_benches.each do |name, block|
          x.report("#{group_name} #{name}") {
            W.times do block.call end
          }
        end
      end

      puts "Measuring -------------------------------------"
      Benchmark.bm do |x|
        group_benches.each do |name, block|
          x.report("#{group_name} #{name}") {
            N.times do block.call end
          }
        end
      end

      Benchmark.ips do |x|
        group_benches.each do |name, block|
          x.report("#{group_name} #{name}", &block)
        end

        x.compare!
      end
    end

    puts "
Compiled benchmark: Template is parsed before the benchmark and
    generated ruby code is compiled into a method.
    This is the fastest evaluation strategy because it benchmarks
    pure execution speed of the generated ruby code.

Compiled Tilt benchmark: Template is compiled with Tilt, which gives a more
    accurate result of the performance in production mode in frameworks like
    Sinatra, Ramaze and Camping. (Rails still uses its own template
    compilation.)

Parsing benchmark: Template is parsed every time.
    This is not the recommended way to use the template engine
    and Slim is not optimized for it. Activate this benchmark with 'rake bench slow=1'.
"
  end

  def bench(group, name, &block)
    @benches[group].push([name, block])
  end
end

Benchmarks.new(ARGV[0]).run
