# @Opulent
module Opulent
  class Compiler
    def buffer(string)
      @template << [:buffer, string]
    end

    def buffer_escape(string)
      @template << [:escape, string]
    end

    def buffer_freeze(string)
      if @template[-1][0] == :freeze
        @template[-1][1] += string
      else
        @template << [:freeze, string]
      end
    end

    def buffer_eval(string)
      @template << [:eval, string]
    end


    def templatize
      separator = "\n " # Readablity during development
      @template.inject("") do |buffer, input|
        buffer += case input[0]
        when :preamble
          "#{Buffer} = []#{separator}"
        when :buffer
          "#{Buffer} << (#{input[1]})#{separator}"
        when :escape
          "#{Buffer} << (::Opulent::Utils::escape(#{input[1]}))#{separator}"
        when :freeze
          "#{Buffer} << (#{input[1].inspect}.freeze)#{separator}"
        when :eval
          "#{input[1]}#{separator}"
        when :postamble
          "#{Buffer}.join"
        end
      end
    end
  end
end
