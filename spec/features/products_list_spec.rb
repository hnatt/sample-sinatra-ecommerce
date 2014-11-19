feature 'products list' do
  before(:each) { DB[:products].delete }

  context 'shows products' do
    let!(:products) do
      [
        ['Pride and Prejudice',   9.99,  'Jane Austen\'s classic'],
        ['To Kill a Mockingbird', 19.00, 'Harper Lee\'s classic'],
        ['The Great Gatsby',      29.00, 'F. Scott Fitzgerald\'s classic'],
        ['1984',                  19.84, 'George Orwell\'s classic'],
        ['Of Mice and Men',       10.00, 'John Steinbeck\'s classic'],
      ].map do |attrs|
        Product.create name: attrs[0], price: attrs[1], description: attrs[2],
                       status: 1
      end
    end

    scenario do
      visit '/'
      expect(all('.product').length).to eq(products.length)
      products.each do |product|
        expect(page).to have_content(product.name)
        expect(page).to have_content(product.description)
        expect(page).to have_content(product.price.to_s('F'))
      end
    end
  end

  context 'paginates if there are too many products' do
    let!(:products) do
      (1..30).map do |i|
        Product.create name: "iPhone #{i}", price: 100 * i,
                       status: 1, description: 'Amazing product'
      end
    end

    scenario 'shows limited amount of products on first page' do
      visit '/'
      expect(all('.product h2').map(&:text)).to \
        eq(products.slice(0, 10).map(&:name))
      expect(page).to have_css('.pagination')
    end

    scenario 'shows different batch no next page' do
      visit '/'
      find('.pagination').find_link('2').click
      expect(all('.product h2').map(&:text)).to \
        eq(products.slice(10, 10).map(&:name))
    end
  end
end
