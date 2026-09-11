# Gestor Inmobiliario

Aplicación móvil en **Flutter** conectada a una **API REST en Node.js (Express) con MongoDB**,
desarrollada con flujo de trabajo **GitFlow**.

| Fase | Aprendiz A | Aprendiz B |
|------|------------|------------|
| 1. Frontend (Flutter) | Login, registro y recuperación de contraseña | Lista de agenda, formulario de nueva tarea y perfil de usuario |
| 2. Backend y BD | Colección de usuarios, endpoints de autenticación | Colección de tareas, endpoints CRUD |
| 3. Integración y despliegue | Login y perfil conectados por HTTP | Lista y creación de tareas conectadas por HTTP |

## Arquitectura

```
Flutter (Android / Web)  ──HTTP + JWT──▶  API Node.js (Express)  ──Mongoose──▶  MongoDB
lib/core/api/api_client.dart              backend/src/                         users, tasks
```

```
.
├── lib/
│   ├── core/api/          # ApiClient (http), URL base y sesión guardada
│   ├── core/state/        # UserStore (auth/perfil) y AgendaStore (tareas) → consumen la API
│   └── features/auth/     # Pantallas: login, registro, recuperación, perfil, agenda, formulario
├── test/                  # Tests de widgets con un backend falso (test/support/fake_api.dart)
├── backend/
│   ├── src/models/        # User y Task (Mongoose)
│   ├── src/controllers/   # Lógica de auth, perfil y tareas
│   ├── src/routes/        # /api/auth, /api/users, /api/tasks
│   └── tests/             # Tests de integración de la API (node:test + supertest)
├── Dockerfile             # Build de Flutter Web + nginx (servicio web en Railway)
└── deploy/nginx.conf.template
```

## API REST

URL base: `http://localhost:3000/api` en local. Las rutas marcadas con 🔒 requieren el header
`Authorization: Bearer <token>`.

### Autenticación y perfil

| Método | Ruta | Cuerpo | Respuesta |
|--------|------|--------|-----------|
| POST | `/auth/register` | `fullName, email, phone, password` | `201 { token, user }` |
| POST | `/auth/login` | `email, password` | `200 { token, user }` |
| POST | `/auth/forgot-password` | `email` | `200` y envía un código de 6 dígitos (vence en 15 min) |
| POST | `/auth/reset-password` | `email, code, password` | `200` |
| GET 🔒 | `/users/me` | — | perfil del usuario |
| PUT 🔒 | `/users/me` | `fullName, email, phone, role, office` | perfil actualizado |
| PUT 🔒 | `/users/me/password` | `currentPassword, newPassword` | `200` / `400` si la actual no coincide |

### Tareas (agenda)

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET 🔒 | `/tasks?status=pending&from=…&to=…` | Lista las tareas del usuario, ordenadas por fecha |
| POST 🔒 | `/tasks` | Crea una tarea |
| GET 🔒 | `/tasks/:id` | Consulta una tarea |
| PUT 🔒 | `/tasks/:id` | Actualiza una tarea |
| PATCH 🔒 | `/tasks/:id/status` | Cambia el estado (`pending`, `done`, `cancelled`) |
| DELETE 🔒 | `/tasks/:id` | Elimina una tarea |

Tarea: `title, client, property, dateTime (ISO 8601), type (visit|signing|call|appraisal), status, notes`.
Cada usuario solo ve y modifica sus propias tareas. Los errores responden `{ "message": "..." }`.

## Ejecutar en local

Requisitos: Node.js 20+, MongoDB y Flutter 3.44.

```bash
# 1. API
cd backend
cp .env.example .env        # ajusta MONGODB_URI y JWT_SECRET si hace falta
npm install
npm run dev                 # http://localhost:3000

# 2. App (en otra terminal, desde la raíz)
flutter pub get
flutter run                 # Android emulador usa http://10.0.2.2:3000/api automáticamente
flutter run -d chrome       # Web usa http://localhost:3000/api
```

Para apuntar a otra API: `flutter run --dart-define=API_URL=https://mi-api.up.railway.app/api`.

Sin SMTP configurado, el código de recuperación de contraseña se imprime en la consola del backend
(`[recuperación] Código para ...`). Para enviarlo por correo configura `SMTP_*` en `.env`.

## Tests

```bash
cd backend && npm test      # API contra MongoDB local (base gestor_inmobiliario_test)
flutter test                # Pantallas contra un backend falso en memoria
```

## Despliegue en Railway

El repositorio es un monorepo: se crean **tres servicios** en el mismo proyecto de Railway.

1. **MongoDB**: *New → Database → MongoDB*.
2. **API** (desde este repo de GitHub):
   - *Settings → Root Directory*: `/backend` (Railway detecta Node y ejecuta `npm start`).
   - *Variables*:
     - `MONGODB_URI` = `${{MongoDB.MONGO_URL}}`
     - `JWT_SECRET` = una cadena larga y aleatoria
     - `NODE_ENV` = `production`
     - `CORS_ORIGIN` = URL del servicio web (o `*`)
   - *Networking → Generate Domain*. Comprueba `https://<api>.up.railway.app/api/health`.
3. **Web** (desde el mismo repo):
   - *Root Directory*: `/` (usa el `Dockerfile` de la raíz).
   - *Variables*: `API_URL` = `https://<api>.up.railway.app/api`
   - *Networking → Generate Domain*.

Para generar el APK apuntando a producción:

```bash
flutter build apk --release --dart-define=API_URL=https://<api>.up.railway.app/api
```

## GitFlow

- `main`: versiones estables (etiquetas `v1.0.0`, …).
- `develop`: integración de funcionalidades.
- `feature/*`: una rama por módulo, fusionada en `develop` con `--no-ff`:
  `feature/fase1-frontend`, `feature/backend-auth`, `feature/backend-tasks`,
  `feature/integracion-auth`, `feature/integracion-agenda`, `feature/despliegue-railway`.
- `release/*`: preparación de una versión antes de fusionar en `main` y `develop`.
