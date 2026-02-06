require 'rails_helper'

RSpec.describe "Books API", type: :request do
  let!(:reader) do
    Reader.create!(
      card_number: "654321",
      full_name: "Jane Doe",
      email: "jane@example.com"
    )
  end

  describe "POST /api/books" do
    it "creates a new book" do
      expect {
        post "/api/books", params: {
          book: {
            serial_number: "123456",
            title: "Clean Code",
            author: "Robert C. Martin"
          }
        }
      }.to change(Book, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe "GET /api/books" do
    let!(:book) do
      Book.create!(
        serial_number: "111111",
        title: "Refactoring",
        author: "Martin Fowler"
      )
    end

    it "returns all books with availability status" do
      get "/api/books"

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json.last).to include(
        "serial_number" => "111111",
        "status" => "available"
      )
    end
  end

  describe "DELETE /api/books/:id" do
    let!(:book) do
      Book.create!(
        serial_number: "222222",
        title: "DDD",
        author: "Eric Evans"
      )
    end

    it "deletes the book" do
      expect {
        delete "/api/books/#{book.id}"
      }.to change(Book, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/books/:id/borrow" do
    let!(:book) do
      Book.create!(
        serial_number: "333333",
        title: "Rails Way",
        author: "Obie Fernandez"
      )
    end

    it "borrows a book for a reader" do
      post "/api/books/#{book.id}/borrow", params: {
        card_number: reader.card_number
      }

      book.reload

      expect(response).to have_http_status(:ok)
      expect(book.borrowed?).to be(true)

      borrowing = book.current_borrowing
      expect(borrowing.reader).to eq(reader)
      expect(borrowing.due_at.to_date).to eq(30.days.from_now.to_date)
    end

    it "prevents borrowing an already borrowed book" do
      post "/api/books/#{book.id}/borrow", params: {
        card_number: reader.card_number
      }

      expect {
        post "/api/books/#{book.id}/borrow", params: {
          card_number: reader.card_number
        }
      }.to raise_error(RuntimeError, "Book already borrowed")
    end
  end

  describe "POST /api/books/:id/return" do
    let!(:book) do
      Book.create!(
        serial_number: "444444",
        title: "Eloquent Ruby",
        author: "Russ Olsen"
      )
    end

    before do
      book.borrowings.create!(
        reader: reader,
        borrowed_at: Time.current,
        due_at: 30.days.from_now
      )
    end

    it "returns a borrowed book" do
      post "/api/books/#{book.id}/return"

      book.reload

      expect(response).to have_http_status(:ok)
      expect(book.borrowed?).to be(false)
      expect(book.borrowings.last.returned_at).not_to be_nil
    end
  end

  describe "GET /api/books/:id" do
    let!(:book) do
      Book.create!(
        serial_number: "555555",
        title: "Design Patterns",
        author: "GoF"
      )
    end

    before do
      book.borrowings.create!(
        reader: reader,
        borrowed_at: 40.days.ago,
        due_at: 10.days.ago,
        returned_at: 5.days.ago
      )
    end

    it "returns book details with borrowing history" do
      get "/api/books/#{book.id}"

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["serial_number"]).to eq("555555")
      expect(json["borrowings"].length).to eq(1)

      borrowing = json["borrowings"].first
      expect(borrowing["reader"]["email"]).to eq("jane@example.com")
      expect(borrowing["returned_at"]).not_to be_nil
    end
  end
end
