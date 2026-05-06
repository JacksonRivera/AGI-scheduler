/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: agi_tiquetes
-- ------------------------------------------------------
-- Server version	10.11.14-MariaDB-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `horarios`
--

DROP TABLE IF EXISTS `horarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `horarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trayecto_id` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `precio` int(11) NOT NULL,
  `cupos_disponibles` int(11) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `trayecto_id` (`trayecto_id`),
  CONSTRAINT `horarios_ibfk_1` FOREIGN KEY (`trayecto_id`) REFERENCES `trayectos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `horarios`
--

LOCK TABLES `horarios` WRITE;
/*!40000 ALTER TABLE `horarios` DISABLE KEYS */;
INSERT INTO `horarios` VALUES
(1,1,'2026-05-07','06:30:00',115000,12,1),
(2,1,'2026-05-07','12:00:00',135000,8,1),
(3,1,'2026-05-07','19:30:00',125000,9,1),
(4,2,'2026-05-07','07:00:00',130000,9,1),
(5,2,'2026-05-07','14:30:00',155000,7,1),
(6,2,'2026-05-07','21:00:00',145000,6,1),
(7,3,'2026-05-07','08:00:00',210000,7,1),
(8,3,'2026-05-07','16:00:00',235000,5,1),
(9,3,'2026-05-08','09:30:00',220000,10,1),
(10,4,'2026-05-07','05:45:00',225000,6,1),
(11,4,'2026-05-07','13:15:00',250000,5,1),
(12,4,'2026-05-08','18:40:00',240000,9,1),
(13,5,'2026-05-07','06:15:00',245000,4,1),
(14,5,'2026-05-07','17:20:00',270000,4,1),
(15,5,'2026-05-08','10:00:00',260000,8,1),
(16,6,'2026-05-07','07:40:00',295000,4,1),
(17,6,'2026-05-08','11:30:00',315000,5,1),
(18,6,'2026-05-08','20:00:00',305000,6,1),
(19,7,'2026-05-07','09:00:00',480000,3,1),
(20,7,'2026-05-08','15:00:00',520000,2,1),
(21,7,'2026-05-09','08:30:00',500000,4,1),
(22,8,'2026-05-07','10:30:00',420000,5,1),
(23,8,'2026-05-08','14:00:00',465000,3,1),
(24,8,'2026-05-09','19:00:00',440000,6,1);
/*!40000 ALTER TABLE `horarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservas`
--

DROP TABLE IF EXISTS `reservas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo_reserva` varchar(20) NOT NULL,
  `trayecto_id` int(11) NOT NULL,
  `horario_id` int(11) NOT NULL,
  `telefono` varchar(50) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT current_timestamp(),
  `estado` varchar(50) DEFAULT 'confirmada',
  PRIMARY KEY (`id`),
  KEY `trayecto_id` (`trayecto_id`),
  KEY `horario_id` (`horario_id`),
  CONSTRAINT `reservas_ibfk_1` FOREIGN KEY (`trayecto_id`) REFERENCES `trayectos` (`id`),
  CONSTRAINT `reservas_ibfk_2` FOREIGN KEY (`horario_id`) REFERENCES `horarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservas`
--

LOCK TABLES `reservas` WRITE;
/*!40000 ALTER TABLE `reservas` DISABLE KEYS */;
INSERT INTO `reservas` VALUES
(1,'384864',1,3,'6001','2026-05-06 00:44:52','confirmada'),
(2,'255896',3,7,'6001','2026-05-06 01:09:56','confirmada'),
(3,'504796',5,13,'6001','2026-05-06 01:18:10','confirmada');
/*!40000 ALTER TABLE `reservas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trayectos`
--

DROP TABLE IF EXISTS `trayectos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trayectos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `opcion_menu` int(11) NOT NULL,
  `origen` varchar(100) NOT NULL,
  `destino` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `opcion_menu` (`opcion_menu`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trayectos`
--

LOCK TABLES `trayectos` WRITE;
/*!40000 ALTER TABLE `trayectos` DISABLE KEYS */;
INSERT INTO `trayectos` VALUES
(1,1,'Medellin','Bogota','Ruta principal hacia la capital',1),
(2,2,'Medellin','Cali','Ruta hacia el suroccidente del pais',1),
(3,3,'Medellin','Barranquilla','Ruta hacia la costa caribe',1),
(4,4,'Medellin','Cartagena','Ruta turistica hacia la costa',1),
(5,5,'Medellin','Santa Marta','Ruta larga hacia el caribe',1),
(6,6,'Medellin','Pasto','Ruta lejana hacia el sur del pais',1),
(7,7,'Medellin','Leticia','Ruta muy lejana hacia el Amazonas',1),
(8,8,'Bogota','San Andres','Ruta aerea hacia la isla',1);
/*!40000 ALTER TABLE `trayectos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-06  1:23:04
