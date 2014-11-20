class ShoppingCart
  attr_reader :items
  def initialize(items, product_model)
    @items = items || {}
    @product_model = product_model
  end

  def add(product_id)
    flush
    items[product_id] ||= 0
    items[product_id] += 1
  end

  def delete(product_id)
    flush
    items.delete(product_id)
  end

  def items=(new_items)
    flush
    @items = Hash[
      new_items.map { |pair| pair.map(&:to_i) }
    ]
  end

  def total_quantity
    items.values.reduce(0, :+)
  end

  def total_price
    BigDecimal.new(
      items.map do |product_id, qty|
        products[product_id].price * qty
      end.reduce(0, :+)
    )
  end

  def items_table
    items.map do |product_id, qty|
      {
        product: products[product_id],
        qty: qty,
        total: qty * products[product_id].price,
      }
    end
  end

  private

  def products
    @products ||= Hash[
      @product_model.where(id: items.keys).map do |product|
        [product.id, product]
      end
    ]
  end

  def flush
    @products = nil
  end
end
