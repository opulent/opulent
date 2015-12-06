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

    it 'renders wrapped attributes with optional terminators' do
      opulent = Opulent.new <<-OPULENT
        div(attr1="value", attr2="value"; attr3="value")
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        '<div attr1="value" attr2="value" attr3="value"></div>'
      )
    end

    it 'fails rendering if a comma appears' do
      expect do
        opulent = Opulent.new <<-OPULENT
          div( attr1 =~ "value<"@@ attr2="value<" )
        OPULENT

        opulent.render Object.new, {} {}
      end.to raise_error(RuntimeError)
    end

    it 'fails rendering if it ends in comma' do
      expect do
        opulent = Opulent.new <<-OPULENT
          div( attr1 =~ "value<" attr2="value<" 33)
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
      expect(result).to eq(
        '<div attr1="test" attr2="value&" attr3="other&amp;"></div>'
      )
    end

    it 'renders a node with wrapped attributes on multiple lines' do
      opulent = Opulent.new <<-OPULENT
        div( inline_attr="value"
          inner_attr="value"
        outer_attr="value")
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        '<div inline_attr="value" inner_attr="value" outer_attr="value"></div>'
      )
    end

    it 'renders a node with wrapped attributes on multiple lines' do
      opulent = Opulent.new <<-OPULENT
        div( inline_attr="value" inner_attr="value"
        outer_attr="value")
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        '<div inline_attr="value" inner_attr="value" outer_attr="value"></div>'
      )
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

      result = opulent.render(Object.new, value1: 5, value2: 5, value3: 11) {}
      expect(result).to eq('<div></div>')
    end

    it 'renders leading whitespace' do
      opulent = Opulent.new <<-OPULENT
        div'
      OPULENT

      result = opulent.render(Object.new, value1: 5, value2: 5, value3: 11) {}
      expect(result).to eq(' <div></div>')
    end

    it 'renders trailing whitespace' do
      opulent = Opulent.new <<-OPULENT
        div"
      OPULENT

      result = opulent.render(Object.new, value1: 5, value2: 5, value3: 11) {}
      expect(result).to eq('<div></div> ')
    end

    it 'renders leading and trailing whitespace' do
      opulent = Opulent.new <<-OPULENT
        div'"
      OPULENT

      result = opulent.render(Object.new, value1: 5, value2: 5, value3: 11) {}
      expect(result).to eq(' <div></div> ')
    end

    it 'renders attribute extension' do
      opulent = Opulent.new <<-OPULENT
        div+ext
      OPULENT

      result = opulent.render(Object.new, ext: { a: 1, b: 2 }) {}
      expect(result).to eq('<div a="1" b="2"></div>')
    end

    it 'renders inline children' do
      opulent = Opulent.new <<-OPULENT
        ul > li > a
      OPULENT

      result = opulent.render(Object.new, ext: { a: 1, b: 2 }) {}
      expect(result).to eq('<ul><li><a></a></li></ul>')
    end

    it 'renders attribute override' do
      opulent = Opulent.new <<-OPULENT
        div attr="value1" attr="value2"
      OPULENT

      result = opulent.render(Object.new, ext: { a: 1, b: 2 }) {}
      expect(result).to eq('<div attr="value2"></div>')
    end

    it 'renders array attribute' do
      opulent = Opulent.new <<-OPULENT
        div attr=array
      OPULENT

      result = opulent.render(Object.new, array: %w(key1 key2)) {}
      expect(result).to eq('<div attr="key1_key2"></div>')
    end

    it 'renders hash attribute' do
      opulent = Opulent.new <<-OPULENT
        div attr=hash
      OPULENT

      result = opulent.render(Object.new, hash: { a: '1', b: '2' }) {}
      expect(result).to eq('<div attr-a="1" attr-b="2"></div>')
    end

    it 'renders multiple class attributes' do
      opulent = Opulent.new <<-OPULENT
        div class="a" class="b" class="c"
      OPULENT

      result = opulent.render(Object.new, hash: { a: '1', b: '2' }) {}
      expect(result).to eq('<div class="a b c"></div>')
    end

    it 'renders multiple class attributes mixed escape' do
      opulent = Opulent.new <<-OPULENT
        div class="a" class=~"<b>" class="c"
      OPULENT

      result = opulent.render(Object.new, hash: { a: '1', b: '2' }) {}
      expect(result).to eq('<div class="a <b> c"></div>')
    end

    it 'renders multiple class attributes mixed escape' do
      opulent = Opulent.new <<-OPULENT
        div class="<a>" class=~"<b>"
      OPULENT

      result = opulent.render(Object.new, hash: { a: '1', b: '2' }) {}
      expect(result).to eq('<div class="&lt;a&gt; <b>"></div>')
    end

    it 'renders extension' do
      opulent = Opulent.new <<-OPULENT
        div+hash
      OPULENT

      result = opulent.render(Object.new, hash: { a: '1', b: '2' }) {}
      expect(result).to eq('<div a="1" b="2"></div>')
    end

    it 'renders extension and wrapped attributes' do
      opulent = Opulent.new <<-OPULENT
        div(attr="value")+hash
      OPULENT

      result = opulent.render(Object.new, hash: { a: '1', b: '2' }) {}
      expect(result).to eq('<div attr="value" a="1" b="2"></div>')
    end

    it 'renders extension and wrapped+unwrapped attributes' do
      opulent = Opulent.new <<-OPULENT
        div(attr="value")+hash unwrapped="value"
      OPULENT

      result = opulent.render(Object.new, hash: { a: '1', b: '2' }) {}
      expect(result).to eq(
        '<div attr="value" unwrapped="value" a="1" b="2"></div>'
      )
    end

    it 'renders unescaped extension' do
      opulent = Opulent.new <<-OPULENT
        div+hash
      OPULENT

      result = opulent.render(Object.new, hash: { a: '<1>', b: '<2>' }) {}
      expect(result).to eq('<div a="&lt;1&gt;" b="&lt;2&gt;"></div>')
    end

    it 'renders escaped extension' do
      opulent = Opulent.new <<-OPULENT
        div+~hash
      OPULENT

      result = opulent.render(Object.new, hash: { a: '<1>', b: '<2>' }) {}
      expect(result).to eq('<div a="<1>" b="<2>"></div>')
    end
  end
end
