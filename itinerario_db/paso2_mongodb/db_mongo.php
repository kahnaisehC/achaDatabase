<?php
/**
 * PASO 2 · Conexión a MongoDB (modelo documental).
 * ------------------------------------------------------------
 * Requisitos:
 *   1) Extensión PECL del driver:   pecl install mongodb
 *   2) Librería de alto nivel:      composer require mongodb/mongodb
 *
 * Diferencia clave con el Paso 1:
 *   - En MySQL nos conectábamos a una BASE con TABLAS y FILAS.
 *   - En MongoDB nos conectamos a una BASE con COLECCIONES y DOCUMENTOS.
 *     Un "documento" es básicamente un JSON flexible.
 */

// Autoloader de Composer: deja disponible la clase MongoDB\Client.
require __DIR__ . '/vendor/autoload.php';

// --- Cadena de conexión --------------------------------------
// Formato:  mongodb://host:puerto
// (para MongoDB Atlas en la nube sería una URI tipo  mongodb+srv://...)
//
// Leemos la variable de entorno MONGO_URI si existe:
//   - Dentro de Docker apunta al servicio mongo:  mongodb://mongo:27017
//   - Si no está definida (ejecución local), usamos 127.0.0.1 por defecto.
$uri = getenv('MONGO_URI') ?: 'mongodb://127.0.0.1:27017';

try {
    // 1) Cliente: el equivalente al objeto PDO del Paso 1.
    $client = new MongoDB\Client($uri);

    // 2) Seleccionamos base "acha" y colección "jugadores".
    //    OJO: no hace falta crearlas antes. MongoDB las crea solas
    //    la primera vez que insertamos un documento. (Schema-less)
    $coleccion = $client->acha->jugadores;
} catch (Exception $e) {
    http_response_code(500);
    exit('Error de conexión a MongoDB: ' . $e->getMessage());
}

// Devolvemos la colección lista para usar desde otros archivos.
return $coleccion;
