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
end
