class User < ApplicationRecord
  include ValidateConcern
  validates :name, :email, presence: true
  has_secure_password
  before_validation :auto_fill_password
  def auto_fill_password
    if Rails.env.development? && password_digest.nil?
      self.password = '111111'
      self.password_confirmation = '111111'
    end
  end
end
