require 'yaml'
require 'fileutils'

# @Render
class Render
  def self.start
    views = YAML.load File.read 'pages.yml'
    views_path = '../views/'

    views.each do |view, view_data|
      layout_path = "#{views_path}#{view_data[:layout]}"
      page_path = "#{views_path}pages/#{view}"
      page_output_path = "../html/#{view_data[:output]}"

      unless File.file? layout_path
        FileUtils.touch layout_path
        puts "Created #{layout_path} file."
      end

      unless File.file? page_path
        FileUtils.touch page_path
        puts "Created #{page_path} file."
      end

      unless File.file? page_output_path
        FileUtils.touch page_output_path
        puts "Created #{page_output_path} file."
      end
    end
  end
end

Render.start
