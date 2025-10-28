-- Crear usuario administrador o actualizarlo si ya existe
INSERT INTO users (email, password_hash, name)
VALUES ('admin@example.com', '$2b$10$AANNBVlssvdXZxuH7wD3oukKNWFjngX10sjxhBOcbOo/JmZnQjtXm', 'Administrador')
ON CONFLICT (email) DO UPDATE
SET password_hash = EXCLUDED.password_hash,
    name = EXCLUDED.name;