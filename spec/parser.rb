require 'rspec'
require '../lib/opulent'

RSpec.describe Opulent do
  describe '#parse' do
    it 'parses' do
      op = Opulent::Parser.new
      expect(result).to eq('test')
    end
  end
end
