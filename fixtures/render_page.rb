require 'opulent'
require 'yaml'
require 'json'
require 'pp'

# @Render
class Render
  def self.start
    views_path = '../views/'
    locals = YAML.load File.read 'meta.yml'
    views = YAML.load File.read 'pages.yml'
    site_locals = YAML.load File.read 'site.yml' if File.exist? 'site.yml'

    view = ARGV[0]
    view_data = views[ARGV[0]]

    return unless view_data

    layout_path = "#{views_path}#{view_data[:layout]}"
    page_path = "#{views_path}#{view}"
    page_output_path = "../#{view_data[:output]}"

    locals[:title] = view_data[:title]
    locals[:navbar_active] = view_data[:navbar] ? view_data[:navbar].to_sym : :index
    locals.merge! site_locals if site_locals

    opulent_layout = Opulent.new layout_path.to_sym
    opulent = Opulent.new page_path.to_sym, def: opulent_layout.def

    output = opulent_layout.render(self, locals){
      opulent.render(self, locals){}
    }

    File.open page_output_path, 'w' do |file|
      file.write output
    end
  end
end

Render.start
