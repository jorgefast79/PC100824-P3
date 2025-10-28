-- db/migrations/001_create_migrations_table.sql
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    filename TEXT UNIQUE NOT NULL,
    run_at TIMESTAMP DEFAULT now()
);
