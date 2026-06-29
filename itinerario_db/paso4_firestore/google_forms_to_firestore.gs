/**
 * GOOGLE APPS SCRIPT — Formulario de inscripción → Firestore
 * -----------------------------------------------------------
 * CÓMO USARLO:
 *   1. Crear un Google Form con estos campos (los nombres deben coincidir exactamente):
 *        - "Apellido"          (respuesta corta, obligatorio)
 *        - "Nombre"            (respuesta corta, obligatorio)
 *        - "DNI"               (respuesta corta, obligatorio)
 *        - "Fecha de nacimiento" (fecha, obligatorio)
 *        - "Teléfono"          (respuesta corta, obligatorio)
 *        - "ID FIDE"           (respuesta corta, opcional)
 *        - "Torneo"            (lista desplegable con los torneos disponibles)
 *
 *   2. En el formulario: Respuestas → icono de Google Sheets → crear hoja vinculada.
 *
 *   3. En la hoja: Extensiones → Apps Script → pegar este código.
 *
 *   4. En Apps Script: Activadores (ícono reloj) → Agregar activador:
 *        Función:       onFormSubmit
 *        Evento:        Al enviar formulario
 *
 *   5. Autorizar el script cuando lo pida Google.
 *
 * REGLAS DE FIRESTORE:
 *   Para que el API key pueda escribir sin autenticación, asegurate de tener
 *   en la consola de Firebase → Firestore → Reglas:
 *
 *     rules_version = '2';
 *     service cloud.firestore {
 *       match /databases/{database}/documents {
 *         match /inscripciones/{doc} {
 *           allow write: if true;   // solo la colección de inscripciones
 *           allow read:  if true;
 *         }
 *       }
 *     }
 */

// ── Configuración del proyecto Firebase ──────────────────────────────────────
const FIREBASE_PROJECT_ID = "chess-43db0";
const FIREBASE_API_KEY    = "AIzaSyArxoIlnzo9CJznlnNPQ4x0cRUVskX0uWE";
const COLECCION           = "inscripciones";   // nombre de la colección en Firestore
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Se ejecuta automáticamente cada vez que alguien envía el formulario.
 * @param {GoogleAppsScript.Events.SheetsOnFormSubmit} e
 */
function onFormSubmit(e) {
  const r = e.namedValues; // { "Apellido": ["García"], "DNI": ["28541632"], … }

  const apellido        = (r["Apellido"]             ?? [""])[0].trim();
  const nombre          = (r["Nombre"]               ?? [""])[0].trim();
  const dni             = (r["DNI"]                  ?? [""])[0].trim();
  const fechaNacimiento = (r["Fecha de nacimiento"]  ?? [""])[0].trim();
  const telefono        = (r["Teléfono"]             ?? [""])[0].trim();
  const idFide          = (r["ID FIDE"]              ?? [""])[0].trim();
  const torneo          = (r["Torneo"]               ?? [""])[0].trim();

  // Construcción del documento en formato Firestore REST
  const documento = {
    fields: {
      apellido:         { stringValue: apellido },
      nombre:           { stringValue: nombre },
      dni:              { stringValue: dni },
      fecha_nacimiento: { stringValue: fechaNacimiento },
      telefono:         { stringValue: telefono },
      torneo:           { stringValue: torneo },
      paga_multa:       { booleanValue: false },
      inscripto_en:     { timestampValue: new Date().toISOString() }
    }
  };

  // El ID FIDE es opcional — solo se agrega si el jugador lo completó
  if (idFide) {
    documento.fields.id_fide = { stringValue: idFide };
  }

  const url = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/${COLECCION}?key=${FIREBASE_API_KEY}`;

  const opciones = {
    method:          "post",
    contentType:     "application/json",
    payload:         JSON.stringify(documento),
    muteHttpExceptions: true   // para poder leer el error sin que el script explote
  };

  const respuesta = UrlFetchApp.fetch(url, opciones);
  const codigo    = respuesta.getResponseCode();
  const cuerpo    = respuesta.getContentText();

  if (codigo === 200 || codigo === 201) {
    Logger.log(`OK — inscripción de ${apellido}, ${nombre} guardada en Firestore.`);
  } else {
    Logger.log(`ERROR ${codigo}: ${cuerpo}`);
    // Opcional: mandar un mail de alerta al organizador
    // MailApp.sendEmail("organizador@acha.org", "Error en inscripción", cuerpo);
  }
}

/**
 * Función de prueba — ejecutar manualmente desde el editor de Apps Script
 * para verificar que la conexión con Firestore funciona antes de activar el trigger.
 */
function testConexion() {
  const eventoSimulado = {
    namedValues: {
      "Apellido":            ["Prueba"],
      "Nombre":              ["Test"],
      "DNI":                 ["99999999"],
      "Fecha de nacimiento": ["2000-01-01"],
      "Teléfono":            ["3624000000"],
      "ID FIDE":             [""],
      "Torneo":              ["Torneo Apertura Chaco 2025"]
    }
  };
  onFormSubmit(eventoSimulado);
}
