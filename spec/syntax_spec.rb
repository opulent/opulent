require 'rspec'
require_relative '../lib/opulent.rb'

locals = {
  a: 3,
  html_var: '<div></div>'
}

RSpec.describe Opulent do
  describe '#render' do
    # @test
    it 'render a simple tag' do
      op = Opulent.new 'tag'
      result = op.render
      expect(result).to eq('<tag></tag>')
    end

    # @test
    it 'renders an id' do
      op = Opulent.new '#id'
      result = op.render
      expect(result).to eq('<div id="id"></div>')
    end

    # @test
    it 'renders overwrites multiple ids' do
      op = Opulent.new '#id1#id2'
      result = op.render
      expect(result).to eq('<div id="id2"></div>')
    end

    # @test
    it 'renders a class' do
      op = Opulent.new '.class'
      result = op.render
      expect(result).to eq('<div class="class"></div>')
    end

    # @test
    it 'renders multiple classes' do
      op = Opulent.new '.class1.class2'
      result = op.render
      expect(result).to eq('<div class="class1 class2"></div>')
    end

    # @test
    it 'renders ids combined with classes' do
      op = Opulent.new '#id.class1.class2'
      result = op.render
      expect(result).to eq('<div class="class1 class2" id="id"></div>')
    end

    # @test
    it 'renders one inline attribute' do
      op = Opulent.new 'div attr="value"'
      result = op.render
      expect(result).to eq('<div attr="value"></div>')
    end

    # @test
    it 'renders multiple inline attributes' do
      op = Opulent.new 'div attr1="value1" attr2="value2"'
      result = op.render
      expect(result).to eq('<div attr1="value1" attr2="value2"></div>')
    end

    # @test
    it 'renders encapsulated attributes with round brackets' do
      op = Opulent.new 'div(attr1="value1", attr2="value2")'
      result = op.render
      expect(result).to eq('<div attr1="value1" attr2="value2"></div>')
    end

    # @test
    it 'renders encapsulated attributes with round brackets' do
      op = Opulent.new 'div(attr1:"value1", attr2:"value2")'
      result = op.render
      expect(result).to eq('<div attr1="value1" attr2="value2"></div>')
    end

    # @test
    it 'renders encapsulated attributes with curly brackets' do
      op = Opulent.new 'div{attr1="value1", attr2="value2"}'
      result = op.render
      expect(result).to eq('<div attr1="value1" attr2="value2"></div>')
    end

    # @test
    it 'renders encapsulated attributes with curly brackets' do
      op = Opulent.new 'div{attr1:"value1", attr2:"value2"}'
      result = op.render
      expect(result).to eq('<div attr1="value1" attr2="value2"></div>')
    end

    # @test
    it 'renders encapsulated attributes with square brackets' do
      op = Opulent.new 'div[attr1="value1", attr2="value2"]'
      result = op.render
      expect(result).to eq('<div attr1="value1" attr2="value2"></div>')
    end

    # @test
    it 'renders encapsulated attributes with square brackets' do
      op = Opulent.new 'div[attr1:"value1", attr2:"value2"]'
      result = op.render
      expect(result).to eq('<div attr1="value1" attr2="value2"></div>')
    end

    # @test
    it 'renders escaped attributes' do
      op = Opulent.new 'div attr="<div></div>"'
      result = op.render
      expect(result).to eq('<div attr="&lt;div&gt;&lt;/div&gt;"></div>')
    end

    # @test
    it 'renders unescaped attributes' do
      op = Opulent.new 'div attr=~"<div></div>"'
      result = op.render
      expect(result).to eq('<div attr="<div></div>"></div>')
    end

    # @test
    it 'renders escaped local' do
      op = Opulent.new 'div attr=html_var'
      result = op.render self, locals
      expect(result).to eq('<div attr="&lt;div&gt;&lt;/div&gt;"></div>')
    end

    # @test
    it 'renders unescaped local' do
      op = Opulent.new 'div attr=~html_var'
      result = op.render self, locals
      expect(result).to eq('<div attr="<div></div>"></div>')
    end
  end
end
