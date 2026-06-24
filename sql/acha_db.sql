-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Apr 28, 2026 at 02:22 PM
-- Server version: 9.7.0
-- PHP Version: 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `acha_db`
--
CREATE DATABASE IF NOT EXISTS `acha_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `acha_db`;

-- --------------------------------------------------------

--
-- Table structure for table `Alias_Lichess`
--

DROP TABLE IF EXISTS `Alias_Lichess`;
CREATE TABLE `Alias_Lichess` (
  `id_persona` int NOT NULL,
  `alias` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Alias_Lichess`
--

INSERT INTO `Alias_Lichess` (`id_persona`, `alias`) VALUES
(1, 'CarlosChess90'),
(2, 'LauraGM'),
(3, 'MarcosFM'),
(4, 'SofiaTactics'),
(5, 'DiegoEndgame'),
(6, 'AnaAttacks'),
(7, 'NicoMaster'),
(8, 'ValeBlitz'),
(10, 'ElenaStrategy');

-- --------------------------------------------------------

--
-- Table structure for table `Arbitra`
--

DROP TABLE IF EXISTS `Arbitra`;
CREATE TABLE `Arbitra` (
  `id_persona` int NOT NULL,
  `id_torneo` int NOT NULL,
  `rol` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Arbitra`
--

INSERT INTO `Arbitra` (`id_persona`, `id_torneo`, `rol`) VALUES
(11, 1, 'Árbitro Principal'),
(11, 3, 'Árbitro Auxiliar'),
(12, 2, 'Árbitro Principal'),
(12, 4, 'Árbitro Principal');

-- --------------------------------------------------------

--
-- Table structure for table `Arbitro`
--

DROP TABLE IF EXISTS `Arbitro`;
CREATE TABLE `Arbitro` (
  `id_persona` int NOT NULL,
  `id_titulo_arbitro` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Arbitro`
--

INSERT INTO `Arbitro` (`id_persona`, `id_titulo_arbitro`) VALUES
(11, 'Arbitro Nacional'),
(12, 'Arbitro FIDE');

-- --------------------------------------------------------

--
-- Table structure for table `Circuito`
--

DROP TABLE IF EXISTS `Circuito`;
CREATE TABLE `Circuito` (
  `id_circuito` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text,
  `año` int NOT NULL,
  `criterio_clasif` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Circuito`
--

INSERT INTO `Circuito` (`id_circuito`, `nombre`, `descripcion`, `año`, `criterio_clasif`) VALUES
(1, 'Circuito Chaqueño 2025', 'Serie de torneos del NEA con ranking acumulado.', 2025, 'Suma de puntos en los 4 mejores torneos del año.'),
(2, 'Liga Juvenil NOA-NEA 2025', 'Circuito juvenil inter-regional para menores de 20 años.', 2025, 'Mejor puntaje en 3 torneos obligatorios.');

-- --------------------------------------------------------

--
-- Table structure for table `Evento`
--

DROP TABLE IF EXISTS `Evento`;
CREATE TABLE `Evento` (
  `id_evento` int NOT NULL,
  `nombre` varchar(120) NOT NULL,
  `descripcion` text,
  `fecha_hora` datetime NOT NULL,
  `cupo` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Evento`
--

INSERT INTO `Evento` (`id_evento`, `nombre`, `descripcion`, `fecha_hora`, `cupo`) VALUES
(1, 'Simul Maestro Invitado', 'Simultáneas de 20 tableros con GM Ariel Sorin.', '2025-05-10 16:00:00', 20),
(2, 'Charla: Finales de Torres', 'Clase teórica abierta a socios y no socios.', '2025-05-17 18:30:00', NULL),
(3, 'Torneo Relámpago Informal', 'Torneo casual sin rating para nuevos jugadores.', '2025-05-24 15:00:00', 30);

-- --------------------------------------------------------

--
-- Table structure for table `Inscripcion`
--

DROP TABLE IF EXISTS `Inscripcion`;
CREATE TABLE `Inscripcion` (
  `id_inscripcion` int NOT NULL,
  `id_persona` int NOT NULL,
  `id_torneo` int NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `paga_multa` tinyint(1) NOT NULL DEFAULT '0',
  `datos_adicionales` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Inscripcion`
--

INSERT INTO `Inscripcion` (`id_inscripcion`, `id_persona`, `id_torneo`, `fecha_hora`, `paga_multa`, `datos_adicionales`) VALUES
(1, 1, 1, '2025-04-01 10:00:00', 0, '{\"categoria\": \"Primera\", \"elo_local\": 1950}'),
(2, 2, 1, '2025-04-01 11:00:00', 0, '{\"categoria\": \"Primera\", \"elo_local\": 2050}'),
(3, 3, 1, '2025-04-02 09:30:00', 0, '{\"categoria\": \"Primera\", \"elo_local\": 1850}'),
(4, 4, 1, '2025-04-02 10:15:00', 0, '{\"categoria\": \"Sub-20\", \"elo_local\": 1620}'),
(5, 5, 1, '2025-04-03 08:00:00', 0, '{\"categoria\": \"Primera\", \"elo_local\": 1780}'),
(6, 6, 2, '2025-04-05 14:00:00', 0, '{\"categoria\": \"Primera\", \"elo_local\": 1540}'),
(7, 7, 2, '2025-04-05 15:00:00', 0, '{\"categoria\": \"Primera\", \"elo_local\": 2010}'),
(8, 8, 2, '2025-04-06 09:00:00', 1, '{\"categoria\": \"Sub-20\", \"elo_local\": 1480}'),
(9, 9, 3, '2025-04-10 18:00:00', 0, NULL),
(10, 10, 3, '2025-04-10 18:05:00', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `Jugador_Organiza`
--

DROP TABLE IF EXISTS `Jugador_Organiza`;
CREATE TABLE `Jugador_Organiza` (
  `id_persona` int NOT NULL,
  `id_torneo` int NOT NULL,
  `rol` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Jugador_Organiza`
--

INSERT INTO `Jugador_Organiza` (`id_persona`, `id_torneo`, `rol`) VALUES
(7, 3, 'Organizador'),
(12, 1, 'Coordinador General'),
(12, 2, 'Coordinador General'),
(12, 4, 'Coordinador General');

-- --------------------------------------------------------

--
-- Table structure for table `Participa_Evento`
--

DROP TABLE IF EXISTS `Participa_Evento`;
CREATE TABLE `Participa_Evento` (
  `id_persona` int NOT NULL,
  `id_evento` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Participa_Evento`
--

INSERT INTO `Participa_Evento` (`id_persona`, `id_evento`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 1),
(10, 1),
(1, 2),
(2, 2),
(5, 2),
(7, 2),
(10, 2),
(4, 3),
(6, 3),
(8, 3),
(9, 3);

-- --------------------------------------------------------

--
-- Table structure for table `Participa_Torneo`
--

DROP TABLE IF EXISTS `Participa_Torneo`;
CREATE TABLE `Participa_Torneo` (
  `id_persona` int NOT NULL,
  `id_torneo` int NOT NULL,
  `posicion` int DEFAULT NULL,
  `performance` int DEFAULT NULL,
  `usuario_de_lichess` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Participa_Torneo`
--

INSERT INTO `Participa_Torneo` (`id_persona`, `id_torneo`, `posicion`, `performance`, `usuario_de_lichess`) VALUES
(1, 1, 2, 1980, 'CarlosChess90'),
(2, 1, 1, 2120, 'LauraGM'),
(3, 1, 4, 1790, 'MarcosFM'),
(4, 1, 5, 1650, 'SofiaTactics'),
(5, 1, 3, 1820, 'DiegoEndgame'),
(6, 2, 2, 1570, 'AnaAttacks'),
(7, 2, 1, 2045, 'NicoMaster'),
(8, 2, 3, 1500, 'ValeBlitz'),
(9, 3, 1, NULL, NULL),
(10, 3, 2, NULL, 'ElenaStrategy');

-- --------------------------------------------------------

--
-- Table structure for table `Partida`
--

DROP TABLE IF EXISTS `Partida`;
CREATE TABLE `Partida` (
  `id_partida` int NOT NULL,
  `id_torneo` int DEFAULT NULL,
  `id_blancas` int NOT NULL,
  `id_negras` int NOT NULL,
  `resultado` enum('1-0','½-½','0-1','0-0','+/-','-/+') NOT NULL,
  `pgn` text,
  `foto_planilla` text,
  `fecha` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Partida`
--

INSERT INTO `Partida` (`id_partida`, `id_torneo`, `id_blancas`, `id_negras`, `resultado`, `pgn`, `foto_planilla`, `fecha`) VALUES
(1, 1, 1, 2, '0-1', '1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 6.Re1 b5 7.Bb3 d6 8.c3 O-O', NULL, '2025-05-03'),
(2, 1, 3, 4, '1-0', '1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.e3 O-O 5.Bd3 d5 6.Nf3 c5', NULL, '2025-05-03'),
(3, 1, 5, 1, '½-½', '1.Nf3 d5 2.g3 Nf6 3.Bg2 e6 4.O-O Be7 5.d3 O-O', NULL, '2025-05-04'),
(4, 1, 2, 3, '1-0', '1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6 6.Bg5', NULL, '2025-05-04'),
(5, 1, 4, 5, '0-1', '1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Nf3 Be7 5.Bg5 O-O', NULL, '2025-05-05'),
(6, 2, 6, 7, '0-1', '1.e4 e6 2.d4 d5 3.Nc3 Bb4 4.e5 c5 5.a3 Bxc3+ 6.bxc3 Ne7', NULL, '2025-05-10'),
(7, 2, 8, 7, '0-1', '1.c4 Nf6 2.Nc3 e5 3.g3 d5 4.cxd5 Nxd5 5.Bg2', NULL, '2025-05-10'),
(8, 3, 9, 10, '½-½', NULL, NULL, '2025-05-17'),
(9, NULL, 1, 7, '1-0', '1.e4 e5 2.f4 exf4 3.Nf3 g5 4.h4 g4 5.Ne5 Nf6 6.Bc4', NULL, '2025-05-01');

-- --------------------------------------------------------

--
-- Table structure for table `Persona`
--

DROP TABLE IF EXISTS `Persona`;
CREATE TABLE `Persona` (
  `id` int NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `apellido` varchar(80) NOT NULL,
  `DNI` varchar(20) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `nacionalidad` varchar(50) NOT NULL,
  `provincia` varchar(80) NOT NULL,
  `celular` varchar(20) NOT NULL,
  `id_fide` varchar(20) DEFAULT NULL,
  `pago_canon` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Persona`
--

INSERT INTO `Persona` (`id`, `nombre`, `apellido`, `DNI`, `fecha_nacimiento`, `nacionalidad`, `provincia`, `celular`, `id_fide`, `pago_canon`) VALUES
(1, 'Carlos', 'Rodríguez', '28541632', '1990-03-14', 'Argentina', 'Chaco', '3624100001', '1234567', 1),
(2, 'Laura', 'González', '31204785', '1995-07-22', 'Argentina', 'Buenos Aires', '3624100002', '2345678', 1),
(3, 'Marcos', 'Fernández', '25874136', '1985-11-05', 'Argentina', 'Córdoba', '3624100003', '3456789', 0),
(4, 'Sofía', 'Martínez', '37891024', '2000-01-30', 'Argentina', 'Chaco', '3624100004', NULL, 1),
(5, 'Diego', 'López', '29637418', '1988-06-18', 'Argentina', 'Santa Fe', '3624100005', '4567890', 1),
(6, 'Ana', 'Pérez', '33412087', '1997-09-09', 'Argentina', 'Misiones', '3624100006', NULL, 0),
(7, 'Nicolás', 'García', '26987543', '1983-12-25', 'Argentina', 'Chaco', '3624100007', '5678901', 1),
(8, 'Valentina', 'Torres', '38012345', '2002-04-11', 'Argentina', 'Formosa', '3624100008', NULL, 1),
(9, 'Roberto', 'Díaz', '24563019', '1979-08-03', 'Argentina', 'Chaco', '3624100009', '6789012', 0),
(10, 'Elena', 'Ruiz', '30789456', '1993-02-27', 'Argentina', 'Santiago', '3624100010', '7890123', 1),
(11, 'Hernán', 'Acosta', '22345678', '1975-05-16', 'Argentina', 'Chaco', '3624100011', '8901234', 1),
(12, 'Patricia', 'Vega', '27654321', '1980-10-08', 'Argentina', 'Buenos Aires', '3624100012', '9012345', 1);

-- --------------------------------------------------------

--
-- Table structure for table `Se_Encarga`
--

DROP TABLE IF EXISTS `Se_Encarga`;
CREATE TABLE `Se_Encarga` (
  `id_persona` int NOT NULL,
  `id_evento` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Se_Encarga`
--

INSERT INTO `Se_Encarga` (`id_persona`, `id_evento`) VALUES
(12, 1),
(11, 2),
(7, 3);

-- --------------------------------------------------------

--
-- Table structure for table `Socio`
--

DROP TABLE IF EXISTS `Socio`;
CREATE TABLE `Socio` (
  `id_persona` int NOT NULL,
  `numero_socio` int NOT NULL,
  `cuota_al_dia` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Socio`
--

INSERT INTO `Socio` (`id_persona`, `numero_socio`, `cuota_al_dia`) VALUES
(1, 1001, 1),
(2, 1002, 1),
(3, 1003, 0),
(4, 1004, 1),
(5, 1005, 1),
(7, 1006, 1),
(9, 1007, 0),
(10, 1008, 1);

-- --------------------------------------------------------

--
-- Table structure for table `Torneo`
--

DROP TABLE IF EXISTS `Torneo`;
CREATE TABLE `Torneo` (
  `id_torneo` int NOT NULL,
  `nombre` varchar(120) NOT NULL,
  `lugar` varchar(150) NOT NULL,
  `control_tiempo` varchar(40) NOT NULL,
  `cupo` int NOT NULL,
  `fide_event_id` varchar(20) DEFAULT NULL,
  `formulario_url` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Torneo`
--

INSERT INTO `Torneo` (`id_torneo`, `nombre`, `lugar`, `control_tiempo`, `cupo`, `fide_event_id`, `formulario_url`) VALUES
(1, 'Torneo Apertura Chaco 2025', 'Club Resistencia, Av. Alberdi 450', '90+30', 32, 'ARG2025001', 'https://forms.gle/apertura2025'),
(2, 'Copa Ciudad de Resistencia', 'Centro Cultural, San Martín 120', '60+0', 16, NULL, 'https://forms.gle/copa2025'),
(3, 'Blitz Nocturno – Ronda 3', 'Club Resistencia, Sala B', '3+2', 24, NULL, NULL),
(4, 'Campeonato Provincial Sub-20 2025', 'Polideportivo Provincial', '90+30', 20, 'ARG2025002', 'https://forms.gle/sub20-2025');

-- --------------------------------------------------------

--
-- Table structure for table `Torneo_Circuito`
--

DROP TABLE IF EXISTS `Torneo_Circuito`;
CREATE TABLE `Torneo_Circuito` (
  `id_torneo` int NOT NULL,
  `id_circuito` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Torneo_Circuito`
--

INSERT INTO `Torneo_Circuito` (`id_torneo`, `id_circuito`) VALUES
(1, 1),
(2, 1),
(4, 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Alias_Lichess`
--
ALTER TABLE `Alias_Lichess`
  ADD PRIMARY KEY (`alias`),
  ADD KEY `fk_alias_persona` (`id_persona`);

--
-- Indexes for table `Arbitra`
--
ALTER TABLE `Arbitra`
  ADD PRIMARY KEY (`id_persona`,`id_torneo`),
  ADD KEY `fk_arbitra_torneo` (`id_torneo`);

--
-- Indexes for table `Arbitro`
--
ALTER TABLE `Arbitro`
  ADD PRIMARY KEY (`id_persona`);

--
-- Indexes for table `Circuito`
--
ALTER TABLE `Circuito`
  ADD PRIMARY KEY (`id_circuito`);

--
-- Indexes for table `Evento`
--
ALTER TABLE `Evento`
  ADD PRIMARY KEY (`id_evento`);

--
-- Indexes for table `Inscripcion`
--
ALTER TABLE `Inscripcion`
  ADD PRIMARY KEY (`id_inscripcion`),
  ADD KEY `fk_insc_persona` (`id_persona`),
  ADD KEY `fk_insc_torneo` (`id_torneo`);

--
-- Indexes for table `Jugador_Organiza`
--
ALTER TABLE `Jugador_Organiza`
  ADD PRIMARY KEY (`id_persona`,`id_torneo`),
  ADD KEY `fk_org_torneo` (`id_torneo`);

--
-- Indexes for table `Participa_Evento`
--
ALTER TABLE `Participa_Evento`
  ADD PRIMARY KEY (`id_persona`,`id_evento`),
  ADD KEY `fk_pe_evento` (`id_evento`);

--
-- Indexes for table `Participa_Torneo`
--
ALTER TABLE `Participa_Torneo`
  ADD PRIMARY KEY (`id_persona`,`id_torneo`),
  ADD KEY `fk_pt_torneo` (`id_torneo`);

--
-- Indexes for table `Partida`
--
ALTER TABLE `Partida`
  ADD PRIMARY KEY (`id_partida`),
  ADD KEY `fk_partida_torneo` (`id_torneo`),
  ADD KEY `fk_partida_blancas` (`id_blancas`),
  ADD KEY `fk_partida_negras` (`id_negras`);

--
-- Indexes for table `Persona`
--
ALTER TABLE `Persona`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Se_Encarga`
--
ALTER TABLE `Se_Encarga`
  ADD PRIMARY KEY (`id_persona`,`id_evento`),
  ADD KEY `fk_se_evento` (`id_evento`);

--
-- Indexes for table `Socio`
--
ALTER TABLE `Socio`
  ADD PRIMARY KEY (`id_persona`),
  ADD UNIQUE KEY `numero_socio` (`numero_socio`);

--
-- Indexes for table `Torneo`
--
ALTER TABLE `Torneo`
  ADD PRIMARY KEY (`id_torneo`);

--
-- Indexes for table `Torneo_Circuito`
--
ALTER TABLE `Torneo_Circuito`
  ADD PRIMARY KEY (`id_torneo`,`id_circuito`),
  ADD KEY `fk_tc_circuito` (`id_circuito`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Circuito`
--
ALTER TABLE `Circuito`
  MODIFY `id_circuito` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Evento`
--
ALTER TABLE `Evento`
  MODIFY `id_evento` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Inscripcion`
--
ALTER TABLE `Inscripcion`
  MODIFY `id_inscripcion` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `Partida`
--
ALTER TABLE `Partida`
  MODIFY `id_partida` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `Persona`
--
ALTER TABLE `Persona`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `Torneo`
--
ALTER TABLE `Torneo`
  MODIFY `id_torneo` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Alias_Lichess`
--
ALTER TABLE `Alias_Lichess`
  ADD CONSTRAINT `fk_alias_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`);

--
-- Constraints for table `Arbitra`
--
ALTER TABLE `Arbitra`
  ADD CONSTRAINT `fk_arbitra_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`),
  ADD CONSTRAINT `fk_arbitra_torneo` FOREIGN KEY (`id_torneo`) REFERENCES `Torneo` (`id_torneo`);

--
-- Constraints for table `Arbitro`
--
ALTER TABLE `Arbitro`
  ADD CONSTRAINT `fk_arbitro_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`);

--
-- Constraints for table `Inscripcion`
--
ALTER TABLE `Inscripcion`
  ADD CONSTRAINT `fk_insc_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`),
  ADD CONSTRAINT `fk_insc_torneo` FOREIGN KEY (`id_torneo`) REFERENCES `Torneo` (`id_torneo`);

--
-- Constraints for table `Jugador_Organiza`
--
ALTER TABLE `Jugador_Organiza`
  ADD CONSTRAINT `fk_org_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`),
  ADD CONSTRAINT `fk_org_torneo` FOREIGN KEY (`id_torneo`) REFERENCES `Torneo` (`id_torneo`);

--
-- Constraints for table `Participa_Evento`
--
ALTER TABLE `Participa_Evento`
  ADD CONSTRAINT `fk_pe_evento` FOREIGN KEY (`id_evento`) REFERENCES `Evento` (`id_evento`),
  ADD CONSTRAINT `fk_pe_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`);

--
-- Constraints for table `Participa_Torneo`
--
ALTER TABLE `Participa_Torneo`
  ADD CONSTRAINT `fk_pt_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`),
  ADD CONSTRAINT `fk_pt_torneo` FOREIGN KEY (`id_torneo`) REFERENCES `Torneo` (`id_torneo`);

--
-- Constraints for table `Partida`
--
ALTER TABLE `Partida`
  ADD CONSTRAINT `fk_partida_blancas` FOREIGN KEY (`id_blancas`) REFERENCES `Persona` (`id`),
  ADD CONSTRAINT `fk_partida_negras` FOREIGN KEY (`id_negras`) REFERENCES `Persona` (`id`),
  ADD CONSTRAINT `fk_partida_torneo` FOREIGN KEY (`id_torneo`) REFERENCES `Torneo` (`id_torneo`);

--
-- Constraints for table `Se_Encarga`
--
ALTER TABLE `Se_Encarga`
  ADD CONSTRAINT `fk_se_evento` FOREIGN KEY (`id_evento`) REFERENCES `Evento` (`id_evento`),
  ADD CONSTRAINT `fk_se_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`);

--
-- Constraints for table `Socio`
--
ALTER TABLE `Socio`
  ADD CONSTRAINT `fk_socio_persona` FOREIGN KEY (`id_persona`) REFERENCES `Persona` (`id`);

--
-- Constraints for table `Torneo_Circuito`
--
ALTER TABLE `Torneo_Circuito`
  ADD CONSTRAINT `fk_tc_circuito` FOREIGN KEY (`id_circuito`) REFERENCES `Circuito` (`id_circuito`),
  ADD CONSTRAINT `fk_tc_torneo` FOREIGN KEY (`id_torneo`) REFERENCES `Torneo` (`id_torneo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
