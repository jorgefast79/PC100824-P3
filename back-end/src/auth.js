// src/auth.js
const jwt = require('jsonwebtoken');
require('dotenv').config();


function generateToken(user) {
const payload = { id: user.id, email: user.email };
return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
}


function authMiddleware(req, res, next) {
const auth = req.headers.authorization;
if (!auth) return res.status(401).json({ error: 'No token' });
const parts = auth.split(' ');
if (parts.length !== 2) return res.status(401).json({ error: 'Bad auth header' });
const token = parts[1];
try {
const decoded = jwt.verify(token, process.env.JWT_SECRET);
req.user = decoded;
next();
} catch (e) {
return res.status(401).json({ error: 'Invalid token' });
}
}


module.exports = { generateToken, authMiddleware };