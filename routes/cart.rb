module Cart
  def self.registered(app)
    app.helpers Cart::Methods
    app.post '/cart' do
      product = Product.find(id: params[:product_id])
      cart.add(product.id)
      session[:cart] = cart.items
      flash[:success] = "#{product.name} was added to cart"
      redirect back
    end
  end

  module Methods
    def cart
      @cart ||= ShoppingCart.new(session[:cart], Product)
    end

    def cart_text
      return 'Cart (empty)' if cart.total_quantity == 0
      "Cart (#{cart.total_quantity}): #{cart.total_price.to_s('F')} USD"
    end
  end
end

Ecommerce.register Cart

