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
    # @param bind [Binding] Call environment binding
    #
    def initialize(locals = {}, &block)
      @block = block
      @binding = if @block
        @block.binding.clone
      else
        Binding.new
      end

      extend_locals locals
    end

    # Evaluate ruby code in current context
    #
    # @param code [String] Code to be evaluated
    #
    def evaluate(code)
      begin
        eval code, @binding
      rescue NameError => variable
        Compiler.error :binding, variable, code
      end
    end

    # Call given input block and return the output
    #
    def evaluate_yield
      @block.call if @block
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
      #
      # bind.eval('self.class.constants').each do |var|
      #   @binding.eval('self').const_set var, bind.eval(var.to_s)
      # end
    end
  end

  # @Binding
  class Binding
    def self.new
      return binding
    end
  end
end
