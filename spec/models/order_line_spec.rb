describe OrderLine do
  context 'validates' do
    context 'required fields' do
      let(:order_line) { OrderLine.new }
      it do
        expect(order_line.valid?).to be(false)
        expect(order_line.errors.keys).to contain_exactly(:product, :qty)
      end
    end

    context 'field types' do
      let(:order_line) do
        OrderLine.new qty: 'too many',
                      unit_price: 'cheap',
                      total_price: 'even cheaper'
      end
      it do
        expect(order_line.valid?).to be(false)
        expect(order_line.errors.keys).to include(:qty, :unit_price, :total_price)
      end
    end

    context 'values' do
      let(:order_line) do
        OrderLine.new qty: -1,
                      unit_price: -9.99,
                      total_price: -100
      end
      it do
        expect(order_line.valid?).to be(false)
        expect(order_line.errors.keys).to include(:qty, :unit_price, :total_price)
      end
    end
  end

  context 'fills price and total' do
    let(:product) do
      Product.create name: 'Higgs Boson', price: 20.99, status: 1,
                     description: 'Best money can get'
    end
    let(:order_line) do
      OrderLine.create product: product, qty: 2
    end
    it do
      expect(order_line.unit_price).to eq(20.99)
      expect(order_line.total_price).to eq(41.98)
    end
  end
end
