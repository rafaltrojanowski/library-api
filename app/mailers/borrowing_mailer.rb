class BorrowingMailer < ApplicationMailer
  def reminder(reader, book, due_at)
    payload = {
      to: reader.email,
      subject: "Reminder: return '#{book.title}'",
      due_at: due_at
    }

    Rails.logger.info("[EMAIL REMINDER] #{payload}")
  end
end
