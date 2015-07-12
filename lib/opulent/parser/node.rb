# @Opulent
module Opulent
  # @Parser
  class Parser
    # Check if we match an node node with its attributes and possibly
    # inline text
    #
    # node [ attributes ] Inline text
    #
    # @param parent [Node] Parent node to which we append the node
    #
    def node(parent, indent = nil)
      if (name = lookahead(:node_lookahead) || lookahead(:shorthand_lookahead))
        return nil if Keywords.include? name[0].to_sym

        # Accept either explicit node_name or implicit :div node_name
        # with shorthand attributes
        if (node_name = accept :node)
          node_name = node_name.to_sym
          shorthand = shorthand_attributes
        elsif (shorthand = shorthand_attributes)
          node_name = :div
        end

        # Node creation options
        options = {}

        # Get leading and trailing whitespace
        if accept_stripped :leading_whitespace
          options[:leading_whitespace] = true
          if accept :leading_trailing_whitespace
            options[:trailing_whitespace] = true
          end
        elsif accept_stripped :trailing_whitespace
          options[:trailing_whitespace] = true
        end

        # Get wrapped node attributes
        atts = attributes(shorthand) || {}

        # Inherit attributes from definition
        options[:extension] = extension = extend_attributes

        # Get unwrapped node attributes
        options[:attributes] = attributes_assignments atts, false

        # Create node
        current_node = [:node, node_name, options, [], indent]

        # Check if the node is explicitly self enclosing
        if(close = accept_stripped :self_enclosing) || Settings::SelfEnclosing.include?(node_name)
          current_node[@options][:self_enclosing] = true

          unless close.nil? || close.strip.empty?
            undo close; error :self_enclosing
          end

          # For self enclosing tag error reporting purposes
          line = @i
        end

        # Check whether we have explicit inline elements and add them
        # with increased base indentation
        if (accept :inline_child)
          # Inline node element
          unless (child_node = node current_node, indent)
            error :inline_child
          end
        else
          # Inline text element
          text_node = text current_node, indent, false
        end

        # Add the current node to the root
        root(current_node, indent)

        if current_node[@options][:self_enclosing] && current_node[@children].any?
          error :self_enclosing_children, line
        end

        # Create a clone of the definition model. Cloning the options is also
        # necessary because it's a shallow copy
        if @definitions.keys.include? node_name
          model = @definitions[node_name].clone
          model[@options] = {}.merge model[@options]
          model[@options][:call] = current_node

          parent[@children] << model
        else
          parent[@children] << current_node
        end
      end
    end

    # Helper method to create an array of values when an attribute is set
    # multiple times. This happens unless the key is id, which is unique
    #
    # @param atts [Hash] Current node attributes hash
    # @param key [Symbol] Attribute name
    # @param value [String] Attribute value
    #
    def add_attribute(atts, key, value)
      # Check whether the attribute value needs to be evaluated or not
      value[@options][:evaluate] = if value[@value] =~ Settings::EvaluationCheck
        value[@value] =~ Settings::InterpolationCheck ? true : false
      else
        true
      end

      # Check for unique key and arrays of attributes
      if key == :class
        # If the key is already associated to an array, add the value to the
        # array, otherwise, create a new array or set it
        if atts[key]
          atts[key] << value
        else
          atts[key] = [value]
        end
      else
        atts[key] = value
      end
    end

    # Accept node shorthand attributes. Each shorthand attribute is directly
    # mapped to an attribute key
    #
    # @param atts [Hash] Node attributes
    #
    def shorthand_attributes(atts = {})
      while (key = accept :shorthand)
        key = Settings::Shorthand[key.to_sym]

        # Check whether the value is escaped or unescaped
        escaped = accept(:unescaped_value) ? false : true

        # Get the attribute value and process it
        if (value = accept(:node))
          value = [:expression, value.inspect, {escaped: escaped}]
        elsif (value = accept(:exp_string))
          value = [:expression, value, {escaped: escaped}]
        elsif (value = paranthesis)
          value = [:expression, value, {escaped: escaped}]
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
      attributes_assignments atts, false

      return atts
    end


    # Check if we match node attributes
    #
    # [ assignments ]
    #
    # @param as_parameters [Boolean] Accept or reject identifier nodes
    #
    def wrapped_attributes(list)
      if (bracket = accept :brackets)
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

      if (argument = accept_stripped :node)
        argument = argument.to_sym

        if accept :assignment
          # Check if we have an attribute escape or not
          escaped = if accept :assignment_unescaped
            false
          else
            true
          end

          # Get the argument value if we have an assignment
          if (value = expression(false, wrapped))
            value[@options][:escaped] = escaped

            # IDs are unique, the rest of the attributes turn into arrays in
            # order to allow multiple values or identifiers
            add_attribute(parent, argument, value)
          else
            error :assignments_colon
          end
        else
          parent[argument] = [:expression, "nil", {evaluate: true, escaped: false}] unless parent[argument]
        end

        # If our attributes are wrapped, we allow method calls without
        # paranthesis, ruby style, therefore we need a terminator to signify
        # the expression end. If they are not wrapped (inline), we require
        # paranthesis and allow inline calls
        if wrapped && accept_stripped(:assignment_terminator)
          attributes_assignments parent, wrapped
        elsif !wrapped && lookahead(:assignment_lookahead)
          attributes_assignments parent, wrapped
        end

        return parent
      elsif !parent.empty?
        error :assignments_comma
      end
    end

    # Extend node attributes with hash from
    #
    # +value
    # +{hash: "value"}
    # +(paranthesis)
    #
    def extend_attributes
      if (accept :extend_attributes)
        unescaped = accept :unescaped_value

        extension = expression(false, false, false)
        extension[@options][:escaped] = false if unescaped

        return extension
      end
    end
  end
end
