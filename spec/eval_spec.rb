require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#render' do
    it 'renders evaluation line with print' do
      opulent = Opulent.new <<-OPULENT
= var
      OPULENT

      result = opulent.render Object.new, { var: 'print' } {}
      expect(result).to eq('print')
    end

    it 'renders evaluation line without print' do
      opulent = Opulent.new <<-OPULENT
- var
      OPULENT

      result = opulent.render Object.new, { var: 'print' } {}
      expect(result).to eq('')
    end

    it 'renders evaluation line with assign and print' do
      opulent = Opulent.new <<-OPULENT
- var = 5
= var
      OPULENT

      result = opulent.render Object.new, { var: 'print' } {}
      expect(result).to eq('5')
    end

    it 'renders expression do with end terminator' do
      opulent = Opulent.new <<-OPULENT
- 5.times do
  = 1
      OPULENT

      result = opulent.render Object.new, { var: 'print' } {}
      expect(result).to eq('11111')
    end

    it 'renders conditional with end terminator' do
      opulent = Opulent.new <<-OPULENT
- if 5 > 3
  = 1
      OPULENT

      result = opulent.render Object.new, { var: 'print' } {}
      expect(result).to eq('1')
    end

    it 'renders conditional and removes end terminator from if' do
      opulent = Opulent.new <<-OPULENT
- if false
  = 1
- else
  = 2
      OPULENT

      result = opulent.render Object.new, { var: 'print' } {}
      expect(result).to eq('2')
    end

    it 'renders fails on explicit end' do 
      expect do
        Opulent.new <<-OPULENT
  - if false
    = 1
  - end
        OPULENT
      end.to raise_error(RuntimeError)
    end
  end
end
