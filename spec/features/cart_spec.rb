feature 'cart' do
  before(:all) do
    DB[:products].delete
    @products = Hash[{
        austen: ['Pride and Prejudice',   9.99,  'Jane Austen\'s classic'],
        lee:    ['To Kill a Mockingbird', 19.00, 'Harper Lee\'s classic'],
        fitz:   ['The Great Gatsby',      29.00, 'F. Scott Fitzgerald\'s classic'],
        orwell: ['1984',                  19.84, 'George Orwell\'s classic'],
        stein:  ['Of Mice and Men',       10.00, 'John Steinbeck\'s classic'],
      }.map do |key, attrs|
        [
          key,
          Product.create(name: attrs[0], price: attrs[1], status: 1,
                         description: attrs[2])
        ]
      end]
  end

  before { visit '/' }

  def add_product_to_cart(name)
    find('h2', text: name).first(:xpath, '../..').find_button('Add to cart').click
  end

  scenario 'adds product to cart' do
    add_product_to_cart('Pride and Prejudice')
    expect(page).to have_content('Pride and Prejudice was added to cart')
    expect(page).to have_link('Cart (1): 9.99 USD')
  end

  scenario 'adds several products to cart across session' do
    add_product_to_cart('Pride and Prejudice')
    add_product_to_cart('Pride and Prejudice')
    add_product_to_cart('Of Mice and Men')
    add_product_to_cart('1984')
    expect(page).to have_link('Cart (4): 49.82 USD')
  end

  scenario 'updates cart' do
    ['Of Mice and Men', '1984', 'The Great Gatsby']
      .each(&method(:add_product_to_cart))
    find('.cart').click
    expect(page).to have_content('Total: 58.84 USD')
    fill_in("items[#{@products[:stein].id}]", with: '2')
    click_button('Update cart')
    expect(page).to have_content('Your cart was updated')
    expect(page).to have_content('Total: 68.84 USD')
    expect(find("#line_#{@products[:stein].id} .total")).to have_text('20.0 USD')
    expect(page).to have_selector("input[name='items[#{@products[:stein].id}]'][value='2']")
    find("#line_#{@products[:stein].id} .remove").click
    expect(page).to have_content('Item removed')
    expect(page).to have_content('Total: 48.84 USD')
    expect(page).not_to have_css("#line_#{@products[:stein].id}")
  end
end
