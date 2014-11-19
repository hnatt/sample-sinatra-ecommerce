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
  end

  module Methods
  end
end

Ecommerce.register Products

