# @Opulent
module Opulent
  # @Context
  #
  # The context class is used to differentiate local, instance and class variables
  # and to define the current working environment. Each class, method and instance
  # has its own context
  #
  class Context
    attr_accessor :block, :binding, :name, :parent

    # Create a context from the environment binding, extended with the locals
    # given as arguments
    #
    # @param locals [Hash] Binding extension
    # @param block [Binding] Call environment block
    # @param content [Binding] Content yielding
    #
    def initialize(locals = {}, block = nil, &content)
      @content = content

      @block = block
      @binding = if @block
        @block.binding.clone
      else
        Binding.new.get
      end

      extend_locals locals
    end

    # Evaluate ruby code in current context
    #
    # @param code [String] Code to be evaluated
    #
    def evaluate(code, &block)
      begin
        eval code, @binding, &block
      rescue NameError => variable
        Compiler.error :binding, variable, code
      end
    end

    # Call given input block and return the output
    #
    def evaluate_yield
      @content.call if @content
    end

    # Extend the call context with a Hash, String or other Object
    #
    # @param context [Object] Extension object
    #
    def extend_locals(locals)
      # Create new local variables from the input hash
      locals.each do |key, value|
        begin
          @binding.local_variable_set key.to_sym, value
        rescue NameError => variable
          Compiler.error :variable_name, variable, key
        end
      end
    end

    # Extend instance, class and global variables for use in definitions
    #
    # @param bind [Binding] Binding to extend current context binding
    #
    def extend_nonlocals(bind)
      bind.eval('instance_variables').each do |var|
        @binding.eval('self').instance_variable_set var, bind.eval(var.to_s)
      end

      bind.eval('self.class.class_variables').each do |var|
        @binding.eval('self').class_variable_set var, bind.eval(var.to_s)
      end
    end
  end

  # @Binding
  class Binding
    def get
      return binding
    end
  end
end
