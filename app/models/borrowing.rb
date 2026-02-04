class Borrowing < ApplicationRecord
  belongs_to :book
  belongs_to :reader

  validates :borrowed_at, :due_at, presence: true
end