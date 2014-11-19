describe Product do
  context 'validates' do
    context 'required fields' do
      let(:product) { Product.new }
      it do
        expect(product.valid?).to be(false)
        expect(product.errors.keys).to \
          contain_exactly(:name, :price, :description, :status)
      end
    end

    context 'status' do
      let(:product) { Product.new status: 10 }
      it do
        expect(product.valid?).to be(false)
        expect(product.errors.keys).to include(:status)
      end
    end

    context 'price' do
      let(:product) { Product.new }
      it 'must be decimal' do
        product.price = 'free of charge'
        expect(product.valid?).to be(false)
        expect(product.errors.keys).to include(:price)
      end

      it 'must be >= 0' do
        product.price = -10
        expect(product.valid?).to be(false)
        expect(product.errors.keys).to include(:price)
      end
    end
  end

  context 'persists' do
    let(:product) do
      Product.new name: 'Higgs Boson',
                  price: 99.99,
                  status: 1,
                  description: 'So small!'
    end

    it do
      expect { product.save }.to change(Product, :count)
      expect(product.id).not_to be(nil)
    end
  end
end
