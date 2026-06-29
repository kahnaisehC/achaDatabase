<?php
/**
 * PASO 1 · Aplicación web en PHP puro + MySQL (PDO).
 * ------------------------------------------------------------
 * Una sola página que:
 *   1. Registra un jugador (formulario POST).
 *   2. Lista todos los jugadores en una tabla HTML.
 *
 * Mantenemos toda la lógica arriba y el HTML abajo para que se lea fácil.
 */

// Traemos la conexión PDO creada en db.php.
$pdo = require __DIR__ . '/db.php';

// Mensaje que mostraremos al usuario (éxito o error).
$mensaje = '';

// ¿El usuario envió el formulario? (método POST)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Tomamos y limpiamos los datos del formulario.
    $nombre = trim($_POST['nombre_apellido'] ?? '');
    $email  = trim($_POST['email'] ?? '');
    $dni    = trim($_POST['dni'] ?? '');
    $fide   = trim($_POST['id_fide'] ?? '');   // puede quedar vacío
    $ciudad = trim($_POST['ciudad'] ?? '');

    // Validación mínima.
    if ($nombre === '' || $email === '' || $dni === '') {
        $mensaje = 'Nombre, email y DNI son obligatorios.';
    } else {
        // CONSULTA PREPARADA: los datos del usuario nunca se
        // concatenan dentro del SQL -> así evitamos inyección SQL.
        $sql = 'INSERT INTO personas (nombre_apellido, email, dni, id_fide, ciudad)
                VALUES (:nombre, :email, :dni, :fide, :ciudad)';
        $stmt = $pdo->prepare($sql);

        try {
            $stmt->execute([
                ':nombre' => $nombre,
                ':email'  => $email,
                ':dni'    => $dni,
                // Si no cargó FIDE guardamos NULL (no string vacío).
                ':fide'   => ($fide === '' ? null : $fide),
                ':ciudad' => ($ciudad === '' ? null : $ciudad),
            ]);
            $mensaje = 'Jugador registrado con éxito.';
        } catch (PDOException $e) {
            // El código 23000 es violación de restricción (ej: email repetido).
            if ($e->getCode() === '23000') {
                $mensaje = 'Ese email ya está registrado.';
            } else {
                $mensaje = 'No se pudo registrar: ' . $e->getMessage();
            }
        }
    }
}

// LISTADO: traemos todos los jugadores ordenados por id descendente.
$jugadores = $pdo->query('SELECT * FROM personas ORDER BY id DESC')->fetchAll();

/**
 * Pequeño helper para escapar texto antes de imprimirlo en HTML.
 * Evita XSS (que alguien inyecte <script> a través de un campo).
 */
function e(?string $valor): string
{
    return htmlspecialchars($valor ?? '', ENT_QUOTES, 'UTF-8');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ACHA · Jugadores (MySQL)</title>
    <style>
        body   { font-family: system-ui, sans-serif; max-width: 760px; margin: 2rem auto; padding: 0 1rem; color: #1f2937; }
        h1     { font-size: 1.4rem; }
        form   { display: grid; gap: .6rem; background: #f9fafb; padding: 1rem; border-radius: 10px; border: 1px solid #e5e7eb; }
        input  { padding: .5rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 1rem; }
        button { padding: .55rem; border: 0; border-radius: 6px; background: #2563eb; color: #fff; font-size: 1rem; cursor: pointer; }
        table  { width: 100%; border-collapse: collapse; margin-top: 1.5rem; }
        th, td { text-align: left; padding: .5rem .6rem; border-bottom: 1px solid #e5e7eb; }
        th     { background: #f1f5f9; }
        .msg   { margin: 1rem 0; padding: .6rem .8rem; background: #ecfeff; border-left: 4px solid #06b6d4; border-radius: 4px; }
    </style>
</head>
<body>
    <h1>♟ Jugadores de la ACHA — Modelo Relacional (MySQL + PDO)</h1>

    <?php if ($mensaje !== ''): ?>
        <p class="msg"><?= e($mensaje) ?></p>
    <?php endif; ?>

    <!-- Formulario de alta -->
    <form method="post">
        <input type="text"  name="nombre_apellido" placeholder="Nombre y apellido *" required>
        <input type="email" name="email"           placeholder="Email *"            required>
        <input type="text"  name="dni"             placeholder="DNI *"              required>
        <input type="text"  name="id_fide"         placeholder="ID FIDE (opcional)">
        <input type="text"  name="ciudad"          placeholder="Ciudad (opcional)">
        <button type="submit">Registrar jugador</button>
    </form>

    <!-- Listado en tabla HTML -->
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Nombre y apellido</th>
                <th>Email</th>
                <th>DNI</th>
                <th>ID FIDE</th>
                <th>Ciudad</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($jugadores)): ?>
                <tr><td colspan="6">Todavía no hay jugadores cargados.</td></tr>
            <?php else: ?>
                <?php foreach ($jugadores as $j): ?>
                    <tr>
                        <td><?= e((string) $j['id']) ?></td>
                        <td><?= e($j['nombre_apellido']) ?></td>
                        <td><?= e($j['email']) ?></td>
                        <td><?= e($j['dni']) ?></td>
                        <td><?= e($j['id_fide']) ?: '—' ?></td>
                        <td><?= e($j['ciudad']) ?: '—' ?></td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</body>
</html>
