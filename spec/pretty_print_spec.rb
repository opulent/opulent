require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#render' do

    it 'renders pretty printed html' do
      code = <<-OPULENT
html
  head
  body
      OPULENT
      opulent = Opulent.new code, pretty: true

      result = opulent.render Object.new, {} {}
      expect(result).to eq <<-HTML
<html>
  <head></head>
  <body></body>
</html>
      HTML
    end

    it 'renders pretty printed html' do
      code = <<-OPULENT
html
  head
  body
    div
    div
    #content
      |Hello world!
      OPULENT
      opulent = Opulent.new code, pretty: true

      result = opulent.render Object.new, {} {}
      expect(result).to eq <<-HTML
<html>
  <head></head>
  <body>
    <div></div>
    <div></div>
    <div id="content">
      Hello world!
    </div>
  </body>
</html>
      HTML
    end

    it 'renders pretty printed html' do
      code = <<-OPULENT
html
  head
  body
    #content
      |Hello world!
      strong I am opulent
      span and I like
      | indentation.
      OPULENT
      opulent = Opulent.new code, pretty: true

      result = opulent.render Object.new, {} {}
      expect(result).to eq <<-HTML
<html>
  <head></head>
  <body>
    <div id="content">
      Hello world!<strong>I am opulent</strong><span>and I like</span>indentation.
    </div>
  </body>
</html>
      HTML
    end


  end
end
