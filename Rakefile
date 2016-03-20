require "bundler/gem_tasks"
require "rspec/core/rake_task"


# RSpec task
RSpec::Core::RakeTask.new(:spec)
task :test => :spec

# Benchmarking task
task :benchmark do
  ruby 'benchmarks/run-benchmarks.rb'
end
