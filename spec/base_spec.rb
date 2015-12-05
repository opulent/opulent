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

    it 'renders multiple blank lines' do
      opulent = Opulent.new <<-OPULENT



      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('')
    end
  end
end
