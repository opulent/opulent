# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @NodeFactory
    class Helper
      def root
        Root.new
      end

      def node(name = '', atts = {}, parent = nil, indent = 0, children = [])
        Node.new name, atts, parent, indent, children
      end

      def block_yield(name = '', parent = nil, indent = 0, children = [])
        Yield.new name, {}, parent, indent, children
      end

      def block(name = '', parent = nil, indent = 0, children = [])
        Block.new name, {}, parent, indent, children
      end

      def theme(name = '', parent = nil, indent = 0, children = [])
        Theme.new name, parent, indent, children
      end

      def filter(name = '', atts = {}, parent = nil, indent = 0, value = '')
        Filter.new name, atts, parent, indent, value
      end

      def evaluate(value, parent = nil, indent = 0, children = [])
        Evaluate.new value, parent, indent, children
      end

      def control(name, value = '', parent = nil, indent = 0, children = [[]])
        case name
        when :if, :unless
          CnditionalControl.new name, value, parent, indent, children
        when :case
          CaseControl.new name, value, parent, indent, children.first
        when :while, :until
          LoopControl.new name, value, parent, indent, children.first
        when :each
          EachControl.new name, value, parent, indent, children.first
        end
      end

      def expression(value = [])
        Expression.new value
      end

      def definition(name, params = [], parent = nil, indent = 0)
        Define.new name, params, parent, indent
      end

      def text(value = nil, escaped = true, parent = nil, indent = 0)
        Text.new value, escaped, parent, indent
      end

      def print(value = nil, escaped = true, parent = nil, indent = 0)
        Print.new value, escaped, parent, indent
      end

      def comment(value = nil, parent = nil, indent = 0)
        Comment.new value, parent, indent
      end
    end
  end
end
