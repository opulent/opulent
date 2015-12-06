require_relative '../lib/opulent'

puts "\n"
opulent = Opulent.new <<-OPULENT
div+{a: "<<", b: 2} id=test[:ext]
OPULENT
puts "\n\n\n", opulent.template

result = opulent.render Object.new, test: { ext: 123 } {}
puts "\n\n\n", result
