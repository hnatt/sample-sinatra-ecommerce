feature 'products management' do
  before do
    DB[:products].delete
  end

  let!(:products) do
    (1..8).map do |n|
      Product.create name: "iPhone #{n}", price: 100 * n, status: 1,
                     description: 'Amazing product'
    end
  end

  let(:test_data) do
    {
      'Name'        => 'iPhone X',
      'Price'       => '999.99',
      'Description' => 'Even amazinger product',
    }
  end

  def fill_with_test_data
    test_data.each { |k, v| fill_in k, with: v }
    find('option[value="0"]').click
  end

  def check_test_data
    test_data.values.each { |v| expect(page).to have_content(v) }
  end

  scenario 'edits product' do
    visit '/'
    find("a[href='/products/#{products[0].id}/edit']").click
    expect(page).to have_content('Editing iPhone 1')
    fill_with_test_data
    click_button 'Update'
    expect(page).to have_content('Product iPhone X updated')
    check_test_data
  end

  scenario 'product fields are validated' do
    visit '/'
    find("a[href='/products/#{products[0].id}/edit']").click
    fill_in 'Price', with: ''
    click_button 'Update'
    expect(page).to have_content('Price is not present')
    expect(current_path).to eq("/products/#{products[0].id}")
    fill_in 'Price', with: 'free'
    click_button 'Update'
    expect(page).to have_content('Price is not a number')
    expect(current_path).to eq("/products/#{products[0].id}")
  end

  scenario 'creates a new product' do
    visit '/'
    click_link 'New product'
    expect(page).to have_css('h1', text: 'New product')
    fill_with_test_data
    click_button 'Create'
    check_test_data
    expect(page).to have_content('Product iPhone X created')
  end

  scenario 'validates fields of new product' do
    visit '/'
    click_link 'New product'
    click_button 'Create'
    expect(page).to have_content('Name is not present')
    expect(page).to have_content('Price is not present')
    expect(page).to have_content('Description is not present')
  end

  scenario 'handles thousands in price well' do
    visit '/'
    click_link 'New product'
    fill_with_test_data
    fill_in 'Price', with: '1,000,999.00'
    click_button 'Create'
    expect(current_path).to eq('/')
    expect(page).to have_content('$1,000,999.00')
  end
end
