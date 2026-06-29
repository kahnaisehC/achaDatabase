/**
 * PASO 4 · Cloud Firestore desde Node.js (mismo SDK modular).
 * ------------------------------------------------------------
 * Instalación:   npm install        (usa package.json)
 * Ejecución:     node firestore_node.js
 *
 * Hace dos cosas:
 *   1) Inserta un jugador con addDoc.
 *   2) Queda ESCUCHANDO la colección en tiempo real con onSnapshot:
 *      mientras el proceso siga vivo, cualquier cambio (desde acá,
 *      desde el navegador o desde la consola de Firebase) se imprime
 *      al instante.
 */

import { initializeApp } from "firebase/app";
import {
    getFirestore, collection, addDoc, onSnapshot,
    query, orderBy, serverTimestamp
} from "firebase/firestore";

// Config de TU proyecto (Consola de Firebase).
const firebaseConfig = {
    apiKey:            "TU_API_KEY",
    authDomain:        "TU_PROYECTO.firebaseapp.com",
    projectId:         "TU_PROYECTO",
    storageBucket:     "TU_PROYECTO.appspot.com",
    messagingSenderId: "TU_SENDER_ID",
    appId:             "TU_APP_ID"
};

const app = initializeApp(firebaseConfig);
const db  = getFirestore(app);

// ---------- 1) INSERCIÓN (CREATE) ----------
async function registrarJugador(jugador) {
    const ref = await addDoc(collection(db, "jugadores"), {
        ...jugador,
        creado_en: serverTimestamp()
    });
    console.log(`Jugador creado con id: ${ref.id}`);
    return ref.id;
}

// ---------- 2) CONSULTA EN TIEMPO REAL (READ) ----------
function escucharJugadores() {
    const q = query(collection(db, "jugadores"), orderBy("creado_en", "desc"));

    // onSnapshot devuelve una función para CANCELAR la suscripción.
    return onSnapshot(q, (snapshot) => {
        console.log("\n=== Lista de jugadores  ===");
        snapshot.forEach((doc) => {
            const j = doc.data();
            console.log(`• ${j.nombre_apellido}  ${j.id_fide ? "(FIDE " + j.id_fide + ")" : "(sin FIDE)"}`);
        });
    });
}

// Arrancamos: primero escuchamos, luego insertamos uno de prueba.
escucharJugadores();
await registrarJugador({
    nombre_apellido: "Hikaru Nakamura",
    email: "hikaru@acha.org",
    dni: "12345678",
    id_fide: "2016192",
    ciudad: "Resistencia"
});
