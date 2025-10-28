import fs from 'fs';
import path from 'path';
import { pool } from './connection.js';

export async function runMigrations() {
  try {
    const sqlPath = path.resolve('db/migrations/script.sql');
    const sql = fs.readFileSync(sqlPath, 'utf-8');
    await pool.query(sql);
    console.log('✅ Migraciones ejecutadas correctamente');
  } catch (err) {
    console.error('❌ Error ejecutando migraciones:', err);
  }
}
