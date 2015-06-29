# @Opulent
module Opulent
  # @Parser
  module Parser
    # @node
    module Node
      # Check if we match an node node with its attributes and possibly
      # inline text
      #
      # node [ attributes ] Inline text
      #
      # @param parent [Node] Parent node to which we append the node
      #
      def node(parent, indent = nil)
        if (name = lookahead :identifier_lookahead)
          return nil if Tokens.keyword name

          # Get current line's indentation
          unless indent
            indent = accept_unstripped(:indent) || ""
            indent = indent.size
          end

          # Get a theme if set, or set append definitions to the default
          # element namespace
          if (theme_name = accept_unstripped(:theme_node))
            theme_name = theme_name.to_sym
          else
            theme_name = Engine::DEFAULT_THEME
          end

          # Accept either explicit node_name or implicit :div node_name
          # with shorthand attributes
          if (node_name = accept :identifier)
            shorthand = shorthand_attributes
          elsif (shorthand = shorthand_attributes)
            node_name = :div
          end

          # Get leading and trailing whitespace
          if accept_line_unstripped :leading_whitespace
            leading_whitespace = true
            if accept_line_unstripped :leading_trailing_whitespace
              trailing_whitespace = true
            end
          elsif accept_line_unstripped :trailing_whitespace
            trailing_whitespace = true
          end

          # Get wrapped node attributes
          atts = attributes(shorthand) || {}

          # Inherit attributes from definition
          extension = extend_attributes

          # Get unwrapped node attributes
          atts = attributes_assignments atts, false

          # Create a new node and set its extension
          _node = @create.node node_name.to_sym, atts, parent, indent, []
          _node.extension = extension
          _node.theme = theme_name
          _node.whitespace = [leading_whitespace, trailing_whitespace]

          if(accept_line :inline_child)
            if (child_node = node _node, indent + Engine[:indent])
              _node.push child_node
            else
              error :inline_child
            end
          end

          if(close = accept_line :self_enclosing)
            _node.self_enclosing = true
            unless close.strip.empty?
              undo close
              error :self_enclosing
            end
          end

          # Accept inline text or multiline text feed as first child
          if(text_node = text _node, " " * indent, false)
            text_node.indent += Engine[:indent]
            _node.push text_node unless text_node.nil?
          end

          return _node
        end
      end

      def shorthand_attributes(atts = {})
        find_shorthand = Proc.new do
          Engine[:shorthand].find do |key, value|
            if accept_unstripped :"shorthand@#{key}"
              key
            else
              false
            end
          end
        end

        while (attribute = find_shorthand[])
          key = attribute[0]

          # Get the attribute value and process it
          if (value = accept_unstripped(:identifier))
            value = @create.expression "\"#{value}\""
          elsif (value = (accept_unstripped(:exp_string) || paranthesis))
            value = @create.expression "#{value}"
          else
            error :shorthand
          end

          # IDs are unique, the rest of the attributes turn into arrays in
          # order to allow multiple values or identifiers
          if key == :id
            atts[key] = value
          else
            if atts[key].is_a? Array
              atts[key] << value
            elsif atts[key]
              atts[key] = [atts[key], value]
            else
              atts[key] = [value]
            end
          end
        end

        return atts
      end

      # Extend node attributes with hash from
      #
      # [hash]
      #
      def extend_attributes
        if (accept_unstripped :extend_attributes)
          bracket = accept_unstripped :brackets, :*
          extension = expression
          accept bracket.to_sym, :*
          return extension
        end
      end

      # Check if we match node attributes
      #
      # [ assignments ]
      #
      # @param as_parameters [Boolean] Accept or reject identifier nodes
      #
      def attributes(list)
        if (bracket = accept_unstripped :brackets)
          attributes_assignments list
          accept bracket.to_sym, :*
        end

        return list
      end

      # Check if we match an expression node or
      # a node node
      #
      # [ assignments ]
      #
      # @param parent [Hash] Parent to which we append nodes
      # @param as_parameters [Boolean] Accept or reject identifier nodes
      #
      def attributes_assignments(parent, wrapped = true)
        unless wrapped
          return parent if lookahead(:assignment_lookahead).nil?
        end

        if (argument = accept :identifier)
          argument = argument.to_sym

          if accept :assignment
            # Check if we have an attribute escape or not
            escaped = if accept_unstripped :assignment_unescaped
              false
            else
              true
            end

            # Get the argument value if we have an assignment
            if (value = expression(false, wrapped))
              value.escaped = escaped

              # Check if our argument already exists in the attributes list, and
              # if it does, check if it's an array. If it isn't, turn it into an
              # array literal, otherwise push the value into it. However, id
              # attributes do not get turned into arrays as they are supposed
              # to be unique
              if parent[argument] && argument != :id
                # Check if argument is already an array, otherwise create an
                # array in which we will add values
                if parent[argument].is_a? Array
                  parent[argument] << value
                else
                  new_parent = []
                  new_parent.push parent[argument]

                  parent[argument] = new_parent
                  parent[argument] << value
                end
              else
                parent[argument] = value
              end
            else
              error :assignments_colon
            end
          else
            parent[argument] = @create.expression "true" unless parent[argument]
          end

          # If our attributes are wrapped, we allow method calls without
          # paranthesis, ruby style, therefore we need a terminator to signify
          # the expression end. If they are not wrapped (inline), we require
          # paranthesis and allow inline calls
          if wrapped && accept_line(:assignment_terminator)
            attributes_assignments parent, wrapped
          elsif lookahead(:assignment_lookahead)
            attributes_assignments parent, wrapped
          end

          return parent
        elsif !parent.empty?
          error :assignments_comma
        end
      end
    end
  end
end
