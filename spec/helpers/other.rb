require_relative '../../lib/opulent'

puts "\n"
opulent = Opulent.new <<-OPULENT
def node(attr1="default", attr2)
  .node attr1=attr1 attr2=attr2

node
OPULENT

result = opulent.render Object.new, test: { ext: 123 } {}
puts opulent.template
puts "\n\n\n", result
