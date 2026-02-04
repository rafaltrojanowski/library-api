class Reader < ApplicationRecord
  has_many :borrowings

  validates :card_number, presence: true, length: { is: 6 }
  validates :email, presence: true, uniqueness: true
end