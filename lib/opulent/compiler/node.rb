# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a standard node element, with closing tags or
    # self enclosing elements
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def node(node, indent, context)
      indentation = " " * indent

      # Add the tag opening, with leading whitespace to the code buffer
      buffer_freeze " " if node[@options][:leading_whitespace]
      buffer_freeze "<#{node[@value]}"

      # Evaluate node extension in the current context
      extension = if node[@options][:extension]
        buffer_set_variable :extension, node[@options][:extension][@value]
      end

      # Evaluate and generate node attributes, then process each one to
      # by generating the required attribute code
      attributes = {}
      buffer_attributes node[@options][:attributes], extension


      # Check if the current node is self enclosing. Self enclosing nodes
      # do not have any child elements
      if node[@options][:self_enclosing]
        # If the tag is self enclosing, it cannot have any child elements.
        buffer_freeze ">"
      else
        # Set tag ending code
        buffer_freeze ">"

        # Process each child element recursively, increasing indentation
        node[@children].each do |child|
          root child, indent + @@settings[:indent], context
        end

        # Set tag closing code
        buffer_freeze "</#{node[@value]}>"
        buffer_freeze " " if node[@options][:trailing_whitespace]
      end
    end
  end
end
