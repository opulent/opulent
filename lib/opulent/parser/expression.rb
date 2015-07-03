# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Expression
    class << self
      # Check if the parser matches an expression node
      #
      def expression(allow_assignments = true, wrapped = true, whitespace = true)
        buffer = ""

        # Build a ruby expression out of accepted literals
        while (term = (whitespace ? accept(:whitespace) : nil)          ||
                      modifier                                          ||
                      identifier                                        ||
                      method_call                                       ||
                      paranthesis                                       ||
                      array                                             ||
                      hash                                              ||
                      symbol                                            ||
                      percent                                           ||
                      primary_term)
          buffer += term

          # Accept operations which have a right term and raise an error if
          # we have an unfinished expression such as "a +", "b - 1 >" and other
          # expressions following the same pattern
          if wrapped && (op = operation || (allow_assignments ? accept_stripped(:exp_assignment) : nil))
            buffer += op
            if (right_term = expression(allow_assignments, wrapped)).nil?
              error :expression
            else
              buffer += right_term[@value]
            end
          elsif (conditional = ternary_operator allow_assignments, wrapped)
            buffer += conditional
          end

          # Do not continue if the expression has whitespace method calls in
          # an unwrapped context because this will confuse the parser
          unless buffer.strip.empty?
            break unless wrapped || lookahead(:exp_identifier_lookahead).nil?
          end
        end

        if buffer.strip.empty?
          return undo buffer
        else
          return [:expression, buffer.strip, {}]
        end
      end

      # Check if it's possible to parse a ruby array literal. First, try to see
      # if the next sequence is a hash_open token: "[", and if it is, then a
      # hash_close: "]" token is required next
      #
      # [array_elements]
      #
      def array
        if (buffer = accept :square_bracket)
          accept_newline
          buffer += array_elements
          accept_newline
          buffer += accept :'[', :*
        end
      end

      # Recursively gather expressions separated by a comma and add them to the
      # expression buffer
      #
      # experssion1, experssion2, experssion3
      #
      # @param buffer [String] Accumulator for the array elements
      #
      def array_elements(buffer = '')
        if (term = expression)
          buffer += term[@value]
          # If there is an array_terminator ",", recursively gather the next
          # array element into the buffer
          if (terminator = accept_stripped :comma) then
            accept_newline
            buffer += array_elements terminator
          end
        end

        # Array ended prematurely with a trailing comma, therefore the current
        # parsing process will stop
        if buffer.strip[-1] == ','
          error :array_elements_terminator
        end

        return buffer
      end

      # Check if it's possible to parse a ruby hash literal. First, try to see
      # if the next sequence is a hash_open token: "{", and if it is, then a
      # hash_close: "}" token is required next
      #
      # { hash_elements }
      #
      def hash
        if (buffer = accept :curly_bracket)
          accept_newline
          buffer += hash_elements
          accept_newline
          buffer += accept :'{', :*
        end
      end

      # Recursively gather expression attributions separated by a comma and add
      # them to the expression buffer
      #
      # key1: experssion1, key2 => experssion2, :key3 => experssion3
      #
      # @param buffer [String] Accumulator for the hash elements
      #
      def hash_elements(buffer = '')
        value = Proc.new do
          # Get the value associated to the current hash key
          if (exp = expression)
            buffer += exp[@value]
          else
            error :hash_elements
          end

          # If there is an hash_terminator ",", recursively gather the next
          # array element into the buffer
          if (terminator = accept_stripped :comma) then
            accept_newline
            buffer += hash_elements terminator
          end
        end

        # Accept both shorthand and default ruby hash style. Following DRY
        # principles, a Proc is used to assign the value to the current key
        #
        # key:
        # :key =>
        if (symbol = accept_stripped :hash_symbol)
          buffer += symbol
          value[]
        elsif (exp = expression false)
          buffer += exp[@value]
          if(assign = accept_stripped :hash_assignment)
            buffer += assign
            value[]
          else
            error :hash_assignment
          end
        end

        # Array ended prematurely with a trailing comma, therefore the current
        # parsing process will stop
        if buffer.strip[-1] == ','
          error :hash_elements_terminator
        end

        return buffer
      end

      # Accept a ruby identifier such as a class, module, method or variable
      #
      def identifier
        if (buffer = accept :exp_identifier)
          if (args = call)
            buffer += args
          end
          return buffer
        end
      end

      # Check if it's possible to parse a ruby paranthesis expression wrapper.
      #
      def paranthesis
        if (buffer = accept :round_bracket)
          buffer += expression[@value]
          buffer += accept_stripped :'(', :*
        end
      end

      # Check if it's possible to parse a ruby call literal. First, try to see
      # if the next sequence is a hash_open token: "(", and if it is, then a
      # hash_close: ")" token is required next
      #
      # ( call_elements )
      #
      def call
        if (buffer = accept :round_bracket)
          buffer += call_elements
          buffer += accept_stripped :'(', :*
        end
      end

      # Recursively gather expression attributes separated by a comma and add
      # them to the expression buffer
      #
      # expression1, a: expression2, expression3
      #
      # @param buffer [String] Accumulator for the call elements
      #
      def call_elements(buffer = '')
        # Accept both shorthand and default ruby hash style. Following DRY
        # principles, a Proc is used to assign the value to the current key
        #
        # key: value
        # :key => value
        # value
        if (symbol = accept_stripped :hash_symbol)
          buffer += symbol

          # Get the value associated to the current hash key
          if (exp = expression(true))
            buffer += exp[@value]
          else
            error :call_elements
          end

          # If there is an comma ",", recursively gather the next
          # array element into the buffer
          if (terminator = accept_stripped :comma) then
            buffer += call_elements terminator
          end
        elsif (exp = expression(true))
          buffer += exp[@value]

          if(assign = accept_stripped :hash_assignment)
            buffer += assign

            # Get the value associated to the current hash key
            if (exp = expression(true))
              buffer += exp[@value]
            else
              error :call_elements
            end
          end

          # If there is an comma ",", recursively gather the next
          # array element into the buffer
          if (terminator = accept_stripped :comma) then
            buffer += call_elements terminator
          end
        end

        buffer
      end

      # Accept a ruby symbol defined through a colon and a trailing expression
      #
      # :'symbol'
      # :symbol
      #
      def symbol
        if (colon = accept :colon)
          return undo colon if lookahead(:whitespace)

          if (exp = expression).nil?
            error :symbol
          else
            colon + exp[@value]
          end
        end
      end

      # Accept a ruby module, method or context modifier
      #
      # Module::
      # @, @@, $
      #
      def modifier
        accept(:exp_context) || accept(:exp_module)
      end


      # Accept a ruby percentage operator for arrays of strings, symbols and
      # simple escaped strings
      #
      # %w(word1 word2 word3)
      #
      def percent
        if (buffer = accept_stripped :exp_percent)
          match_start = buffer[-1]
          match_name = :"percent#{match_start}"

          unless Tokens[match_name]
            match_end = Tokens.bracket(match_start) || match_start

            match_inner = "\\#{match_start}"
            match_inner += "\\#{match_end}" unless match_end == match_start

            pattern = /(((?:[^#{match_inner}\\]|\\.)*?)#{'\\' + match_end})/

            Tokens[match_name] = pattern
          end

          buffer += accept match_name
        end
      end

      # Accept any primary term and return it without the leading whitespace to
      # the expression buffer
      #
      # "string"
      # 123
      # 123.456
      # nil
      # true
      # false
      # /.*/
      #
      def primary_term
        accept_stripped(:exp_string)     ||
        accept_stripped(:exp_fixnum)     ||
        accept_stripped(:exp_double)     ||
        accept_stripped(:exp_nil)        ||
        accept_stripped(:exp_regex)      ||
        accept_stripped(:exp_boolean)
      end

      # Accept an operation between two or more expressions
      #
      def operation
        accept(:exp_operation)
      end

      # Accept a ruby method call modifier
      #
      def method_call
        accept(:exp_method_call)
      end

      # Accept ternary operator syntax
      #
      # condition ? expression1 : expression2
      #
      def ternary_operator(allow_assignments, wrapped)
        if (buffer = accept :exp_ternary)
          buffer += expression(allow_assignments, wrapped)[@value]
          if (else_branch = accept :exp_ternary_else)
            buffer += else_branch
            buffer += expression(allow_assignments, wrapped)[@value]
          end
          return buffer
        end
      end
    end
  end
end
