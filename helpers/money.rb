require 'money'

Money.use_i18n = false
I18n.enforce_available_locales = false

module MoneyHelper
  def money(amount)
    Money.new(BigDecimal.new(amount * 100), 'USD').format
  end
end
