<?php
/**
 * PASO 1 · Conexión a MySQL usando PDO.
 * ------------------------------------------------------------
 * Centralizamos la conexión en un solo archivo y la reutilizamos
 * con: $pdo = require 'db.php';
 *
 * ¿Por qué PDO?
 *   - Es la forma moderna y segura de hablar con la base en PHP.
 *   - Permite "consultas preparadas" (prepared statements), que
 *     evitan la inyección SQL.
 *   - Funciona con muchos motores (MySQL, PostgreSQL, SQLite...).
 */

// --- Datos de conexión -------------------------------------------
// Dentro de Docker leemos las variables de entorno definidas en
// docker-compose.yml. Fuera de Docker (XAMPP) caen los valores
// por defecto ('127.0.0.1', 'root', '', etc.).
$host   = $_ENV['MYSQL_HOST']     ?? '127.0.0.1';
$puerto = 3306;
$base   = $_ENV['MYSQL_DATABASE'] ?? 'acha';
$user   = $_ENV['MYSQL_USER']     ?? 'root';
$pass   = $_ENV['MYSQL_PASSWORD'] ?? '';

// DSN = cadena que describe a qué nos conectamos.
$dsn = "mysql:host=$host;port=$puerto;dbname=$base;charset=utf8mb4";

// Opciones recomendadas para PDO.
$opciones = [
    // Si algo falla, que lance una excepción (y no falle en silencio).
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    // Traer las filas como arrays asociativos: $fila['nombre_apellido'].
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    // Usar prepared statements reales del servidor (más seguro).
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    // Creamos la conexión.
    $pdo = new PDO($dsn, $user, $pass, $opciones);
} catch (PDOException $e) {
    // En un proyecto real registraríamos el error en un log,
    // no lo mostraríamos al usuario. Aquí lo mostramos para aprender.
    http_response_code(500);
    exit('Error de conexión a la base de datos: ' . $e->getMessage());
}

// Devolvemos la conexión para usarla desde otros archivos.
return $pdo;
