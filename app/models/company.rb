class Company < ActiveRecord::Base
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false}

  validates :location, presence: true, length:  { maximum: 20 }

  validates :size, presence: true, numericality: { only_integer: true }, inclusion: { in: 1..1000 }

  validates :description, presence: true

  has_secure_password
  validates :password, length: { minimum: 6 }
end
