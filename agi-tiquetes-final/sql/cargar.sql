CREATE DATABASE IF NOT EXISTS agi_tiquetes
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'agi_tiquetes_user'@'localhost'
IDENTIFIED BY 'Tiquetes123*';

GRANT SELECT, INSERT, UPDATE ON agi_tiquetes.* TO 'agi_tiquetes_user'@'localhost';
FLUSH PRIVILEGES;

USE agi_tiquetes;

DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS horarios;
DROP TABLE IF EXISTS trayectos;

CREATE TABLE trayectos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  opcion_menu INT NOT NULL UNIQUE,
  origen VARCHAR(100) NOT NULL,
  destino VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255),
  activo TINYINT(1) DEFAULT 1
);

CREATE TABLE horarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  trayecto_id INT NOT NULL,
  fecha DATE NOT NULL,
  hora TIME NOT NULL,
  precio INT NOT NULL,
  cupos_disponibles INT NOT NULL,
  activo TINYINT(1) DEFAULT 1,
  FOREIGN KEY (trayecto_id) REFERENCES trayectos(id)
);

CREATE TABLE reservas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo_reserva VARCHAR(20) NOT NULL,
  trayecto_id INT NOT NULL,
  horario_id INT NOT NULL,
  telefono VARCHAR(50),
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado VARCHAR(50) DEFAULT 'confirmada',
  FOREIGN KEY (trayecto_id) REFERENCES trayectos(id),
  FOREIGN KEY (horario_id) REFERENCES horarios(id)
);

INSERT INTO trayectos (opcion_menu, origen, destino, descripcion) VALUES
(1, 'Medellin', 'Bogota', 'Ruta principal hacia la capital'),
(2, 'Medellin', 'Cali', 'Ruta hacia el suroccidente del pais'),
(3, 'Medellin', 'Barranquilla', 'Ruta hacia la costa caribe'),
(4, 'Medellin', 'Cartagena', 'Ruta turistica hacia la costa'),
(5, 'Medellin', 'Santa Marta', 'Ruta larga hacia el caribe'),
(6, 'Medellin', 'Pasto', 'Ruta lejana hacia el sur del pais'),
(7, 'Medellin', 'Leticia', 'Ruta muy lejana hacia el Amazonas'),
(8, 'Bogota', 'San Andres', 'Ruta aerea hacia la isla');

INSERT INTO horarios (trayecto_id, fecha, hora, precio, cupos_disponibles) VALUES
-- Medellin - Bogota
(1, CURDATE() + INTERVAL 1 DAY, '06:30:00', 115000, 12),
(1, CURDATE() + INTERVAL 1 DAY, '12:00:00', 135000, 8),
(1, CURDATE() + INTERVAL 1 DAY, '19:30:00', 125000, 10),

-- Medellin - Cali
(2, CURDATE() + INTERVAL 1 DAY, '07:00:00', 130000, 9),
(2, CURDATE() + INTERVAL 1 DAY, '14:30:00', 155000, 7),
(2, CURDATE() + INTERVAL 1 DAY, '21:00:00', 145000, 6),

-- Medellin - Barranquilla
(3, CURDATE() + INTERVAL 1 DAY, '08:00:00', 210000, 8),
(3, CURDATE() + INTERVAL 1 DAY, '16:00:00', 235000, 5),
(3, CURDATE() + INTERVAL 2 DAY, '09:30:00', 220000, 10),

-- Medellin - Cartagena
(4, CURDATE() + INTERVAL 1 DAY, '05:45:00', 225000, 6),
(4, CURDATE() + INTERVAL 1 DAY, '13:15:00', 250000, 5),
(4, CURDATE() + INTERVAL 2 DAY, '18:40:00', 240000, 9),

-- Medellin - Santa Marta
(5, CURDATE() + INTERVAL 1 DAY, '06:15:00', 245000, 5),
(5, CURDATE() + INTERVAL 1 DAY, '17:20:00', 270000, 4),
(5, CURDATE() + INTERVAL 2 DAY, '10:00:00', 260000, 8),

-- Medellin - Pasto
(6, CURDATE() + INTERVAL 1 DAY, '07:40:00', 295000, 4),
(6, CURDATE() + INTERVAL 2 DAY, '11:30:00', 315000, 5),
(6, CURDATE() + INTERVAL 2 DAY, '20:00:00', 305000, 6),

-- Medellin - Leticia
(7, CURDATE() + INTERVAL 1 DAY, '09:00:00', 480000, 3),
(7, CURDATE() + INTERVAL 2 DAY, '15:00:00', 520000, 2),
(7, CURDATE() + INTERVAL 3 DAY, '08:30:00', 500000, 4),

-- Bogota - San Andres
(8, CURDATE() + INTERVAL 1 DAY, '10:30:00', 420000, 5),
(8, CURDATE() + INTERVAL 2 DAY, '14:00:00', 465000, 3),
(8, CURDATE() + INTERVAL 3 DAY, '19:00:00', 440000, 6);
