describe Customer do
  context 'validates' do
    context 'required fields' do
      let(:customer) { Customer.new }
      it do
        expect(customer.valid?).to be(false)
        expect(customer.errors.keys).to contain_exactly(:first_name, :last_name,
                                                        :email, :password)
      end
    end

    context 'email' do
      context 'validness' do
        let(:customer) { Customer.new email: 'what is email?' }
        it 'validness' do
          expect(customer.valid?).to be(false)
          expect(customer.errors.keys).to include(:email)
        end
      end

      context 'uniqueness' do
        let!(:spongebob) do
          Customer.create first_name: 'Bob',
                          last_name: 'Squarepants',
                          email: 'bob@example.com',
                          password: 'shellfish'
        end
        let(:bobross) do
          Customer.new first_name: 'Bob',
                       last_name: 'Ross',
                       email: 'bob@example.com',
                       password: 'happyacc1dents'
        end
        it do
          expect(bobross.valid?).to be(false)
          expect(bobross.errors.keys).to include(:email)
        end
      end
    end

    context 'password' do
      let(:customer) { Customer.new password: 'short' }
      it do
        expect(customer.valid?).to be(false)
        expect(customer.errors.keys).to include(:password)
      end
    end
  end

  context 'persists' do
    let(:customer) do
      Customer.new first_name: 'Snorri',
                   last_name: 'Sturluson',
                   email: 'ssturluson@althing.gov.is',
                   password: 'futhark!#1179$'
    end

    it do
      expect { customer.save }.to change(Customer, :count)
      expect(customer.id).not_to be(nil)
    end
  end

  context 'password' do
    def john
      @john ||= Customer.create first_name: 'John',
                                last_name: 'Doe',
                                email: 'john@doe-family.com',
                                password: 'pirates!'
    end
    def jane
      @jane ||= Customer.create first_name: 'Jane',
                                last_name: 'Doe',
                                email: 'jane@doe-family.com',
                                password: 'pirates!'
    end

    before(:all) { jane; john } # to memoize them in the group

    it 'has different salt for each record' do
      expect(john.password).not_to eq(jane.password)
    end

    it 'is encrypted' do
      expect(john.password).not_to match('pirates!')
    end

    it 'checks for correct' do
      expect(john.check_password('pirates!')).to be(true)
    end

    it 'checks for incorrect' do
      expect(john.check_password('pirates')).to be(false)
    end

    it 'is not changed on record update' do
      old_value = john.password
      john.update(first_name: 'Johnny')
      expect(john.password).to eq(old_value)
    end
  end
end
