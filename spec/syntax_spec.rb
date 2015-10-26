require 'rspec'
require_relative '../lib/opulent.rb'

locals = {
  a: 3,
  html_var: '<div></div>',
  interpolated_string: 'string',
  interpolated_hash: { a: 1, b: 2 },
  interpolated_array: [1, 2, 3]
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

    # @test
    it 'renders inline text' do
      op = Opulent.new 'p Hello world!'
      result = op.render self, locals
      expect(result).to eq('<p>Hello world!</p>')
    end

    # @test
    it 'renders block text' do
      op = Opulent.new <<-OPULENT
| This is a block
  of text
  on multiple lines
      OPULENT
      result = op.render self, locals
      expect(result).to eq("This is a block\nof text\non multiple lines")
    end

    # @test
    it 'renders block text inside a tag' do
      op = Opulent.new <<-OPULENT
p |
  This is a block
      OPULENT
      result = op.render self, locals
      expect(result).to eq('<p>This is a block</p>')
    end

    # @test
    it 'renders multiple blank lines' do
      op = Opulent.new <<-OPULENT



      OPULENT
      result = op.render self, locals
      expect(result).to eq('')
    end

    # @test
    it 'renders inline children' do
      op = Opulent.new <<-OPULENT
ul > li > a
      OPULENT
      result = op.render self, locals
      expect(result).to eq('<ul><li><a></a></li></ul>')
    end

    # @test
    it 'renders inline children with attributes' do
      op = Opulent.new <<-OPULENT
ul class="list-inline" > li class="list-item" > a class="list-link"
      OPULENT
      result = op.render self, locals
      expect(result).to eq(
        '<ul class="list-inline">' \
        '<li class="list-item">' \
        '<a class="list-link">'\
        '</a>'\
        '</li>'\
        '</ul>'
      )
    end

    # @test
    it 'renders inline children with mixed attributes' do
      op = Opulent.new <<-OPULENT
ul.list-inline > li class="list-item" > a#link
      OPULENT
      result = op.render self, locals
      expect(result).to eq(
        '<ul class="list-inline">' \
        '<li class="list-item">' \
        '<a id="link">'\
        '</a>'\
        '</li>'\
        '</ul>'
      )
    end

    # @test
    it 'renders children' do
      op = Opulent.new <<-OPULENT
ul
  li
    a
      OPULENT
      result = op.render self, locals
      expect(result).to eq('<ul><li><a></a></li></ul>')
    end

    # @test
    it 'renders interpolated strings' do
      op = Opulent.new <<-OPULENT
|~ \#{interpolated_string}
      OPULENT
      result = op.render self, locals
      expect(result).to eq(
        'string'
      )
    end

    # @test
    it 'renders interpolated hash' do
      op = Opulent.new <<-OPULENT
|~ \#{interpolated_hash}
      OPULENT
      result = op.render self, locals
      expect(result).to eq(
        '{:a=>1, :b=>2}'
      )
    end

    # @test
    it 'renders interpolated array' do
      op = Opulent.new <<-OPULENT
|~ \#{interpolated_array}
      OPULENT
      result = op.render self, locals
      expect(result).to eq(
        '123'
      )
    end
  end
end
