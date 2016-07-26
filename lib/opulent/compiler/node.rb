# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a standard node element, with closing tags or
    # self enclosing elements
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    #
    def node(node, indent)
      # Pretty print
      if @settings[:pretty]
        indentation = ' ' * indent
        inline = Settings::INLINE_NODE.include? node[@value]

        if inline
          if @sibling_stack[-1][-1] && @sibling_stack[-1][-1][0] == :plain
            buffer_remove_trailing_whitespace
          elsif @sibling_stack[-1].length == 1
            buffer_freeze indentation
          end
        else
          buffer_freeze indentation
        end

        @sibling_stack[-1] << [node[@type], node[@value]]
        @sibling_stack << [ [node[@type], node[@value]] ]
      end

      # Add the tag opening, with leading whitespace to the code buffer
      buffer_freeze ' ' if node[@options][:leading_whitespace]
      buffer_freeze "<#{node[@value]}"

      # Evaluate node extension in the current context
      if node[@options][:extension]
        extension_name = buffer_set_variable :extension,
                                             node[@options][:extension][@value]

        extension = {
          name: extension_name,
          escaped: node[@options][:extension][@options][:escaped]
        }
      end

      # Evaluate and generate node attributes, then process each one to
      # by generating the required attribute code
      buffer_attributes node[@options][:attributes],
                        extension


      # Check if the current node is self enclosing. Self enclosing nodes
      # do not have any child elements
      if node[@options][:self_enclosing]
        # If the tag is self enclosing, it cannot have any child elements.
        buffer_freeze '>'

        # Pretty print
        buffer_freeze "\n" if @settings[:pretty]

        # If we mistakenly add children to self enclosing nodes,
        # process each child element as if it was correctly indented
        # node[@children].each do |child|
        #   root child, indent + @settings[:indent]
        # end
      else
        # Set tag ending code
        buffer_freeze '>'

        # Pretty print
        if @settings[:pretty]
          if node[@children].length > 0
            buffer_freeze "\n" unless inline
          end
          # @sibling_stack << [[node[@type], node[@value]]]
        end

        # Process each child element recursively, increasing indentation
        node[@children].each do |child|
          root child, indent + @settings[:indent]
        end

        # Pretty print
        if @settings[:pretty]
          if node[@children].length > 1 &&
            @sibling_stack[-1][-1] &&
            (@sibling_stack[-1][-1][0] == :plain ||
              Settings::INLINE_NODE.include?(@sibling_stack[-1][-1][1]))
            buffer_freeze "\n"
          end

          if node[@children].size > 0 and !inline
            buffer_freeze indentation
          end
        end

        # Set tag closing code
        buffer_freeze "</#{node[@value]}>"
        buffer_freeze ' ' if node[@options][:trailing_whitespace]

        # Pretty print
        if @settings[:pretty]
          buffer_freeze "\n" unless inline
        end
      end

      if @settings[:pretty]
        @sibling_stack.pop
      end
    end
  end
end
