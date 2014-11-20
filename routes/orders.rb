module Orders
  def self.registered(app)
    app.helpers Orders::Methods

    app.get '/orders/:number' do
      @order = Order.find(order_no: params[:number])
      return if order_not_found(@order)
      return if order_unauthorized(@order)
      slim :'orders/show'
    end
  end

  module Methods
    def order_unauthorized(order)
      return false if current_customer && current_customer == order.customer
      render_error 401, 'You are unauthorized to see this page'
    end

    def order_not_found(order)
      return false unless order.nil?
      render_error 404, 'Page not found'
    end
  end
end

Ecommerce.register Orders
