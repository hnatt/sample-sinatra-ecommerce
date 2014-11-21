require 'validates_email_format_of'
require 'bcrypt'
require 'securerandom'

class Customer < Sequel::Model
  plugin :validation_helpers
  def validate
    validates_presence [:first_name, :last_name, :email, :password]
    validates_min_length 7, :password
    validates_unique :email
    email_errors = ValidatesEmailFormatOf::validate_email_format(email)
    email_errors.each { |e| errors.add(:email, e) } if email_errors
  end

  def before_create
    salt = SecureRandom.base64(12)
    self.password = salt + ':' + BCrypt::Password.create(salt + self.password)
  end

  def check_password(password)
    salt, encrypted_password = self.password.split(':')
    BCrypt::Password.new(encrypted_password) == salt + password
  end

  def full_name
    first_name + ' ' + last_name
  end
end
