// src/migrate.js
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { Pool } from 'pg';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, '../.env') });

// --- Primero conectarse a la DB por defecto para crear 'rentacar' si no existe ---
const poolDefaultDB = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: 'postgres', // usar la DB por defecto
  password: process.env.DB_PASSWORD,
  port: Number(process.env.DB_PORT),
});

async function createDatabaseIfNotExists() {
  const dbName = process.env.DB_NAME;
  const result = await poolDefaultDB.query(
    `SELECT 1 FROM pg_database WHERE datname=$1`,
    [dbName]
  );
  if (result.rowCount === 0) {
    console.log(`Database "${dbName}" does not exist. Creating...`);
    await poolDefaultDB.query(`CREATE DATABASE ${dbName}`);
    console.log(`Database "${dbName}" created ✅`);
  } else {
    console.log(`Database "${dbName}" already exists`);
  }
  await poolDefaultDB.end();
}

// --- Pool conectado a la DB real ---
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: Number(process.env.DB_PORT),
});

async function runMigration(filePath) {
  const sql = fs.readFileSync(filePath, 'utf8');
  await pool.query(sql);
}

async function runAllMigrations() {
  const migrationsDir = path.resolve(__dirname, '../db/migrations');
  const files = fs.readdirSync(migrationsDir)
                  .filter(f => f.endsWith('.sql'))
                  .sort(); // ejecutar en orden

  for (const file of files) {
    // Verifica si ya se ejecutó
    const res = await pool.query(
      'SELECT 1 FROM migrations WHERE filename = $1',
      [file]
    ).catch(err => {
      if (file.startsWith('000')) return null; // primera migración crea tabla migrations
      throw err;
    });

    if (!res || res.rowCount === 0) {
      console.log('Running migration:', file);
      await runMigration(path.join(migrationsDir, file));
      if (!file.startsWith('000')) {
        await pool.query(
          'INSERT INTO migrations (filename) VALUES ($1)',
          [file]
        );
      }
      console.log('Migration completed ✅', file);
    } else {
      console.log('Skipping already executed migration:', file);
    }
  }

  await pool.end();
}

// --- Ejecutar ---
async function main() {
  await createDatabaseIfNotExists();
  await runAllMigrations();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
