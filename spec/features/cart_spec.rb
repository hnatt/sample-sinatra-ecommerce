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

  def add_product_to_cart(key)
    find('h2', text: @products[key].name).first(:xpath, '../..')
                                         .find_button('Add to cart').click
  end

  scenario 'adds product to cart' do
    add_product_to_cart(:austen)
    expect(page).to have_content('Pride and Prejudice was added to cart')
    expect(page).to have_link('Cart (1): $9.99')
  end

  scenario 'adds several products to cart across session' do
    [:austen, :austen, :stein, :orwell].each(&method(:add_product_to_cart))
    expect(page).to have_link('Cart (4): $49.82')
  end

  scenario 'updates cart' do
    [:stein, :orwell, :fitz].each(&method(:add_product_to_cart))
    find('.cart').click
    expect(page).to have_content('Total: $58.84')
    fill_in("items[#{@products[:stein].id}]", with: '2')
    click_button('Update cart')
    expect(page).to have_content('Your cart was updated')
    expect(page).to have_content('Total: $68.84')
    expect(find("#line_#{@products[:stein].id} .total")).to have_text('$20.00')
    expect(page).to have_selector("input[name='items[#{@products[:stein].id}]'][value='2']")
    find("#line_#{@products[:stein].id} .remove").click
    expect(page).to have_content('Item removed')
    expect(page).to have_content('Total: $48.84')
    expect(page).not_to have_css("#line_#{@products[:stein].id}")
  end

  context 'checkout' do
    scenario 'guest user cannot checkout' do
      add_product_to_cart(:lee)
      find('.cart').click
      expect(page).not_to have_selector('button[name=checkout]')
    end

    context 'registered customer' do
      let(:customer) do
        Customer.create first_name: 'Moby', last_name: 'Dick',
                        email: 'mdick@oce.an', password: 'ammamammal'
      end

      after { [:order_lines, :orders, :customers].each { |tbl| DB[tbl].delete } }

      def log_in(email, password)
        visit '/customers/login'
        fill_in 'Email', with: email
        fill_in 'Password', with: password
        click_button 'Sign in'
      end

      scenario 'checks out' do
        add_product_to_cart(:lee)
        log_in(customer.email, 'ammamammal')
        find('.cart').click
        expect(page).to have_selector('button[name=checkout]')
        expect { click_button 'Checkout' }.to change(Order, :count)
        expect(page).to have_content('Thank you for your order!')
        expect(page).to have_content('Total: $19.00')
        visit '/'
        expect(find('.cart')).to have_content('Cart (empty)')
      end

      scenario 'cannot checkout after his session expires' do
        add_product_to_cart(:lee)
        log_in(customer.email, 'ammamammal')
        find('.cart').click
        customer.delete
        expect { click_button 'Checkout' }.not_to change(Order, :count)
        expect(page).to have_content('Sign in or register to checkout')
      end
    end
  end
end
