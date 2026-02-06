# README

## Tech assumptions
- Ruby on Rails 8 (API-only)
- PostgreSQL
- ActiveJob for reminders
- ActionMailer for emails
- RSpec (request specs)
- Docker & docker-compose

## Domain model
### Entities
- Book
- Reader
- Borrowing (join model, keeps full history)
### Relationships
- Book has many borrowings
- Reader has many borrowings
- A book is currently borrowed if it has an open borrowing (no returned_at)

## API behavior summary
✔ Add / delete books

✔ List all books with availability status

✔ View book details with full borrowing history
 
✔ Borrow / return books 

✔ Automatic due-date tracking (30 days)

✔ Email reminders at T-3 days and T-0

## API
1️⃣ Add a new book
```bash
POST /api/books
```
```json
{
  "book": {
    "serial_number": "123456",
    "title": "The Pragmatic Programmer",
    "author": "Andrew Hunt"
  }
}
```

2️⃣ Delete a book
```bash
DELETE /api/books/:id
```

3️⃣ List all books with availability
```bash
GET /api/books
```
```json
[
  {
    "serial_number": "123456",
    "title": "The Pragmatic Programmer",
    "author": "Andrew Hunt",
    "status": "available"
  }
]
```

4️⃣ Get book details + borrowing history
```bash
GET /api/books/:id
```
```json
{
  "serial_number": "123456",
  "title": "The Pragmatic Programmer",
  "author": "Andrew Hunt",
  "borrowings": [
    {
      "borrowed_at": "2026-01-01T10:00:00Z",
      "returned_at": "2026-01-20T12:00:00Z",
      "reader": {
        "card_number": "654321",
        "full_name": "Jane Doe",
        "email": "jane@example.com"
      }
    }
  ]
}
```

5️⃣ Borrow a book
```bash
POST /api/books/:id/borrow
```
```json
{
  "card_number": "654321"
}
```

6️⃣ Return a book
```bash
POST /api/books/:id/return
```

## Getting Started

### Run the applicationn
```bash
docker compose build
docker compose run web bin/rails db:prepare
docker compose up
```
The API will be available at:
```
http://localhost:3000
```

### Testing
```bash
docker compose run web bin/rails spec
```

### Seed Data
To load sample data (books, readers, borrowings):
```bash
docker compose run web bin/rails db:seed
```

## Possible Improvements
- Pagination and filtering for book listings
- Soft deletes for books
- API documentation (OpenAPI / Swagger)
- Reader management endpoints
- Convert responses to JSON:API