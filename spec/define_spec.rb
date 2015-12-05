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

  end
end
