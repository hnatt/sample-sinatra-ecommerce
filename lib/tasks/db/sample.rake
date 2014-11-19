namespace :db do 
  SAMPLE = {
    customer: { firstname: 'Bob', lastname: 'Ross',
                email: 'bross@example.com',
                password: 'happyaccidents' },
    products: {
      sinatra_book: {
        name: 'Sinatra Book',
        price: 10.99,
        description: 'A fast and easy way to get started with Sinatra',
        status: 1,
      },
      rspec_book: {
        name: 'RSpec Book',
        price: 15.49,
        description: 'RSpec testing framework handbook',
        status: 1,
      },
      ruby_book: {
        name: 'Getting Started With Ruby',
        price: 19.99,
        description: 'From beginner to professional',
        status: 1,
      },
    },
    orders: [
      { ruby_book: 1,
        rspec_book: 1 },
      { sinatra_book: 3 },
      { rspec_book: 10 },
    ]
  }

  def create_customer 
    printf "Creating sample customer %s %s. Email: %s, password: %s \n",
           * SAMPLE[:customer].values
    Customer.create SAMPLE[:customer]
  end

  def create_products 
    Hash[SAMPLE[:products].map do |key, attrs|
      puts "Creating sample product: #{attrs[:name]}"
      product = Product.create attrs 
      [key, product]
    end]
  end

  def create_orders(customer, products) 
    SAMPLE[:orders].map do |lines| 
      order = Order.create customer: customer
      lines.map do |key, qty|
        order.add_order_line OrderLine.new product: products[key],
                                           qty: qty
      end
      puts "Sample order created: #{order.order_no}"
      order
    end
  end

  task :sample do 
    customer = create_customer
    products = create_products
    create_orders(customer, products)
  end
end
