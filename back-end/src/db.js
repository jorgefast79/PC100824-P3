// src/db.js
import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config(); // 🔹 DEBE ir primero

const { Pool } = pg;

// Validar variables de entorno
const requiredEnv = ['DB_USER', 'DB_PASSWORD', 'DB_NAME', 'DB_HOST', 'DB_PORT'];
for (const key of requiredEnv) {
  if (!process.env[key]) {
    throw new Error(`Missing database environment variable: ${key}`);
  }
}

// Crear pool
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: Number(process.env.DB_PORT),
});

// Manejar errores globales del pool
pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Exportar funciones de uso
export const query = (text, params) => pool.query(text, params);
export const getClient = () => pool.connect();
