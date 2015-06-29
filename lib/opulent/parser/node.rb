# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Singleton
    class << self
      def node(parent, indent)
        if(match = accept :node)
          # Process data
          match = match.to_sym

          # Create node
          node = [:node, match, attributes, [], indent]
          root(node, indent)

          parent[@children] << node
        end
      end


      # Check if we match an node node with its attributes and possibly
      # inline text
      #
      # node [ attributes ] Inline text
      #
      # @param parent [Node] Parent node to which we append the node
      #
      def node(parent, indent = nil)
        if (name = lookahead(:node_lookahead) || lookahead(:shorthand_lookahead))
          return nil if Keywords.include? name[0]

          # Accept either explicit node_name or implicit :div node_name
          # with shorthand attributes
          if (node_name = accept :node)
            shorthand = shorthand_attributes
          elsif (shorthand = shorthand_attributes)
            node_name = :div
          end

          # Node creation options
          options = {}

          # Get leading and trailing whitespace
          if accept_line_unstripped :leading_whitespace
            options[:leading_whitespace] = true
            if accept_line_unstripped :leading_trailing_whitespace
              options[:trailing_whitespace] = true
            end
          elsif accept_line_unstripped :trailing_whitespace
            options[:trailing_whitespace] = true
          end

          # Get wrapped node attributes
          atts = attributes(shorthand) || {}

          # Inherit attributes from definition
          extension = extend_attributes

          # Get unwrapped node attributes
          atts = attributes_assignments atts, false

          # Create node
          current_node = [:node, node_name, atts, [], indent, options]
          root(node, indent)

          current_node.extension = extension
          current_node.whitespace = [leading_whitespace, trailing_whitespace]

          if(accept_line :inline_child)
            if (child_node = node current_node, indent + Settings[:indent])
              current_node.push child_node
            else
              error :inline_child
            end
          end

          if(close = accept_line :self_enclosing)
            current_node.self_enclosing = true
            unless close.strip.empty?
              undo close
              error :self_enclosing
            end
          end

          # Accept inline text or multiline text feed as first child
          # if(text_node = text current_node, " " * indent, false)
          #   text_node.indent += Engine[:indent]
          #   current_node.push textcurrent_node unless textcurrent_node.nil?
          # end

          parent[@children] << node
        end
      end

      def add_attribute(atts, key, value)
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

      def shorthand_attributes(atts = {})
        while (key = accept :shorthand)
          key = Settings::Shorthand[key.to_sym]

          # Get the attribute value and process it
          if (value = accept(:node))
            value = [:value, value.inspect]
          # @TODO
          #elsif (value = (accept(:exp_string) || paranthesis))
          #  value = [:expression, value.inspect]
          else
            error :shorthand
          end

          # IDs are unique, the rest of the attributes turn into arrays in
          # order to allow multiple values or identifiers
          add_attribute(atts, key, value)
        end

        return atts
      end

      def attributes(atts = {})
        wrapped_attributes atts
        unrwapped_attributes atts

        return atts
      end


      # Check if we match node attributes
      #
      # [ assignments ]
      #
      # @param as_parameters [Boolean] Accept or reject identifier nodes
      #
      def wrapped_attributes(list)
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
