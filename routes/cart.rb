module Cart
  def self.registered(app)
    app.helpers Cart::Methods

    app.patch '/cart' do
      checkout and return if params[:checkout]
      cart.items = params[:items]
      session[:cart] = cart.items
      update_session_cart
      flash[:success] = 'Your cart was updated'
      redirect to('/cart')
    end

    app.post '/cart' do
      product = Product.find(id: params[:product_id])
      cart.add(product.id)
      session[:cart] = cart.items
      update_session_cart
      flash[:success] = "#{product.name} was added to cart"
      redirect back
    end

    app.delete '/cart/items/:id' do
      return if cart_item_delete_success(params[:id].to_i)
      flash[:error] = 'Cart item not found'
      redirect to('/cart')
    end

    app.get '/cart' do
      slim :'cart/cart'
    end
  end

  module Methods
    def cart
      @cart ||= ShoppingCart.new(session[:cart], Product)
    end

    def cart_text
      return 'Cart (empty)' if cart.total_quantity == 0
      "Cart (#{cart.total_quantity}): #{money(cart.total_price)}"
    end

    # Formats BigDecimal as money
    def money(amount)
      BigDecimal.new(amount).to_s('F') + ' USD'
    end

    def update_session_cart
      session[:cart] = cart.items
    end

    def cart_item_delete_success(product_id)
      return false unless cart.delete(product_id)
      update_session_cart
      flash[:success] = 'Item removed'
      redirect to('/cart')
    end
  end
end

Ecommerce.register Cart

