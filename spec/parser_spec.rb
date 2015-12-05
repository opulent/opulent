require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#parse' do
    it 'parses root' do
      result = Opulent::Parser.new('index', {}).parse <<-OPULENT
      OPULENT
      expect(result).to eq([[:root, nil, {}, [], -1], {}])
    end

    it 'parses a node with id' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div#id
      OPULENT
    end

    it 'parses a node with escaped id' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div#~id
      OPULENT
    end

    it 'parses a node with string id' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div#"id"
      OPULENT
    end

    it 'parses a node with escaped string id' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div#~"id"
      OPULENT
    end

    it 'parses a node with shorthand syntax' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        #id
      OPULENT
    end

    it 'parses a node with wrapped attributes' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div[test="value"]
      OPULENT
    end

    it 'parses a node with wrapped attributes' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div[ test="value" ]
      OPULENT
    end

    it 'parses a node with wrapped attributes' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div[ test =~ "value" ]
      OPULENT
    end

    it 'parses a node with wrapped attributes' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div( test =~ "value" )
      OPULENT
    end

    it 'parses a node with wrapped attributes' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div( test =~ "value", different="other" )
      OPULENT
    end

    it 'parses a node with wrapped attributes on multiple lines' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div(
          asdf="test"
          test =~ "value"
          different="other"
        )
      OPULENT
    end

    it 'parses a node with wrapped attributes on multiple lines' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div( inline_attr="value"
          inner_attr="value"
        outer_attr="value")
      OPULENT
    end

    it 'parses a node with wrapped attributes on multiple lines' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        p div( inline_attr="value" inner_attr="value"
        outer_attr="value")
      OPULENT
    end

    it 'parses expressions in unwrapped context' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div attr=value
      OPULENT
    end

    it 'parses expressions in wrapped context' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div(attr=value)
      OPULENT
    end

    it 'parses expressions in wrapped context' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div(attr=value1 + value2)
      OPULENT
    end

    it 'parses expressions in wrapped context' do
      Opulent::Parser.new('index', {}).parse <<-OPULENT
        div(checked id="test"
          more checks=~)
      OPULENT
    end

    it 'parses expressions in wrapped context' do
      p Opulent::Parser.new('index', {}).parse <<-OPULENT
        div(attr=value1 + value2 < value 3)
      OPULENT
    end
  end
end
