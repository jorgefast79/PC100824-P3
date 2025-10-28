// hash-password.js
import bcrypt from 'bcrypt'; // o const bcrypt = require('bcrypt');

const password = 'admin123';
const saltRounds = 10;

bcrypt.hash(password, saltRounds)
  .then(hash => {
    console.log('Hash generado:', JSON.stringify(hash));
  })
  .catch(err => console.error(err));
