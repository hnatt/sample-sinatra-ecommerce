feature 'log in' do
  context 'registered customer' do
    before do
      DB[:customers].delete
    end

    let!(:customer) do
      Customer.create firstname: 'John',
                      lastname: 'Connor',
                      email: 'jconnor@aol.com',
                      password: 'bananas'
    end

    def log_in(email = 'jconnor@aol.com', password = 'bananas')
      visit '/'
      click_link 'Sign in'
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    scenario 'logs in' do
      log_in
      expect(page.status_code).to eq(200)
      expect(current_path).to eq('/')
      expect(page).to have_content('John Connor')
      expect(page).not_to have_link('Sign in')
    end

    scenario 'tries to log in with incorrect credentials' do
      log_in('jconnor@aol.com', 'pineapples')
      expect(page).to have_content('Incorrect email or password')
      expect(page).not_to have_link('John Connor')
    end

    scenario 'logs out' do
      log_in
      click_button 'Sign out'
      expect(page).not_to have_text('John Connor')
      expect(page).to have_text('You have signed out')
    end
  end
end
