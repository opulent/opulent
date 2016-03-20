require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#render' do
    it 'defines a new element' do
      opulent = Opulent.new <<-OPULENT
      def node
        .node
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('')
    end

    it 'defines a new element with attributes' do
      opulent = Opulent.new <<-OPULENT
      def node(attr1, attr2)
        .node
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('')
    end

    it 'defines and uses a new element' do
      opulent = Opulent.new <<-OPULENT
      def node
        .node

      node
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div class="node"></div>')
    end

    it 'defines and uses a new element with attributes' do
      opulent = Opulent.new <<-OPULENT
      def node(attr1, attr2)
        .node attr1=attr1 attr2=attr2

      node attr1="1" attr2="2"
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div class="node" attr1="1" attr2="2"></div>')
    end

    it 'sets unspecified arguments to nil' do
      opulent = Opulent.new <<-OPULENT
      def node(attr1="default", attr2)
        .node attr1=attr1 attr2=attr2

      node
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div class="node" attr1="default"></div>')
    end

    it 'defines and uses a new element with default attributes' do
      opulent = Opulent.new <<-OPULENT
      def node(attr1="default", attr2)
        .node attr1=attr1 attr2=attr2

      node attr2="2"
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div class="node" attr1="default" attr2="2"></div>')
    end

    it 'defines and uses a new element with default attribute override' do
      opulent = Opulent.new <<-OPULENT
      def node(attr1="default", attr2)
        .node attr1=attr1 attr2=attr2

      node attr1="1" attr2="2"
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div class="node" attr1="1" attr2="2"></div>')
    end

    it 'uses definitions inside of definitions' do
      opulent = Opulent.new <<-OPULENT
      def type1
        outer
          yield

      def type2
        inner
          yield

      def type3
        last
          yield

      type1
        type2
          type3
          type3
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        '<outer><inner><last></last><last></last></inner></outer>'
      )
    end

    it 'contains a non-recursive node with same name as the definition' do
      opulent = Opulent.new <<-OPULENT
      def footer
        footer
          yield

      footer
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<footer></footer>')
    end

    it 'contains a recursive node with same name as the definition' do
      opulent = Opulent.new <<-OPULENT
      def node(count = 3)
        - count -= 1
        if count > 0
          node* count=count
            node
              yield
        else
          yield

      node
        child
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<node><node><child></child></node></node>')
    end

    it 'contains a node with same name as the definition with children' do
      opulent = Opulent.new <<-OPULENT
      def node
        node
          yield

      node
        node
          inside
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<node><node><inside></inside></node></node>')
    end

    it 'uses a definition inside of definition' do
      opulent = Opulent.new <<-OPULENT
      def insidenode
        test
          yield

      def node
        insidenode
          yield

      node
        child
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        '<test><child></child></test>'
      )
    end

    it 'should disregard definition order' do
      opulent = Opulent.new <<-OPULENT
      def node
        insidenode
          yield

      def insidenode
        test
          yield

      node
        child
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        '<test><child></child></test>'
      )
    end

    it 'should pass definition arguments to inside definition' do
      opulent = Opulent.new <<-OPULENT
def x(xparam)
  y yparam=xparam

def y(yparam)
  div class=yparam

x xparam="test"
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        '<div class="test"></div>'
      )
    end
  end
end
