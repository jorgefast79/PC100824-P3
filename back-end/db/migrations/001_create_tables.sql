CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TABLE users (
id SERIAL PRIMARY KEY,
email TEXT UNIQUE NOT NULL,
password_hash TEXT NOT NULL,
name TEXT,
created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);


CREATE TABLE cars (
id SERIAL PRIMARY KEY,
plate TEXT UNIQUE NOT NULL,
model TEXT NOT NULL,
brand TEXT,
seats INT DEFAULT 4,
price_per_day NUMERIC(10,2) NOT NULL,
is_active BOOLEAN DEFAULT true,
created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);


CREATE TABLE bookings (
id SERIAL PRIMARY KEY,
user_id INT REFERENCES users(id) ON DELETE CASCADE,
car_id INT REFERENCES cars(id) ON DELETE CASCADE,
start_date DATE NOT NULL,
end_date DATE NOT NULL,
total_amount NUMERIC(10,2) NOT NULL,
created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);


CREATE INDEX idx_bookings_car_dates ON bookings (car_id, start_date, end_date);