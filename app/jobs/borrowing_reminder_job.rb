class BorrowingReminderJob < ApplicationJob
  queue_as :default

  def self.schedule(borrowing)
    set(wait_until: borrowing.due_at - 3.days)
      .perform_later(borrowing.id)

    set(wait_until: borrowing.due_at)
      .perform_later(borrowing.id)
  end

  def perform(borrowing_id)
    borrowing = Borrowing.find_by(id: borrowing_id)
    return if borrowing.nil? || borrowing.returned_at.present?

    BorrowingMailer.reminder(
      borrowing.reader,
      borrowing.book,
      borrowing.due_at
    ).deliver_now
  end
end
