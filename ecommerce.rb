require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/flash'
require 'slim'
require 'sass'
require_relative 'database'
require './lib/shopping_cart'

class Ecommerce < Sinatra::Base
  register Sinatra::AssetPack
  register Sinatra::Flash
  enable :sessions
  enable :method_override

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

  Dir['./helpers/*.rb'].each do |f|
    require f
    helper_name = File.basename(f, '.*').split('_').map(&:capitalize).join
    helpers Module.const_get("#{helper_name}Helper")
  end

  run! if app_file == $0
end
