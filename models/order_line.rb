class OrderLine < Sequel::Model
  many_to_one :order
  many_to_one :product
  plugin :validation_helpers
  def validate
    validates_presence [:product, :qty]
    validates_integer :qty
    validates_numeric [:unit_price, :total_price], allow_nil: true
    [:unit_price, :total_price, :qty].each do |field|
      errors.add(field, 'must be zero or greater') if self.send(field).to_f < 0
    end
  end

  def autofill
    self.unit_price ||= product.price
    self.total_price = self.unit_price * self.qty
  end

  def before_save
    autofill
  end
end
