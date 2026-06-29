-- ============================================================
--  PASO 1 · BASE DE DATOS RELACIONAL (MySQL / MariaDB)
--  Proyecto: Asociación Chaqueña de Ajedrez (ACHA)
--  Schema completo del caso de estudio.
-- ============================================================
--
--  Tablas:
--    personas            → jugador / socio / árbitro (roles superpuestos)
--    lichess_aliases     → multivaluado: aliases de cada persona en Lichess
--    socios              → extensión de persona (solo quienes son socios)
--    arbitros            → extensión de persona (solo quienes son árbitros)
--    torneos             → torneos presenciales y online
--    torneo_arb_ayud     → árbitros ayudantes de un torneo (N:M)
--    torneo_organizadores→ personas que organizan un torneo (N:M)
--    inscripciones       → relación administrativa: quién se inscribió y cómo
--    participaciones     → si el jugador efectivamente jugó el torneo
--    partidas            → registro de una partida (con PGN opcional)
--    circuitos           → conjuntos de torneos que clasifican a una final
--    circuito_torneos    → qué torneos forman cada circuito (N:M)
-- ============================================================

CREATE DATABASE IF NOT EXISTS acha
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE acha;

-- ============================================================
--  PERSONAS
--  El documento llama a esta entidad "Jugador/Persona".
--  En el modelo relacional NO podemos hacer que un campo sea
--  "opcional según el rol": si el campo existe, existe para todos.
--  La solución SQL clásica es usar tablas separadas (socios,
--  arbitros) que extienden a personas con sus campos extra.
--  Observá la cantidad de columnas DEFAULT NULL: eso es el
--  "costo" de un esquema fijo para datos heterogéneos.
--  En el Paso 2 veremos cómo MongoDB lo resuelve de otra forma.
-- ============================================================
DROP TABLE IF EXISTS lichess_aliases;
DROP TABLE IF EXISTS torneo_arb_ayud;
DROP TABLE IF EXISTS torneo_organizadores;
DROP TABLE IF EXISTS inscripciones;
DROP TABLE IF EXISTS participaciones;
DROP TABLE IF EXISTS partidas;
DROP TABLE IF EXISTS circuito_torneos;
DROP TABLE IF EXISTS circuitos;
DROP TABLE IF EXISTS torneos;
DROP TABLE IF EXISTS socios;
DROP TABLE IF EXISTS arbitros;
DROP TABLE IF EXISTS personas;

