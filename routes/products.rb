module Products
  PRODUCTS_PER_PAGE = 10

  def self.registered(app)
    app.helpers Products::Methods

    app.get '/' do
      params[:page] ||= 1
      @products = Product.order(:id).extension(:pagination)
                         .paginate(params[:page].to_i, PRODUCTS_PER_PAGE)
      status 404 if @products.current_page > @products.page_count
      slim :'products/index'
    end

    app.patch '/products/:id' do
      @product = Product.find(id: params[:id])
      product_assign_from_params(@product)
      return if product_not_found(@product)
      return if product_invalid(@product)
      @product.save
      flash[:success] = "Product #{@product.name} updated"
      redirect to('/')
    end

    app.get '/products/:id/edit' do
      @product = Product.find(id: params[:id])
      return if product_not_found(@product)
      slim :'products/edit'
    end

    app.get '/products/new' do
      @product = Product.new
      slim :'products/new'
    end

    app.post '/products' do
      @product = Product.new
      product_assign_from_params(@product)
      return if product_invalid(@product)
      @product.save
      flash[:success] = "Product #{@product.name} created"
      redirect to('/')
    end
  end

  module Methods
    def product_assign_from_params(product)
      params[:product] && params[:product][:price] = params[:product][:price].gsub(',', '')
      product.set_only(params[:product], :name, :price, :status, :description)
    end

    def product_not_found(product)
      return false if product
      render_error(404, 'Product not found')
    end

    def product_invalid(product)
      return false if product.valid?
      halt slim(product.id ? :'products/edit' : :'products/new')
    end
  end
end

Ecommerce.register Products

