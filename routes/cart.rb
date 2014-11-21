module Cart
  def self.registered(app)
    app.helpers Cart::Methods

    app.patch '/cart' do
      cart.items = params[:items]
      checkout and return if params[:checkout]
      session[:cart] = cart.items
      update_session_cart
      flash[:success] = 'Your cart was updated'
      redirect to('/cart')
    end

    app.post '/cart' do
      product = Product.find(id: params[:product_id])
      return if product_disabled(product)
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

    def update_session_cart
      session[:cart] = cart.items
    end

    def cart_item_delete_success(product_id)
      return false unless cart.delete(product_id)
      update_session_cart
      flash[:success] = 'Item removed'
      redirect to('/cart')
    end

    def checkout
      return if checkout_failure
      order = Order.create customer: current_customer
      cart.items_table.each do |line|
        order.add_order_line(OrderLine.new(product: line[:product],
                                           qty: line[:qty]))
      end
      cart.clear
      update_session_cart
      flash[:success] = 'Thank you for your order!'
      redirect to("/orders/#{order.number}")
    end

    def checkout_failure
      return true if checkout_authorization_failure
      return true if checkout_products_failure
      false
    end

    def checkout_authorization_failure
      return false if current_customer
      flash[:error] = 'Sign in or register to checkout'
      redirect to('/customers/login')
      true
    end

    def checkout_products_failure
      return false if cart.total_quantity > 0
      flash[:error] = 'Your cart is empty'
      redirect to('/')
      true
    end

    def product_disabled(product)
      return false if product.status == 1
      flash[:error] = "Product #{product.name} is disabled"
      redirect back
      true
    end
  end
end

Ecommerce.register Cart

