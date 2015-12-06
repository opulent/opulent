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
      return unless (name = lookahead(:node_lookahead) ||
                            lookahead(:shorthand_lookahead))

      return nil if KEYWORDS.include? name[0].to_sym

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

      # Get leading whitespace
      options[:leading_whitespace] = accept_stripped(:leading_whitespace)

      # Get trailing whitespace
      options[:trailing_whitespace] = accept_stripped(:trailing_whitespace)

      # Get wrapped node attributes
      atts = attributes(shorthand) || {}

      # Inherit attributes from definition
      options[:extension] = extend_attributes

      # Get unwrapped node attributes
      options[:attributes] = attributes_assignments atts, false

      # Create node
      current_node = [:node, node_name, options, [], indent]

      # Check for self enclosing tags and definitions
      def_check = !@definitions.keys.include?(node_name) &&
                  Settings::SELF_ENCLOSING.include?(node_name)

      # Check if the node is explicitly self enclosing
      if (close = accept_stripped :self_enclosing) || def_check
        current_node[@options][:self_enclosing] = true

        unless close.nil? || close.strip.empty?
          undo close
          Logger.error :parse, @code, @i, @j, :self_enclosing
        end
      end

      # Check whether we have explicit inline elements and add them
      # with increased base indentation
      if accept :inline_child
        # Inline node element
        Logger.error :parse,
                     @code,
                     @i,
                     @j,
                     :inline_child unless node current_node, indent
      elsif comment current_node, indent
        # Accept same line comments
      else
        # Accept inline text element
        text current_node, indent, false
      end

      # Add the current node to the root
      root current_node, indent

      # Create a clone of the definition model. Cloning the options is also
      # necessary because it's a shallow copy
      if @definitions.keys.include?(node_name)
        @definition_stack << node_name
        parent[@children] << process_definition(node_name, current_node)
        @definition_stack.pop
      else
        parent[@children] << current_node
      end
    end

    # When entering a definition model, we replace all the node types with their
    # know definitions at definition call time.
    #
    # @param node_name [Symbol] Node identifier
    # @param call_context [Node] Initial node call with its attributes
    #
    def process_definition(node_name, call_context)
      model = @definitions[node_name].clone
      model[@options] = {}.merge model[@options]
      model[@options][:call] = call_context

      # Recursively map each child nodes to their definitions
      # for the initial call node children and for the model
      # children
      process_definition_child model[@options][:call]
      process_definition_child model

      model
    end

    # Process definition children for the current node.
    #
    # @param node [Node] Callee node
    #
    def process_definition_child(node)
      node[@children].map! do |child|
        if child[@type] == :node
          if !@definition_stack.include?(child[@value]) &&
             @definitions.keys.include?(child[@value])
            process_definition child[@value], child
          else
            process_definition_child child if child[@children]
            child
          end
        else
          child
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
        key = Settings::SHORTHAND[key.to_sym]

        # Check whether the value is escaped or unescaped
        escaped = accept(:unescaped_value) ? false : true

        # Get the attribute value and process it
        if (value = accept(:node))
          value = [:expression, value.inspect, { escaped: escaped }]
        elsif (value = accept(:exp_string))
          value = [:expression, value, { escaped: escaped }]
        elsif (value = paranthesis)
          value = [:expression, value, { escaped: escaped }]
        else
          Logger.error :parse, @code, @i, @j, :shorthand
        end

        # IDs are unique, the rest of the attributes turn into arrays in
        # order to allow multiple values or identifiers
        add_attribute(atts, key, value)
      end

      atts
    end

    # Get element attributes
    #
    # @atts [Hash] Accumulator for node attributes
    #
    def attributes(atts = {})
      wrapped_attributes atts
      attributes_assignments atts, false
      atts
    end

    # Check if we match node attributes
    #
    # [ assignments ]
    #
    # @param as_parameters [Boolean] Accept or reject identifier nodes
    #
    def wrapped_attributes(list)
      if (bracket = accept :brackets)
        accept_newline
        attributes_assignments list, true
        accept_newline

        accept_stripped bracket.to_sym, :*
      end

      list
    end

    # Check if we match an expression node or
    # a node node
    #
    # [ assignments ]
    #
    # @param list [Hash] Parent to which we append nodes
    # @param as_parameters [Boolean] Accept or reject identifier nodes
    #
    def attributes_assignments(list, wrapped = true)
      if wrapped && lookahead(:exp_identifier_stripped_lookahead).nil? ||
         !wrapped && lookahead(:assignment_lookahead).nil?
        return list
      end

      return unless (argument = accept_stripped :node)

      argument = argument.to_sym

      if accept_stripped :assignment
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
          add_attribute(list, argument, value)
        else
          Logger.error :parse, @code, @i, @j, :assignments_colon
        end
      else
        unless list[argument]
          list[argument] = [:expression, 'true', { escaped: false }]
        end
      end

      # If our attributes are wrapped, we allow method calls without
      # paranthesis, ruby style, therefore we need a terminator to signify
      # the expression end. If they are not wrapped (inline), we require
      # paranthesis and allow inline calls
      if wrapped
        # Accept optional comma between attributes
        accept_stripped :assignment_terminator

        # Lookahead for attributes on the current line and the next one
        if lookahead(:exp_identifier_stripped_lookahead)
          attributes_assignments list, wrapped
        elsif lookahead_next_line(:exp_identifier_stripped_lookahead)
          accept_newline
          attributes_assignments list, wrapped
        end
      elsif !wrapped && lookahead(:assignment_lookahead)
        attributes_assignments list, wrapped
      end

      list
    end

    # Extend node attributes with hash from
    #
    # +value
    # +{hash: "value"}
    # +(paranthesis)
    #
    def extend_attributes
      return unless accept :extend_attributes
      unescaped = accept :unescaped_value

      extension = expression(false, false, false)
      extension[@options][:escaped] = !unescaped

      extension
    end
  end
end
