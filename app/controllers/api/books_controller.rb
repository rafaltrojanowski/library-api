class Api::BooksController < ApplicationController

  def index
    books = Book.all
    render json: books.map { |b|
      {
        id: b.id,
        serial_number: b.serial_number,
        title: b.title,
        author: b.author,
        status: b.borrowed? ? "borrowed" : "available"
      }
    }
  end

  def show
    book = Book.find(params[:id])

    render json: {
      id: book.id,
      serial_number: book.serial_number,
      title: book.title,
      author: book.author,
      borrowings: book.borrowings.order(borrowed_at: :desc).map { |br|
        {
          borrowed_at: br.borrowed_at,
          returned_at: br.returned_at,
          reader: {
            card_number: br.reader.card_number,
            full_name: br.reader.full_name,
            email: br.reader.email
          }
        }
      }
    }
  end

  def create
    book = Book.create!(book_params)
    render json: book, status: :created
  end

  def destroy
    Book.find(params[:id]).destroy
    head :no_content
  end

  def borrow
    book = Book.find(params[:id])
    raise "Book already borrowed" if book.borrowed?

    reader = Reader.find_by!(card_number: params[:card_number])

    borrowing = book.borrowings.create!(
      reader: reader,
      borrowed_at: Time.current,
      due_at: 30.days.from_now
    )

    BorrowingReminderJob.schedule(borrowing)

    render json: { status: "borrowed", due_at: borrowing.due_at }
  end

  def return
    book = Book.find(params[:id])
    borrowing = book.current_borrowing

    borrowing.update!(returned_at: Time.current)
    render json: { status: "available" }
  end

  private

  def book_params
    params.require(:book).permit(:serial_number, :title, :author)
  end
end
