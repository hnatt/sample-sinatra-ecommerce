feature 'register' do
  before do
    visit '/'
    click_link 'Register'
  end

  it 'registers a new customer' do
    fill_in 'customer[firstname]',   with: 'Bart'
    fill_in 'customer[lastname]',    with: 'Simpson'
    fill_in 'customer[email]',       with: 'bsimpson@yahoo.com'
    fill_in 'customer[password]',    with: 'bitemyshorts'
    fill_in 'password_confirmation', with: 'bitemyshorts'
    click_button 'Register'
    expect(page).to have_content('Congratulations! You are a registered customer now')
    expect(page).to have_content('Bart Simpson')
  end

  context 'validates' do
    context 'presence' do
      subject do
        click_button 'Register'
        page
      end
      it { is_expected.to have_text 'First Name is not present' }
      it { is_expected.to have_text 'Last Name is not present' }
      it { is_expected.to have_text 'Email is not present' }
      it { is_expected.to have_text 'Password is not present' }
    end

    context 'format' do
      subject do
        fill_in 'customer[email]',    with: 'yahoo.com'
        fill_in 'customer[password]', with: 'short'
        click_button 'Register'
        page
      end
      it { is_expected.to have_text 'Email does not appear to be valid' }
      it { is_expected.to have_text 'Password is shorter than 7 characters' }
    end

    context 'email uniqueness' do
      before do
        Customer.create firstname: 'Tom', lastname: 'Sawyer',
                        email: 'tsawyer@aol.com', password: 'deadcat'
      end
      subject do
        fill_in 'customer[email]', with: 'tsawyer@aol.com'
        click_button 'Register'
        page
      end
      it { is_expected.to have_text 'Email is already taken' }
    end

    context 'password confirmation' do
      subject do
        fill_in 'customer[firstname]',   with: 'Nicholas'
        fill_in 'customer[lastname]',    with: 'Cage'
        fill_in 'customer[email]',       with: 'ncage@yahoo.com'
        fill_in 'customer[password]',    with: 'secret!'
        fill_in 'password_confirmation', with: 'secret'
        click_button 'Register'
        page
      end
      it { is_expected.to have_text 'Password confirmation does not match' }
    end
  end
end
