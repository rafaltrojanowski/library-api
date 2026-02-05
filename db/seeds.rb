# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding data..."

# ---- Readers ----
readers = [
  {
    card_number: "100001",
    full_name: "Alice Johnson",
    email: "alice@example.com"
  },
  {
    card_number: "100002",
    full_name: "Bob Smith",
    email: "bob@example.com"
  },
  {
    card_number: "100003",
    full_name: "Charlie Brown",
    email: "charlie@example.com"
  }
]

readers.each do |attrs|
  Reader.find_or_create_by!(card_number: attrs[:card_number]) do |r|
    r.full_name = attrs[:full_name]
    r.email = attrs[:email]
  end
end

puts "Readers seeded: #{Reader.count}"

# ---- Books ----
books = [
  {
    serial_number: "200001",
    title: "Clean Code",
    author: "Robert C. Martin"
  },
  {
    serial_number: "200002",
    title: "The Pragmatic Programmer",
    author: "Andrew Hunt"
  },
  {
    serial_number: "200003",
    title: "Refactoring",
    author: "Martin Fowler"
  },
  {
    serial_number: "200004",
    title: "Design Patterns",
    author: "Erich Gamma et al."
  }
]

books.each do |attrs|
  Book.find_or_create_by!(serial_number: attrs[:serial_number]) do |b|
    b.title = attrs[:title]
    b.author = attrs[:author]
  end
end

puts "Books seeded: #{Book.count}"

# ---- Borrowing history ----
alice = Reader.find_by(card_number: "100001")
bob   = Reader.find_by(card_number: "100002")

clean_code = Book.find_by(serial_number: "200001")
pragmatic  = Book.find_by(serial_number: "200002")

# Returned borrowing
if clean_code.borrowings.empty?
  clean_code.borrowings.create!(
    reader: alice,
    borrowed_at: 45.days.ago,
    due_at: 15.days.ago,
    returned_at: 10.days.ago
  )
end

# Currently borrowed book
unless pragmatic.borrowed?
  pragmatic.borrowings.create!(
    reader: bob,
    borrowed_at: 5.days.ago,
    due_at: 25.days.from_now
  )
end

puts "Borrowings seeded: #{Borrowing.count}"

puts "Seeding completed successfully."
