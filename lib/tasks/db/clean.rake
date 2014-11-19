namespace :db do
  task :clean do 
    [:order_lines, :orders, :products, :customers].each do |table|
      DB[table].delete
    end
  end
end
