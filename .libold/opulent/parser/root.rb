# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Root
    module Root
      # Check if we match any root element. This is the starting point of the
      # parser and it checks for any elements which can be considered as root
      #
      # @param parent [Node] Parent element to append to
      # @param min_indent [Integer] Minimum indent to which the root responds
      #
      def root(parent)
        # Starting line of the root method
        starting_line = @current_line

        # Skip any whitespace at the beginning of the document
        accept_unstripped :newline

        if(element = define(parent))
          # Add definition elements to the root's knowledgebase and add elements
          # and evaluate elements to their parent elements
          if parent.is_a? Nodes::Root
            @root.themes[Engine::DEFAULT_THEME][element.name] = element
          elsif parent.is_a? Nodes::Theme
            @root.themes[parent.name][element.name] = element
          else
            error :definition
          end
        elsif(element = theme(parent))
          # Theme nodes cannot be nested, so we accept only a root parent and
          # we add the node in the themes hash and we allow reopening the theme
          # and adding more definitions to it, ruby style
          if parent.is_a? Nodes::Root
            @root.themes[element.name] ||= {}
          else
            error :theme
          end
        elsif (element =  node(parent)                ||
                          text(parent)                ||
                          comment(parent)             ||
                          control(parent)             ||
                          evaluate(parent)            ||
                          filter_element(parent)      ||
                          html_text(parent))
          parent.push element
        elsif (element = block_yield(parent))
          # Handle yield node by searching for ther definition parent node
          yield_parent = element.parent
          begin
            until [Nodes::Define, Nodes::Root].include? yield_parent.class
              yield_parent = yield_parent.parent
            end
          rescue NoMethodError
            error :yield_parent
          end

          # Add the yield element to the parent and keep a pointer to the parent
          # for each yield element to avoid recursive searching as much as
          # possible
          parent.push element
          yield_parent.yields << parent
        elsif (element = block(parent))
          # Blocks will be set as separate entities for the parent element in
          # order to replace them fast in the definition yields
          parent.blocks[element.name] ||= []
          parent.blocks[element.name] << element
        end

        next_indent = lookahead(:indent_lookahead, false).length
        if element
          if next_indent > element.indent
            # If we have an indentation which is greater than the current one,
            # set the current element as a root element and add children to it
            root element
          elsif next_indent < element.indent
            # If we have an indentation which is smaller than the current one,
            # go through the current element's ancestors until we find one with
            # the same indentation as the next element
            next_parent = element.parent
            while next_parent.indent > next_indent
              next_parent = next_parent.parent
            end
            next_parent = next_parent.parent

            root next_parent
          else
            # If the indentation level stays the same, the parent element will
            # remain the current one
            root parent
          end
        end
      end
    end
  end
end
