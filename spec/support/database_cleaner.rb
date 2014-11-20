RSpec.configure do |config|
  config.before(:all) do
    [:order_lines, :orders, :products, :customers].each do |table|
      DB[table].delete
    end
  end
end
