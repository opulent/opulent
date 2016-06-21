require 'opulent'
require 'yaml'
require 'json'
require 'pp'

# @Render
class Render
  def self.start
    views_path = '../views/'
    views = YAML.load File.read 'pages.yml'
    locals = YAML.load File.read 'meta.yml'
    opulent_layouts = {}

    views.each do |view, view_data|
      layout_path = "#{views_path}#{view_data[:layout]}"
      page_path = "#{views_path}pages/#{view}"
      page_output_path = "../#{view_data[:output]}"

      locals[:title] = view_data[:title]

      opulent_layouts[layout_path] ||= Opulent.new layout_path.to_sym
      opulent = Opulent.new page_path.to_sym, def: opulent_layouts[layout_path].def

      output = opulent_layouts[layout_path].render(self, locals){
        opulent.render(self, locals){}
      }

      puts page_path

      File.open page_output_path, 'w' do |file|
        file.write output
      end
    end
  end
end

Render.start
