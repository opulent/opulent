require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#render' do
    it 'includes a file inside the current one' do
      opulent = Opulent.new <<-OPULENT
include ../../spec/helpers/include.op
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<ul><li></li><li></li></ul>')
    end

    it 'includes a file inside the current one and adds .op extension' do
      opulent = Opulent.new <<-OPULENT
include ../../spec/helpers/include
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<ul><li></li><li></li></ul>')
    end

    it 'includes a file inside the current one and indents it' do
      opulent = Opulent.new <<-OPULENT
div
  include ../../spec/helpers/include.op
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<div><ul><li></li><li></li></ul></div>')
    end

    it 'fails including if file doesn\'t exist' do
      expect do
        opulent = Opulent.new <<-OPULENT
  include ../../spec/helpers/doesnt_exist.op
        OPULENT

        result = opulent.render Object.new, {} {}
      end.to raise_error(RuntimeError)
    end

    it 'fails including if file is a folder' do
      expect do
        opulent = Opulent.new <<-OPULENT
  include ../../spec/helpers
        OPULENT

        result = opulent.render Object.new, {} {}
      end.to raise_error(RuntimeError)
    end
  end
end
