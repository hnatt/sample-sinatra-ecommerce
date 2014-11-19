class Product < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:name, :price, :status, :description]
    validates_includes [0, 1], :status
    validates_numeric :price
    errors.add(:price, 'must be zero or greater') if price.to_f < 0
  end
end
