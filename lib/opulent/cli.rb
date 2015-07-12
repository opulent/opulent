require 'thor'

# @Opulent
module Opulent
  # @CLI
  class CLI < Thor
      desc 'hello NAME', 'Display greeting with given NAME'
      def hello(name)
        puts "Hello #{name}"
      end
    end
end
