require_relative '../lib/opulent'

opulent = Opulent.new <<-OPULENT
def node(attr1, attr2)
  .node
OPULENT

result = opulent.render Object.new, {} {}
