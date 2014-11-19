require 'sequel'
require 'mysql2'
require 'yaml'

DB = Sequel.connect(YAML.load_file('database.yml')[ENV['RACK_ENV']])

DB.create_table?(:products) do
  primary_key :id
  String      :name
  BigDecimal  :price, size: [8, 2]
  Int         :status, default: 1
  Text        :description
end

DB.create_table?(:customers) do
  primary_key :id
  String      :firstname
  String      :lastname
  String      :email
  String      :password
end

DB.create_table?(:orders) do
  primary_key :id
  String      :order_no
  foreign_key :customer_id, :customers
  BigDecimal  :total, size: [8, 2]
  Date        :date
end

DB.create_table?(:order_lines) do
  primary_key :id
  foreign_key :order_id, :orders
  foreign_key :product_id, :products
  Integer     :qty
  Decimal     :unit_price, size: [8, 2]
  Decimal     :total_price, size: [8, 2]
end

Dir.glob('./models/**/*.rb').each { |f| require f }
