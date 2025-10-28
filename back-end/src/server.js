// src/server.js
import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { query, getClient } from './db.js';
import dotenv from 'dotenv';
import speakeasy from 'speakeasy';
import qrcode from 'qrcode';

dotenv.config();

const app = express();
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET || 'supersecret';

// ------------------- AUTH -------------------

// Registrar usuario con TOTP y generar QR
// Registrar usuario y generar TOTP + QR
app.post("/api/register", async (req, res) => {
  const { email, password, name } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email y contraseña son requeridos" });
  }

  try {
    // Verificar si el usuario ya existe
    const userCheck = await query("SELECT * FROM users WHERE email=$1", [email]);
    if (userCheck.rowCount > 0) {
      return res.status(400).json({ error: "El correo ya está registrado" });
    }

    // Hashear la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generar secreto TOTP
    const secret = speakeasy.generateSecret({
      name: `RentaCar (${email})`,
      length: 20,
    });

    // Guardar usuario en la DB
    const result = await query(
      "INSERT INTO users (email, password_hash, name, totp_secret, is_verified) VALUES ($1,$2,$3,$4,$5) RETURNING id,email,name",
      [email, hashedPassword, name || null, secret.base32, true] // true = usuario listo para login
    );

    const user = result.rows[0];

    // Generar QR para mostrar en el frontend
    const qrDataUrl = await qrcode.toDataURL(secret.otpauth_url);

    // Devolver respuesta al frontend
    res.status(201).json({
      success: true,
      message: "Usuario registrado. Escanea este QR con tu app de autenticación",
      userId: user.id,
      qrCode: qrDataUrl,
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error al registrar usuario" });
  }
});

// Login con TOTP
app.post("/api/login", async (req, res) => {
  const { email, password, otp } = req.body; // <-- aquí cambia
  try {
    const result = await query("SELECT * FROM users WHERE email=$1", [email]);
    const user = result.rows[0];
    if (!user) return res.status(401).json({ error: "Correo o contraseña incorrectos" });

    const passwordMatch = await bcrypt.compare(password, user.password_hash);
    if (!passwordMatch) return res.status(401).json({ error: "Correo o contraseña incorrectos" });

    if (!user.totp_secret) return res.status(403).json({ error: "Usuario no tiene TOTP configurado" });

    const verified = speakeasy.totp.verify({
      secret: user.totp_secret,
      encoding: "base32",
      token: otp, // <-- usar otp enviado desde el frontend
      window: 1,
    });

    if (!verified) return res.status(403).json({ error: "Código TOTP inválido o expirado" });

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: "1h" });

    res.json({ message: "Inicio de sesión exitoso", token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error al iniciar sesión" });
  }
});

// Middleware de auth
const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Missing authorization header' });

  const token = authHeader.split(' ')[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    next();
  } catch {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// ------------------- AUTOS -------------------

app.get('/api/cars', async (req, res) => {
  try {
    const result = await query('SELECT * FROM cars WHERE is_active=true ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch cars' });
  }
});

app.post('/api/cars', authMiddleware, async (req, res) => {
  const { plate, model, brand, seats, price_per_day } = req.body;
  if (!plate || !model || !price_per_day) return res.status(400).json({ error: 'Missing fields' });

  try {
    const result = await query(
      'INSERT INTO cars (plate, model, brand, seats, price_per_day) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [plate, model, brand || null, seats || 4, price_per_day]
    );
    res.status(201).json({ car: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create car' });
  }
});

// ------------------- RESERVAS -------------------

app.post('/api/bookings', authMiddleware, async (req, res) => {
  const { car_id, start_date, end_date } = req.body;
  const userId = req.user.id;
  if (!car_id || !start_date || !end_date) return res.status(400).json({ error: 'Missing fields' });

  const client = await getClient();
  try {
    await client.query('BEGIN');

    const carRes = await client.query('SELECT price_per_day FROM cars WHERE id=$1 AND is_active=true FOR UPDATE', [car_id]);
    if (carRes.rowCount === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Car not found or inactive' });
    }

    const overlap = await client.query(
      'SELECT 1 FROM bookings WHERE car_id=$1 AND NOT (end_date<$2 OR start_date>$3) LIMIT 1',
      [car_id, start_date, end_date]
    );
    if (overlap.rowCount > 0) {
      await client.query('ROLLBACK');
      return res.status(409).json({ error: 'Car already booked' });
    }

    const days = Math.max(1, Math.ceil((new Date(end_date) - new Date(start_date)) / (24*60*60*1000)) + 1);
    const total = (days * parseFloat(carRes.rows[0].price_per_day)).toFixed(2);

    const ins = await client.query(
      'INSERT INTO bookings (user_id, car_id, start_date, end_date, total_amount) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [userId, car_id, start_date, end_date, total]
    );

    await client.query('COMMIT');
    res.status(201).json({ booking: ins.rows[0] });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Failed to create booking' });
  } finally {
    client.release();
  }
});

app.get('/api/bookings', authMiddleware, async (req, res) => {
  const userId = req.user.id;
  try {
    const result = await query(
      'SELECT b.*, c.model, c.brand FROM bookings b JOIN cars c ON c.id=b.car_id WHERE b.user_id=$1 ORDER BY b.start_date DESC',
      [userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

// ------------------- SERVIDOR -------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));
