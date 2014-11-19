module Customers
  def self.registered(app)
    app.helpers Customers::Methods

    app.get '/customers/login' do
      @customer = Customer.new
      slim :'customers/login'
    end

    app.post '/customers/login' do
      customer = Customer.find(email: params[:email])
      return if sign_in_success(customer, params[:password])
      sign_in_failure
    end

    app.post '/customers/logout' do
      session.delete(:customer_id)
      flash[:success] = 'You have signed out'
      redirect back
    end

    app.get '/customers/register' do
      @customer = Customer.new
      slim :'customers/register'
    end

    app.post '/customers/register' do
      @customer = Customer.new params[:customer] if params[:customer]
      return if register_success(@customer, params[:password_confirmation])
      slim :'customers/register'
    end
  end

  module Methods
    def current_customer
      return nil unless session[:customer_id]
      @current_customer ||= Customer.find(id: session[:customer_id])
    end

    def sign_in_success(customer, password)
      return false unless customer && customer.check_password(password)
      flash[:success] = 'You have signed in'
      session[:customer_id] = customer.id
      redirect to('/')
    end

    def sign_in_failure
      flash[:error] = 'Incorrect email or password'
      redirect to('/customers/login')
    end

    def register_success(customer, password_confirmation)
      valid = customer.valid?
      if password_confirmation != customer.password
        customer.errors.add(:password_confirmation, 'does not match')
        valid = false
      end
      return false unless valid
      customer.save
      session[:customer_id] = customer.id
      flash[:success] = 'Congratulations! You are a registered customer now'
      redirect to('/')
    end
  end
end

Ecommerce.register Customers