CREATE TABLE personas (
  id               INT          NOT NULL AUTO_INCREMENT,
  nombre_apellido  VARCHAR(255) NOT NULL,
  dni              VARCHAR(20)  NOT NULL,
  fecha_nacimiento DATE         DEFAULT NULL,
  celular          VARCHAR(30)  DEFAULT NULL,
  email            VARCHAR(255) DEFAULT NULL,
  ciudad           VARCHAR(100) DEFAULT NULL,
  provincia        VARCHAR(100) DEFAULT NULL,
  nacionalidad     VARCHAR(100) DEFAULT NULL,
  -- "entidad que representa": para socios es "Asociación Chaqueña de Ajedrez".
  -- para jugadores externos puede ser otro club o la ciudad.
  entidad          VARCHAR(255) DEFAULT NULL,
  id_fide          VARCHAR(20)  DEFAULT NULL,  -- no todos los jugadores tienen FIDE
  creado_en        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_personas_dni   (dni),
  UNIQUE KEY uq_personas_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  LICHESS ALIASES
--  Un jugador puede tener varias cuentas en Lichess.
--  En SQL, los campos multivaluados siempre se modelan como
--  una tabla separada con FK al padre.
--  (En MongoDB, sería simplemente un array dentro del documento.)
-- ============================================================
CREATE TABLE lichess_aliases (
  id         INT          NOT NULL AUTO_INCREMENT,
  persona_id INT          NOT NULL,
  alias      VARCHAR(100) NOT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_lichess_alias (alias),
  FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  SOCIOS
--  Extensión de Persona: solo las filas de personas que
--  además son socias de la ACHA tienen entrada aquí.
--  ON DELETE CASCADE: si se borra la persona, se borra el socio.
-- ============================================================
CREATE TABLE socios (
  id               INT     NOT NULL AUTO_INCREMENT,
  persona_id       INT     NOT NULL,
  numero_socio     INT     NOT NULL,
  cuota_al_dia     BOOLEAN NOT NULL DEFAULT FALSE,
  anio_formulario  YEAR    DEFAULT NULL,  -- año del último formulario actualizado

  PRIMARY KEY (id),
  UNIQUE KEY uq_socios_persona (persona_id),
  UNIQUE KEY uq_socios_numero  (numero_socio),
  FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  ÁRBITROS
--  Igual que socios: extensión opcional de Persona.
--  Una persona puede ser socio Y árbitro al mismo tiempo;
--  en ese caso tiene filas en ambas tablas.
-- ============================================================
CREATE TABLE arbitros (
  id                INT         NOT NULL AUTO_INCREMENT,
  persona_id        INT         NOT NULL,
  id_titulo_arbitro VARCHAR(50) DEFAULT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_arbitros_persona (persona_id),
  FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  TORNEOS
--  Los campos de IRT (director, árbitros, FIDE Event ID) son
--  DEFAULT NULL porque solo aplican si es_IRT = TRUE.
--  Esos NULLs "inevitables" en SQL son exactamente el trade-off
--  que el Paso 2 (MongoDB) resuelve con el esquema flexible.
-- ============================================================
CREATE TABLE torneos (
  id               INT          NOT NULL AUTO_INCREMENT,
  nombre           VARCHAR(255) NOT NULL,
  lugar            VARCHAR(255) DEFAULT NULL,
  control_tiempo   VARCHAR(100) DEFAULT NULL,  -- ej: '90+30', 'blitz 5+0'
  cupo_maximo      INT          DEFAULT NULL,
  es_IRT           BOOLEAN      NOT NULL DEFAULT FALSE,
  fide_event_id    VARCHAR(50)  DEFAULT NULL,  -- solo si es_IRT = TRUE
  -- El director de torneo es una Persona (no necesariamente árbitro).
  director_id      INT          DEFAULT NULL,
  -- Los árbitros sí son de la tabla arbitros.
  arb_principal_id INT          DEFAULT NULL,
  arb_adjunto_id   INT          DEFAULT NULL,
  es_online        BOOLEAN      NOT NULL DEFAULT FALSE,
  plataforma       VARCHAR(50)  DEFAULT NULL,  -- ej: 'lichess'
  fecha_inicio     DATE         DEFAULT NULL,
  fecha_fin        DATE         DEFAULT NULL,
  creado_en        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  FOREIGN KEY (director_id)      REFERENCES personas(id) ON DELETE SET NULL,
  FOREIGN KEY (arb_principal_id) REFERENCES arbitros(id) ON DELETE SET NULL,
  FOREIGN KEY (arb_adjunto_id)   REFERENCES arbitros(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Árbitros ayudantes: un torneo tiene varios, un árbitro ayuda en varios torneos.
CREATE TABLE torneo_arb_ayud (
  torneo_id  INT NOT NULL,
  arbitro_id INT NOT NULL,

  PRIMARY KEY (torneo_id, arbitro_id),
  FOREIGN KEY (torneo_id)  REFERENCES torneos(id)  ON DELETE CASCADE,
  FOREIGN KEY (arbitro_id) REFERENCES arbitros(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Organizadores: cualquier persona con permiso puede organizar un torneo
-- (distinto de arbitrar: el documento diferencia explícitamente estas dos relaciones).
CREATE TABLE torneo_organizadores (
  torneo_id  INT NOT NULL,
  persona_id INT NOT NULL,

  PRIMARY KEY (torneo_id, persona_id),
  FOREIGN KEY (torneo_id)  REFERENCES torneos(id)  ON DELETE CASCADE,
  FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  INSCRIPCIONES
--  Relación ADMINISTRATIVA: quién se inscribió, cuándo, con qué datos.
--  El documento distingue esto de la participación real:
--  alguien puede inscribirse y no aparecer el día del torneo.
--
--  El campo datos_extra usa JSON para los datos variables por torneo
--  (ej: "restricción alimenticia", "requiere alojamiento deportivo").
--  Nota: JSON en SQL es un parche necesario para datos semiestructurados.
--  MongoDB los manejaría de forma natural como campos del documento.
-- ============================================================
CREATE TABLE inscripciones (
  id                      INT       NOT NULL AUTO_INCREMENT,
  torneo_id               INT       NOT NULL,
  persona_id              INT       NOT NULL,
  fecha_inscripcion       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  comprobante_pago        BOOLEAN   NOT NULL DEFAULT FALSE,
  requiere_alojamiento    BOOLEAN   NOT NULL DEFAULT FALSE,
  restriccion_alimenticia VARCHAR(255) DEFAULT NULL,
  datos_extra             JSON      DEFAULT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_inscripcion (torneo_id, persona_id),
  FOREIGN KEY (torneo_id)  REFERENCES torneos(id)  ON DELETE CASCADE,
  FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  PARTICIPACIONES
--  ¿El jugador efectivamente jugó el torneo? Sí o no, y en
--  qué posición terminó. Sin datos burocráticos (eso es la inscripción).
--  Esta separación facilita los análisis de rendimiento sin
--  mezclarlos con datos administrativos.
-- ============================================================
CREATE TABLE participaciones (
  id             INT NOT NULL AUTO_INCREMENT,
  torneo_id      INT NOT NULL,
  persona_id     INT NOT NULL,
  posicion_final INT DEFAULT NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_participacion (torneo_id, persona_id),
  FOREIGN KEY (torneo_id)  REFERENCES torneos(id)  ON DELETE CASCADE,
  FOREIGN KEY (persona_id) REFERENCES personas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  PARTIDAS
--  Una partida es blancas vs. negras. Puede no pertenecer a
--  ningún torneo (partida de entrenamiento).
--  El PGN (Portable Game Notation) es el formato estándar para
--  guardar partidas de ajedrez; es autodescriptivo como JSON.
--  Solo torneos clásicos (IRT) deben guardar el PGN.
-- ============================================================
CREATE TABLE partidas (
  id              INT          NOT NULL AUTO_INCREMENT,
  persona_blancas INT          NOT NULL,
  persona_negras  INT          NOT NULL,
  torneo_id       INT          DEFAULT NULL,  -- NULL = partida de entrenamiento
  resultado       ENUM('1-0','0-1','1/2-1/2','*') NOT NULL DEFAULT '*',
  pgn             LONGTEXT     DEFAULT NULL,  -- texto PGN completo
  foto_planilla   VARCHAR(500) DEFAULT NULL,  -- ruta/URL a imagen de planilla física
  jugada_en       TIMESTAMP    DEFAULT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (persona_blancas) REFERENCES personas(id) ON DELETE RESTRICT,
  FOREIGN KEY (persona_negras)  REFERENCES personas(id) ON DELETE RESTRICT,
  FOREIGN KEY (torneo_id)       REFERENCES torneos(id)  ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  CIRCUITOS
--  Un circuito es un conjunto de torneos que clasifican a una
--  final. El criterio de clasificación varía por circuito
--  (campeón, mejor promedio de performance, etc.): lo guardamos
--  como texto libre porque no tiene estructura fija.
-- ============================================================
CREATE TABLE circuitos (
  id                     INT          NOT NULL AUTO_INCREMENT,
  nombre                 VARCHAR(255) NOT NULL,
  criterio_clasificacion TEXT         DEFAULT NULL,
  torneo_final_id        INT          DEFAULT NULL,

  PRIMARY KEY (id),
  FOREIGN KEY (torneo_final_id) REFERENCES torneos(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE circuito_torneos (
  circuito_id INT NOT NULL,
  torneo_id   INT NOT NULL,
  orden       INT DEFAULT NULL,  -- posición dentro del circuito

  PRIMARY KEY (circuito_id, torneo_id),
  FOREIGN KEY (circuito_id) REFERENCES circuitos(id) ON DELETE CASCADE,
  FOREIGN KEY (torneo_id)   REFERENCES torneos(id)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  DATOS DE EJEMPLO
-- ============================================================

-- Personas: jugador con FIDE, jugador sin FIDE, árbitro y organizador externo
INSERT INTO personas (nombre_apellido, dni, fecha_nacimiento, celular, email, ciudad, provincia, nacionalidad, entidad, id_fide) VALUES
  ('Juan Gomez',   '35939400', '1990-03-15', '3624001122', 'juan.gomez@acha.org',   'Resistencia', 'Chaco',     'Argentina', 'Asociación Chaqueña de Ajedrez', '4150001'),
  ('Joana Guarez', '35939411', '1995-07-22', '3624003344', 'joana.guarez@acha.org', 'Corrientes',  'Corrientes','Argentina', 'Club Corrientes',                NULL),
  ('Carlos Ruiz',  '28100200', '1985-01-10', '3624005566', 'carlos.ruiz@acha.org',  'Resistencia', 'Chaco',     'Argentina', 'Asociación Chaqueña de Ajedrez', '4150099');

-- Alias de Lichess (Juan tiene dos cuentas)
INSERT INTO lichess_aliases (persona_id, alias) VALUES
  (1, 'jgomez_chess'),
  (1, 'JuanGomezARG'),
  (2, 'joana_g95');

-- Socios
INSERT INTO socios (persona_id, numero_socio, cuota_al_dia, anio_formulario) VALUES
  (1, 101, TRUE,  2026),
  (3, 102, FALSE, 2025);

-- Árbitros
INSERT INTO arbitros (persona_id, id_titulo_arbitro) VALUES
  (3, 'FA-0045');  -- Carlos Ruiz es árbitro FIDE

-- Torneo IRT
INSERT INTO torneos (nombre, lugar, control_tiempo, cupo_maximo, es_IRT, fide_event_id, director_id, arb_principal_id, fecha_inicio, fecha_fin) VALUES
  ('Torneo Provincial Blitz 2026', 'Club Social Resistencia', '5+0', 40, TRUE, 'ARG2026001', 1, 1, '2026-08-15', '2026-08-15');

-- Torneo online
INSERT INTO torneos (nombre, es_IRT, es_online, plataforma, fecha_inicio) VALUES
  ('Copa ACHA Online Lichess #3', FALSE, TRUE, 'lichess', '2026-07-20');

-- Inscripciones al torneo presencial
INSERT INTO inscripciones (torneo_id, persona_id, comprobante_pago, requiere_alojamiento) VALUES
  (1, 1, TRUE,  FALSE),
  (1, 2, FALSE, TRUE);

-- Participaciones (Juan participó, Joana no pudo ir)
INSERT INTO participaciones (torneo_id, persona_id, posicion_final) VALUES
  (1, 1, 1);

-- Partida del torneo con PGN mínimo
INSERT INTO partidas (persona_blancas, persona_negras, torneo_id, resultado, pgn) VALUES
  (1, 2, 1, '1-0',
   '[Event "Torneo Provincial Blitz 2026"]\n[White "Gomez, Juan"]\n[Black "Guarez, Joana"]\n[Result "1-0"]\n\n1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 1-0');

-- Circuito con dos torneos
INSERT INTO circuitos (nombre, criterio_clasificacion, torneo_final_id) VALUES
  ('Liga Chaqueña 2026', 'Clasifica el jugador con mejor promedio de performance en los torneos del circuito.', NULL);

INSERT INTO circuito_torneos (circuito_id, torneo_id, orden) VALUES
  (1, 1, 1),
  (1, 2, 2);
