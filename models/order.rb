class Order < Sequel::Model
  many_to_one :customer
  one_to_many :order_lines

  ORDER_NUMBER_PREFIX = 'O'

  plugin :validation_helpers
  def validate
    validates_presence :customer
  end

  def generate_order_number
    number = loop do
      random = ORDER_NUMBER_PREFIX +
        (0...10).map { Random.rand(10) }.join
      break random if self.class.where(number: random).count == 0
    end
  end

  def before_create
    self.number = generate_order_number
    self.date = Time.now
  end


  def before_save
    self.total = self.order_lines.reduce(0) do |sum, line|
      line.autofill if line.id.nil?
      sum + line.total_price
    end
  end

  def add_order_line(*args)
    result = super
    save
    result
  end
end
