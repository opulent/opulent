# @Opulent
module Opulent
  # @Runtime
  module Runtime
    # @Singleton
    class << self
      # HTML Entities Object for escaping and unescaping strings
      @@entities = HTMLEntities.new

      # Definitions knowledgebase
      @@themes = {}

      # Remodel a structured abstract syntax tree using a given context
      #
      # @param syntax [Root] Root node with contents and definitions
      # @param context [Context] Context holding environment variables
      #
      def remodel(syntax, context)
        @@themes = syntax.themes
        syntax.evaluate(context)
      end

      # Apply given context to node attributes through evaluation
      #
      # @param attributes [Hash] Node attributes
      # @param extension [String] Inline attributes extension code
      # @param context [Context] Context holding environment variables
      #
      def attributes(attributes, extension, context)
        atts = Hash[attributes.map{ |key, value|
          case value
          when Nodes::Expression
            evaluated = value.evaluate(context)
          when Array
            evaluated = value.map do |v| v.evaluate(context) end
          when Hash
            evaluated = value.each do |k, v| value[k] = v.evaluate(context) end
          end

          [key, evaluated]
        }]

        # If we have an extension, we evaluate it and we merge it with the
        # old attributes hash
        if extension
          atts_extension = context.evaluate extension.value
          if atts_extension.is_a? Hash
            atts.merge! atts_extension
          else
            error :extension, extension
          end
        end

        return atts
      end

      # Create a node from the chosen theme and definition
      #
      def define(node, attributes, context)
        # Get the definition model
        model = @@themes[node.theme][node.name].dup

        # Create a new definition context
        definition_context = Context.new
        definition_context.extend_nonlocals context.binding
        definition_context.name = node.name

        # Definition call arguments
        arguments = {}

        # Extract values which appear as definition parameters. If we have the
        # key passed as argument, get its value. Otherwise, set the default
        # parameter value
        model.attributes.each do |key, value|
          if attributes[key]
            arguments[key] = attributes.delete key
          else
            arguments[key] = value.evaluate definition_context
          end
        end

        # Set the remaining attributes as a value in the arguments
        arguments[:attributes] = attributes

        # Set variable to determine available blocks
        arguments[:blocks] = Hash[node.blocks.keys.map do |blk| [blk, true] end]

        # Create local variables from argument variables
        definition_context.extend_locals arguments

        # Evaluate the model using the new context
        model.evaluate definition_context, node.blocks
      end

      # Escape a given input value using htmlentities
      #
      # @param value [String] String to be escaped
      #
      def escape(value)
        @@entities.encode value
      end

      # Quick access wrapper to defined runtime themes
      #
      def [](theme)
        @@themes[theme]
      end

      # Give an explicit error report where an unexpected sequence of tokens
      # appears and give indications on how to solve it
      #
      # @param context [Symbol] Context name in which the error happens
      # @param data [Array] Additional error information
      #
      def error(context, *data)
        message = case context
        when :theme
          "The theme \"#{data[0]}\" cannot be found in the theme knowledgebase."
        when :enumerable
          "The provided each structure iteration input \"#{data[0]}\" is not Enumerable."
        when :binding
          data[0] = data[0].to_s.match(/\`(.*)\'/)
          data[0] = data[0][1] if data[0]
          "Found an undefined local variable or method \"#{data[0]}\" at \"#{data[1]}\"."
        when :variable_name
          data[0] = data[0].to_s.match(/\`(.*)\'/)[1]
          "Found an undefined local variable or method \"#{data[0]}\" in locals."
        when :extension
          "The extension sequence \"#{data[0]}\" is not a valid attributes extension. " +
          "Please use a Hash to extend attributes."
        when :filter_registered
          "The \"#{data[0]}\" filter could not be recognized by Opulent."
        when :filter_load
          "The gem required for the \"#{data[0]}\" filter is not installed. You can install it by running:\n\n#{data[1]}"
        end

        # Reconstruct lines to display where errors occur
        fail "\n\nOpulent " + Logger.red("[Runtime Error]") + "\n---\n" +
        "A runtime error has been encountered when building the compiled node tree.\n" +
        "#{message}\n\n\n"
      end
    end
  end
end
