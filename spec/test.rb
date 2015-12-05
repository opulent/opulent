require_relative '../lib/opulent'

puts "\n"
opulent = Opulent.new <<-OPULENT
def node(attr1="default", attr2)
  .node
    yield

node
OPULENT
opulent.render Object.new, {} {}
puts "\n\n\n", opulent.template
