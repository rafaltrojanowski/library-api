class Book < ApplicationRecord
  has_many :borrowings, dependent: :destroy

  validates :serial_number, presence: true, length: { is: 6 }
  validates :title, :author, presence: true

  def current_borrowing
    borrowings.find_by(returned_at: nil)
  end

  def borrowed?
    current_borrowing.present?
  end
end