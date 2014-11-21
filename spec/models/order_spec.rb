describe Order do
  context 'validates' do
    context 'required fields' do
      let(:order) { Order.new }
      it do
        expect(order.valid?).to be(false)
        expect(order.errors.keys).to contain_exactly(:customer)
      end
    end
  end

  context 'persists' do
    def customer
      Customer.create first_name: 'John', last_name: 'Doe',
                      email: 'jdoe@example.com', password: 'secret!!!'
    end
    def sinatra_book
      Product.create name: 'Sinatra Book', price: 10.0,
                     status: 1, description: 'A guide on Sinatra microframework'
    end
    def rspec_book
      Product.create name: 'RSpec Book', price: 15.0, status: 1,
                     description: 'RSpec testing framework handbook'
    end
    def order
      return @order if @order
      @order = Order.new customer: customer
      @order.save
      @order.add_order_line(product: sinatra_book, qty: 1)
      @order.add_order_line(product: rspec_book, qty: 2)
      @order
    end

    before(:all) { order }

    it 'generates number' do
      expect(order.number).to match(/^[A-Z][0-9]+$/)
    end

    it 'saves current date' do
      expect(order.date).to eq(Time.now.to_date)
    end

    it 'calculates total' do
      expect(order.total).to eq(10 + 15 * 2)
    end
  end
end
