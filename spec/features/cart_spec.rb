feature 'cart' do
  before(:all) do
    DB[:products].delete
    @products = [
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

  def add_product_to_cart(name)
    find('h2', text: name).first(:xpath, '../..').find_button('Add to cart').click
  end

  scenario 'adds product to cart' do
    visit '/'
    add_product_to_cart('Pride and Prejudice')
    expect(page).to have_content('Pride and Prejudice was added to cart')
    expect(page).to have_link('Cart (1): 9.99 USD')
  end

  scenario 'adds several products to cart across session' do
    visit '/'
    add_product_to_cart('Pride and Prejudice')
    add_product_to_cart('Pride and Prejudice')
    add_product_to_cart('Of Mice and Men')
    add_product_to_cart('1984')

    expect(page).to have_link('Cart (4): 49.82 USD')
  end
end
