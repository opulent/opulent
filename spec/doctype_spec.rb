require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#render' do
    it 'renders custom doctypes' do
      opulent = Opulent.new <<-OPULENT
        doctype custom
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<!DOCTYPE custom>')
    end
  end
end
