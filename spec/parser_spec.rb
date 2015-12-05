require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#render' do
    it 'renders blank input' do
      opulent = Opulent.new <<-OPULENT
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('')
    end

    it 'renders a node with id' do
      opulent = Opulent.new <<-OPULENT
        div#id
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div id="id"></div>')
    end

    it 'renders a node with escaped id' do
      opulent = Opulent.new <<-OPULENT
        div#~id
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div id="id"></div>')
    end

    it 'renders a node with string id' do
      opulent = Opulent.new <<-OPULENT
        div#"id"
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div id="id"></div>')
    end

    it 'renders a node with escaped string id' do
      opulent = Opulent.new <<-OPULENT
        div#~"id"
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div id="id"></div>')
    end

    it 'renders a node with shorthand syntax' do
      opulent = Opulent.new <<-OPULENT
        #id
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div id="id"></div>')
    end

    it 'renders a node with squared bracket wrapped attribute' do
      opulent = Opulent.new <<-OPULENT
        div[attr="value"]
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div attr="value"></div>')
    end

    it 'renders a node with round bracket wrapped attribute' do
      opulent = Opulent.new <<-OPULENT
        div(attr="value")
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div attr="value"></div>')
    end

    it 'renders a node with curly bracket wrapped attribute' do
      opulent = Opulent.new <<-OPULENT
        div{attr="value"}
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div attr="value"></div>')
    end

    it 'renders a node with wrapped attribute and whitespace' do
      opulent = Opulent.new <<-OPULENT
        div[ attr="value" ]
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div attr="value"></div>')
    end

    it 'renders a node with wrapped escaped attribute' do
      opulent = Opulent.new <<-OPULENT
        div[ attr =~ "value" ]
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div attr="value"></div>')
    end

    it 'renders a node with mixed escape wrapped attributes' do
      opulent = Opulent.new <<-OPULENT
        div( attr1 =~ "value<" attr2="value<" )
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div attr1="value<" attr2="value&lt;"></div>')
    end

    it 'fails rendering if a comma appears' do
      expect do
        opulent = Opulent.new <<-OPULENT
          div( attr1 =~ "value<", attr2="value<" )
        OPULENT

        opulent.render Object.new, {} {}
      end.to raise_error(RuntimeError)
    end

    it 'fails rendering if it ends in comma' do
      expect do
        opulent = Opulent.new <<-OPULENT
          div( attr1 =~ "value<" attr2="value<" ,)
        OPULENT

        opulent.render Object.new, {} {}
      end.to raise_error(RuntimeError)
    end

    it 'renders a node with wrapped attributes on multiple lines' do
      opulent = Opulent.new <<-OPULENT
        div(
          attr1="test"
          attr2 =~ "value&"
          attr3="other&"
        )
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div attr1="test" attr2="value&" attr3="other&amp;"></div>')
    end

    it 'renders a node with wrapped attributes on multiple lines' do
      opulent = Opulent.new <<-OPULENT
        div( inline_attr="value"
          inner_attr="value"
        outer_attr="value")
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div inline_attr="value" inner_attr="value" outer_attr="value"></div>')
    end

    it 'renders a node with wrapped attributes on multiple lines' do
      opulent = Opulent.new <<-OPULENT
        div( inline_attr="value" inner_attr="value"
        outer_attr="value")
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div inline_attr="value" inner_attr="value" outer_attr="value"></div>')
    end

    it 'renders expressions in unwrapped context' do
      opulent = Opulent.new <<-OPULENT
        div attr=value
      OPULENT

      result = opulent.render(Object.new, value: 5) {}
      expect(result).to eq('<div attr="5"></div>')
    end

    it 'renders expressions in wrapped context' do
      opulent = Opulent.new <<-OPULENT
        div(attr=value)
      OPULENT

      result = opulent.render(Object.new, value: 5) {}
      expect(result).to eq('<div attr="5"></div>')
    end

    it 'renders expressions in wrapped context' do
      opulent = Opulent.new <<-OPULENT
        div(attr=value1 + value2)
      OPULENT

      result = opulent.render(Object.new, value1: 5, value2: 5) {}
      expect(result).to eq('<div attr="10"></div>')
    end

    it 'renders expressions in wrapped context' do
      opulent = Opulent.new <<-OPULENT
        div(checked id="test"
          more checks=~"")
      OPULENT

      result = opulent.render(Object.new, value1: 5, value2: 5) {}
      expect(result).to eq('<div checked id="test" more checks=""></div>')
    end

    it 'renders expressions in wrapped context' do
      opulent = Opulent.new <<-OPULENT
        div(attr=value1 + value2 > value3)
      OPULENT

      result = opulent.render(Object.new, value1: 5, value2: 5, value3:11) {}
      expect(result).to eq('<div></div>')
    end
  end
end
