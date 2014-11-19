RSpec.configure do |config|
  config.before(:suite) do
    [:order_lines, :orders, :products, :customers].each do |table|
      DB[table].delete
    end
  end
end
