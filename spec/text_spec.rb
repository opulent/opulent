require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#render' do
    it 'renders explicit text on a single line' do
      opulent = Opulent.new <<-OPULENT
| Hello world!
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('Hello world!')
    end

    it 'renders explicit text on multiple lines' do
      opulent = Opulent.new <<-OPULENT
| Hello world!
  This is another line.
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq("Hello world!\nThis is another line.")
    end

    it 'renders explicit text on multiple lines and keeps indentation' do
      opulent = Opulent.new <<-OPULENT
| Hello world!
  This is another line.
    This is indented.
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        "Hello world!\nThis is another line.\n  This is indented."
      )
    end

    it 'renders inline text' do
      opulent = Opulent.new <<-OPULENT
div Hello world!
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div>Hello world!</div>')
    end

    it 'renders explicit inline text' do
      opulent = Opulent.new <<-OPULENT
div \ Hello world!
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div>Hello world!</div>')
    end

    it 'renders explicit child text' do
      opulent = Opulent.new <<-OPULENT
div | Hello world!
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div>Hello world!</div>')
    end

    it 'renders explicit multiline child text' do
      opulent = Opulent.new <<-OPULENT
div | Hello world!
      This is a text.
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq("<div>Hello world!\nThis is a text.</div>")
    end

    it 'renders explicit multiline child text and keeps indentation' do
      opulent = Opulent.new <<-OPULENT
div | Hello world!
      This is a text.
        This will be indented.
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        "<div>Hello world!\nThis is a text.\n  This will be indented.</div>"
      )
    end

    it 'renders escaped text' do
      opulent = Opulent.new <<-OPULENT
| This is <escaped>
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        'This is &lt;escaped&gt;'
      )
    end

    it 'renders unescaped text' do
      opulent = Opulent.new <<-OPULENT
|~ This is <escaped>
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        'This is <escaped>'
      )
    end

    it 'renders text with leading whitespace' do
      opulent = Opulent.new <<-OPULENT
|' This has whitespace
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        ' This has whitespace'
      )
    end

    it 'renders text with trailing whitespace' do
      opulent = Opulent.new <<-OPULENT
|" This has whitespace
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        'This has whitespace '
      )
    end

    it 'renders text with leading and trailing whitespace' do
      opulent = Opulent.new <<-OPULENT
|'" This has whitespace
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        ' This has whitespace '
      )
    end

    it 'renders escaped text with leading and trailing whitespace' do
      opulent = Opulent.new <<-OPULENT
|'"~ This has <whitespace>
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq(
        ' This has <whitespace> '
      )
    end

    it 'renders interpolated variables' do
      opulent = Opulent.new <<-OPULENT
p This is \#{interpolated}.
      OPULENT

      result = opulent.render Object.new, { interpolated: 'true' } {}
      expect(result).to eq('<p>This is true.</p>')
    end

    it 'renders escaped interpolated variables' do
      opulent = Opulent.new <<-OPULENT
p This is \#{interpolated}.
      OPULENT

      result = opulent.render Object.new, { interpolated: '<interpolate>' } {}
      expect(result).to eq('<p>This is &lt;interpolate&gt;.</p>')
    end

    it 'renders unescaped interpolated variables' do
      opulent = Opulent.new <<-OPULENT
p ~ This is \#{interpolated}.
      OPULENT

      result = opulent.render Object.new, { interpolated: '<interpolate>' } {}
      expect(result).to eq('<p>This is <interpolate>.</p>')
    end

    it 'escapes interpolated variables' do
      opulent = Opulent.new <<-OPULENT
p This is not \\\#{interpolated}.
      OPULENT

      result = opulent.render Object.new, { interpolated: 'true' } {}
      expect(result).to eq('<p>This is not #{interpolated}.</p>')
    end

    it 'renders interpolated variables' do
      opulent = Opulent.new <<-OPULENT
pre |
  - href = "/css/\\\#{href}.css"
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq("<pre>- href = &quot;/css/\#{href}.css&quot;</pre>")
    end
  end
end
