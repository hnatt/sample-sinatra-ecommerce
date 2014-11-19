class ShoppingCart
  attr_reader :items
  def initialize(items, product_model)
    @items = items || {}
    @product_model = product_model
  end

  def add(product_id)
    items[product_id] ||= 0
    items[product_id] += 1
  end

  def total_quantity
    items.values.reduce(0, :+)
  end

  def products(reload = true)
    @products = nil if reload
    @products ||= Hash[
      @product_model.where(id: items.keys).map do |product|
        [product.id, product]
      end
    ]
  end

  def total_price
    BigDecimal.new(
      items.map do |product_id, qty|
        products(false)[product_id].price * qty
      end.reduce(0, :+)
    )
  end
end
