# @Opulent
module Opulent
  # @Settings
  class Settings
    # Set buffer variable name
    BUFFER = :@_opulent_buffer

    # Default Opulent file extension
    FILE_EXTENSION = '.op'.freeze

    # Default yield target which is used for child block replacements
    DEFAULT_EACH_KEY = :key

    # Default yield target which is used for child block replacements
    DEFAULT_EACH_VALUE = :value

    # List of self enclosing node elements
    SELF_ENCLOSING = [
      :img, :link, :input, :meta, :br, :hr, :area, :base, :col, :command,
      :embed, :keygen, :param, :source, :track, :wbr
    ].freeze

    # List of inline node parents which can be either inline or have complex
    # structures inside of them, such as anchor tags
    MULTI_NODE = [:a].freeze

    # List of inline node names
    INLINE_NODE = [
      :text, :a, :span, :strong, :em, :br, :i, :b, :small, :label, :sub, :sup,
      :abbr, :var, :code, :kbd
    ].freeze

    # Check whether text should or shouldn't be evaluated
    INTERPOLATION_CHECK = /(?<!\\)\#\{.*\}/

    # Check if the attribute value is a bare string
    EVALUATION_CHECK = /\A(("((?:[^"\\]|\\.)*?)")|('(?:[^'\\]|\\.)*?')|true|false|nil)\Z/

    # Check to see if we need to insert an end block for the current evaluation
    # control do || .* end
    END_INSERTION = /\A(if|begin|unless|else|elsif|when|rescue|ensure|for|while|until)\b|\bdo\s*(\|[^\|]*\|)?\s*$/
    END_REMOVAL = /\A(else|elsif|when|rescue|ensure)/
    END_EXPLICIT = /\A(end)/

    # Shorthand attribute associations
    SHORTHAND = {
      :'.' => :class,
      :'#' => :id,
      :'&' => :name
    }.freeze

    # Opulent runtime settings
    DEFAULTS = {
      indent: 2,
      layouts: false,
      pretty: false,
      default_layout: :'views/layouts/application'
    }

    # Set defaults as initial settings
    #
    def initialize
      @settings = DEFAULTS.clone
    end

    # Get an option at runtime
    #
    # @param name [Symbol] Identifier for the option
    #
    def [](name)
      @settings[name]
    end

    # Set a new option at runtime
    #
    # @param name [Symbol] Identifier for the option
    # @param value Option value to be set
    #
    def []=(name, value)
      @settings[name] = value
    end

    # Remove an option at runtime
    #
    # @param name [Symbol] Identifier for the option
    # @param value Option value to be set
    #
    def delete(name)
      @settings.delete name
    end

    # Update the engine settings with the required option changes
    #
    # @param opts [Hash] Option extension hash
    #
    def update_settings(opts)
      opts.each do |key, value|
        @settings[key] = value
      end
    end
  end
end
