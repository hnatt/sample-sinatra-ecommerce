require 'money'

Money.use_i18n = false
I18n.enforce_available_locales = false

module MoneyHelper
  def money(amount, show_currency = true)
    Money.new(BigDecimal.new(amount || 0) * 100, 'USD').format(symbol: show_currency)
  end
end
