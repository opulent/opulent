require 'opulent'
require 'yaml'
require 'json'
require 'pp'

# @Render
class Render
  def self.start
    views_path = '../views/'
    views = YAML.load File.read 'pages.yml'
    view = ARGV[0]
    view_data = views[ARGV[0]]

    return unless view_data

    layout_path = "#{views_path}#{view_data[:layout]}"
    page_path = "#{views_path}pages/#{view}"
    page_output_path = "../html/#{view_data[:output]}"

    locals = YAML.load File.read 'meta.yml'
    locals[:title] = view_data[:title]

    opulent_layout = Opulent.new layout_path.to_sym
    opulent = Opulent.new page_path.to_sym, def: opulent_layout.def

    output = opulent_layout.render(self, locals){
      opulent.render(self, locals){}
    }

    File.open "../html/#{view_data[:output]}", 'w' do |file|
      file.write output
    end
  end
end

Render.start
