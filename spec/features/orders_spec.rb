feature 'orders' do
  before(:all) do
    DB[:products].delete
    @products = Hash[{
        austen: ['Pride and Prejudice',   9.99,  'Jane Austen\'s classic'],
        lee:    ['To Kill a Mockingbird', 19.00, 'Harper Lee\'s classic'],
        fitz:   ['The Great Gatsby',      29.00, 'F. Scott Fitzgerald\'s classic'],
      }.map do |key, attrs|
        [
          key,
          Product.create(name: attrs[0], price: attrs[1], status: 1,
                         description: attrs[2])
        ]
      end]
  end

  before { [:order_lines, :orders, :customers].each { |tbl| DB[tbl].delete } }

  def log_in(email, password)
    visit '/customers/login'
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_button 'Sign in'
  end

  let(:customer) do
    Customer.create firstname: 'Bosco', lastname: 'Baracus',
                    email: 'mrt@a-team.com', password: 'ipitythefool'
  end

  let(:other_customer) do
    Customer.create firstname: 'John', lastname: 'Smith',
                    email: 'hannibal@a-team.com', password: 'cigars!'
  end

  let(:order) do
    order = Order.create customer: customer
    order.add_order_line(product: @products[:austen], qty: 2)
    order.add_order_line(product: @products[:lee], qty: 1)
    order
  end

  let(:other_order) do
    order = Order.create customer: other_customer
    order.add_order_line(product: @products[:austen], qty: 2)
    order.add_order_line(product: @products[:fitz], qty: 1)
    order
  end

  scenario 'guest user cannot see an order' do
    visit "/orders/#{order.order_no}"
    expect(page.status_code).to eq(401)
    expect(page).to have_content('You are unauthorized to see this page')
  end

  context 'authorized customer' do
    before do
      log_in(customer.email, 'ipitythefool')
    end

    scenario 'can see his order' do
      visit "/orders/#{order.order_no}"
      expect(page).to have_content(order.order_no)
      expect(page).to have_content('Total: $38.98')
    end

    scenario 'sees 404 when order not found' do
      visit '/orders/DOESNTEXIST'
      expect(page.status_code).to be(404)
      expect(page).to have_content('Page not found')
    end

    scenario 'unauthorized to see other customers\'s order' do
      visit "/orders/#{other_order.order_no}"
      expect(page.status_code).to be(401)
      expect(page).to have_content('You are unauthorized to see this page')
    end
  end
end