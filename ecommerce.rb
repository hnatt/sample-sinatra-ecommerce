require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/flash'
require 'slim'
require 'sass'
require_relative 'database'

class Ecommerce < Sinatra::Base
  register Sinatra::AssetPack
  register Sinatra::Flash
  enable :sessions

  assets do
    serve '/js', from: 'assets/js'
    serve '/bower_components', from: 'bower_components'
    js :modernizr, [
      '/bower_components/modernizr/modernizr.js',
    ]

    js :libs, [
      '/bower_components/jquery/dist/jquery.js',
      '/bower_components/foundation/js/foundation.js'
    ]

    js :application, [
      '/js/app.js'
    ]

    js_compression :jsmin
  end

  Dir['./routes/**/*.rb'].each { |f| require f }

  run! if app_file == $0
end
