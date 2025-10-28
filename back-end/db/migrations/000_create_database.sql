-- db/migrations/000_create_database.sql
-- Nota: solo crea la base de datos si no existe
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'rentacar') THEN
      PERFORM dblink_exec('dbname=postgres user=postgres password=Universo_800', 'CREATE DATABASE rentacar');
   END IF;
END
$$;
