require 'yaml'
require 'rack-livereload'

# @Application
module Application
  # @RockSlider
  class Opulent < Base
    # Run LiveReload Server
    use Rack::LiveReload, live_reload_port: 35730 if Sinatra::Base.development?

    # Set views folder
    set :views, File.join(File.dirname(__FILE__), 'views')

    # Set public folder
    set :public_folder, File.join(File.dirname(__FILE__), 'assets')

    # Load local site data
    locals = YAML.load File.read File.join(File.dirname(__FILE__), 'site.yml')

    # Load application data
    before do
      @application_route = '/opulent'
    end

    # Routes
    #

    get '/' do
      @page_title = make_title 'Opulent', 'Templating Engine for Creative Web Developers'

      opulent :'landing/index', layout: :'landing/layout', locals: locals
    end

    get '/documentation' do
      @page_title = make_title 'Opulent', 'Documentation'

      opulent :'documentation/index', layout: :'documentation/layout', locals: locals
    end

    # 404 Error
    not_found do
      @page_title = make_title 'Opulent', '404 Not Found'

      status 404
      opulent :'error/404', locals: locals
    end

    # 500 Error
    error do
      @page_title = make_title 'Opulent', '500 Internal Error'

      status 500
      opulent :'error/500', locals: locals
    end
  end
end
