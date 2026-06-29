<?php
/**
 * PASO 2 · La MISMA app del Paso 1, pero con MongoDB.
 * ------------------------------------------------------------
 * Registra un jugador y lista a todos. Fijate que el HTML es
 * idéntico al del Paso 1: lo único que cambió es CÓMO guardamos
 * y leemos los datos (documentos en vez de filas).
 */

use MongoDB\BSON\ObjectId;       // Tipo del _id que genera MongoDB
use MongoDB\BSON\UTCDateTime;    // Fecha al estilo MongoDB

// Traemos la colección 'jugadores' desde db_mongo.php.
$jugadoresCol = require __DIR__ . '/db_mongo.php';

$mensaje = '';

// --- ALTA (CREATE) -------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'crear') {
    $nombre = trim($_POST['nombre_apellido'] ?? '');
    $email  = trim($_POST['email'] ?? '');
    $dni    = trim($_POST['dni'] ?? '');
    $fide   = trim($_POST['id_fide'] ?? '');
    $ciudad = trim($_POST['ciudad'] ?? '');

    if ($nombre === '' || $email === '' || $dni === '') {
        $mensaje = 'Nombre, email y DNI son obligatorios.';
    } else {
        // Armamos el DOCUMENTO como un array asociativo (≈ un JSON).
        // CLAVE: si el jugador NO tiene id_fide, directamente NO
        // incluimos el campo. En MongoDB cada documento puede tener
        // campos distintos -> esto es el "esquema flexible".
        $doc = [
            'nombre_apellido' => $nombre,
            'email'           => $email,
            'dni'             => $dni,
            'ciudad'          => ($ciudad === '' ? null : $ciudad),
            'creado_en'       => new UTCDateTime(),  // fecha actual
        ];
        if ($fide !== '') {
            $doc['id_fide'] = $fide;   // sólo existe si lo cargaron
        }

        // insertOne -> equivale al INSERT del Paso 1.
        $jugadoresCol->insertOne($doc);
        $mensaje = 'Jugador registrado en MongoDB.';
    }
}

// --- BAJA (DELETE) -------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'borrar') {
    // deleteOne -> borra el documento cuyo _id coincida.
    $jugadoresCol->deleteOne(['_id' => new ObjectId($_POST['id'])]);
    $mensaje = 'Jugador eliminado.';
}

// --- LISTADO (READ) ------------------------------------------
// find() devuelve un cursor. Lo ordenamos por _id descendente.
$jugadores = $jugadoresCol->find([], ['sort' => ['_id' => -1]]);

function e(?string $valor): string
{
    return htmlspecialchars((string) ($valor ?? ''), ENT_QUOTES, 'UTF-8');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ACHA · Jugadores (MongoDB)</title>
    <style>
        body   { font-family: system-ui, sans-serif; max-width: 760px; margin: 2rem auto; padding: 0 1rem; color: #1f2937; }
        h1     { font-size: 1.4rem; }
        form.alta { display: grid; gap: .6rem; background: #f0fdf4; padding: 1rem; border-radius: 10px; border: 1px solid #dcfce7; }
        input  { padding: .5rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 1rem; }
        button { padding: .5rem .7rem; border: 0; border-radius: 6px; background: #16a34a; color: #fff; font-size: 1rem; cursor: pointer; }
        table  { width: 100%; border-collapse: collapse; margin-top: 1.5rem; }
        th, td { text-align: left; padding: .5rem .6rem; border-bottom: 1px solid #e5e7eb; }
        th     { background: #f1f5f9; }
        .msg   { margin: 1rem 0; padding: .6rem .8rem; background: #f0fdf4; border-left: 4px solid #16a34a; border-radius: 4px; }
        .del   { background: #dc2626; }
    </style>
</head>
<body>
    <h1>♟ Jugadores de la ACHA — Modelo Documental (MongoDB)</h1>

    <?php if ($mensaje !== ''): ?>
        <p class="msg"><?= e($mensaje) ?></p>
    <?php endif; ?>

    <form class="alta" method="post">
        <input type="hidden" name="accion" value="crear">
        <input type="text"  name="nombre_apellido" placeholder="Nombre y apellido *" required>
        <input type="email" name="email"           placeholder="Email *"            required>
        <input type="text"  name="dni"             placeholder="DNI *"              required>
        <input type="text"  name="id_fide"         placeholder="ID FIDE (opcional)">
        <input type="text"  name="ciudad"          placeholder="Ciudad (opcional)">
        <button type="submit">Registrar jugador</button>
    </form>

    <table>
        <thead>
            <tr>
                <th>_id</th>
                <th>Nombre y apellido</th>
                <th>Email</th>
                <th>DNI</th>
                <th>ID FIDE</th>
                <th>Ciudad</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($jugadores as $j): ?>
                <tr>
                    <!-- _id es un objeto ObjectId; lo convertimos a string -->
                    <td><?= e((string) $j['_id']) ?></td>
                    <td><?= e($j['nombre_apellido'] ?? '') ?></td>
                    <td><?= e($j['email'] ?? '') ?></td>
                    <td><?= e($j['dni'] ?? '') ?></td>
                    <!-- id_fide puede no existir en el documento -->
                    <td><?= e($j['id_fide'] ?? '') ?: '—' ?></td>
                    <td><?= e($j['ciudad'] ?? '') ?: '—' ?></td>
                    <td>
                        <form method="post" onsubmit="return confirm('¿Eliminar jugador?');">
                            <input type="hidden" name="accion" value="borrar">
                            <input type="hidden" name="id" value="<?= e((string) $j['_id']) ?>">
                            <button class="del" type="submit">Borrar</button>
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</body>
</html>
