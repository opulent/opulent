require_relative '../../lib/opulent'

puts "\n"
opulent = Opulent.new <<-OPULENT
def node(count = 5)
  - count -= 1
  if count > 0
    node* count=count
      node
        yield

node
  child
OPULENT

result = opulent.render Object.new, test: { ext: 123 } {}
puts opulent.template
puts "\n\n\n", result
