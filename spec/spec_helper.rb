ENV['RACK_ENV'] ||= 'test'
require 'rack/test'
require './ecommerce'
require 'capybara/rspec'

Dir.glob('./spec/support/*.rb') { |f| require f }
Capybara.app = Ecommerce
