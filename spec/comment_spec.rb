require 'rspec'
require_relative '../lib/opulent'

RSpec.describe Opulent do
  describe '#render' do
    it 'renders single line comment' do
      opulent = Opulent.new <<-OPULENT
/ This is a comment
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('')
    end

    it 'renders multiple line comment' do
      opulent = Opulent.new <<-OPULENT
/ This is a comment
  on multiple
  lines
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('')
    end

    it 'renders single line visible comment' do
      opulent = Opulent.new <<-OPULENT
/! This is a comment
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq('<!-- This is a comment -->')
    end

    it 'renders multiple line visible comment' do
      opulent = Opulent.new <<-OPULENT
/!This is a comment
  on multiple lines
      OPULENT

      result = opulent.render Object.new, {} {}
      expect(result).to eq("<!-- This is a comment\non multiple lines -->")
    end
  end
end
