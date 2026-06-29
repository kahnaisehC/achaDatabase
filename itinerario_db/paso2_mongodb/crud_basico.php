<?php
/**
 * PASO 2 · Referencia rápida: CRUD básico en MongoDB con PHP.
 * ------------------------------------------------------------
 * Script de consola (no es una página web). Ejecutalo con:
 *     php crud_basico.php
 *
 * Muestra, una tras otra, las 4 operaciones fundamentales:
 *   CREATE  -> insertOne
 *   READ    -> find / findOne
 *   UPDATE  -> updateOne
 *   DELETE  -> deleteOne
 */

use MongoDB\BSON\ObjectId;

$jugadores = require __DIR__ . '/db_mongo.php';

// ============ CREATE ============
// Insertamos un documento. Devuelve el _id generado por MongoDB.
$res = $jugadores->insertOne([
    'nombre_apellido' => 'Magnus Carlsen',
    'email'           => 'magnus@acha.org',
    'dni'             => '99999999',
    'id_fide'         => '1503014',
    'ciudad'          => 'Tromsø',
]);
$nuevoId = $res->getInsertedId();
echo "CREATE  -> insertado con _id: {$nuevoId}\n";

// ============ READ ============
// findOne: trae UN documento que cumpla el filtro.
$doc = $jugadores->findOne(['_id' => $nuevoId]);
echo "READ    -> nombre: {$doc['nombre_apellido']}, FIDE: {$doc['id_fide']}\n";

// find: trae MUCHOS (acá, todos). Devuelve un cursor recorrible.
$total = $jugadores->countDocuments();
echo "READ    -> total de jugadores en la colección: {$total}\n";

// ============ UPDATE ============
// updateOne + operador $set: cambia sólo los campos indicados.
$jugadores->updateOne(
    ['_id' => $nuevoId],
    ['$set' => ['ciudad' => 'Oslo']]
);
echo "UPDATE  -> ciudad actualizada a 'Oslo'\n";

// ============ DELETE ============
// deleteOne: borra el documento que cumpla el filtro.
$jugadores->deleteOne(['_id' => $nuevoId]);
echo "DELETE  -> documento {$nuevoId} eliminado\n";

echo "\nListo. CRUD completo demostrado.\n";
