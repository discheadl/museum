# Museum (Flutter + Node.js API)

Base para una app de museo en horizontal que ahora consume imagenes y videos reales desde una API sencilla en Node.js/Express.

## Que se agrego

- API Express en `api/` con:
  - `GET /api/health`
  - `GET /api/rooms`
- Servicio HTTP en Flutter (`lib/services/museum_api_service.dart`)
- Modelos listos para `image` y `video`
- `MuseumArtPanel` reescrito para mostrar:
  - `Image.network(...)`
  - `VideoPlayer(...)` en la vista principal de una pieza
- `demo_museum.dart` convertido en repositorio demo con URLs reales, util para pruebas

## 1. Levantar la API

```bash
cd api
npm install
npm run dev
```

La API queda por defecto en `http://localhost:4000`.

### Opcion recomendada: dejar la API corriendo con Docker Compose

Si quieres evitar entrar a `api/` y levantar Node manualmente cada vez, desde la raiz del proyecto puedes usar:

```bash
docker compose up -d --build
```

Eso deja la API corriendo en segundo plano en `http://localhost:4000`.
Mientras Docker Desktop siga abierto, la API seguira disponible aunque cierres VS Code.

Comandos utiles:

```bash
docker compose logs -f api
docker compose restart api
docker compose down
```

Para volver a iniciarla mas adelante sin reconstruir:

```bash
docker compose up -d
```

## 2. Correr Flutter contra la API

```bash
flutter pub get
flutter run --dart-define=MUSEUM_API_BASE_URL=http://localhost:4000
```

En Android emulator normalmente conviene:

```bash
flutter run --dart-define=MUSEUM_API_BASE_URL=http://10.0.2.2:4000
```

En un dispositivo fisico usa la IP de tu maquina, por ejemplo:

```bash
flutter run --dart-define=MUSEUM_API_BASE_URL=http://192.168.1.25:4000
```

## 3. Esquema que consume Flutter

La app espera esta estructura:

```json
{
  "rooms": [
    {
      "id": "sala-origen",
      "title": "Sala Origen",
      "subtitle": "Rituales, territorio y memoria",
      "accent": "#2D6A4F",
      "coverUrl": "https://...",
      "exhibits": [
        {
          "id": "origen-1",
          "title": "Vasija ceremonial",
          "subtitle": "Siglo XII",
          "description": "Texto corto",
          "accent": "#2D6A4F",
          "mediaType": "image",
          "mediaUrl": "https://...",
          "thumbnailUrl": "https://..."
        }
      ]
    }
  ]
}
```

## 4. Donde se hizo cada cambio

- API Node.js/Express: [api/src/server.js](/Users/arne/museum/api/src/server.js)
- Datos de ejemplo para la API: [api/src/data/museum-data.js](/Users/arne/museum/api/src/data/museum-data.js)
- Servicio HTTP Flutter: [lib/services/museum_api_service.dart](/Users/arne/museum/lib/services/museum_api_service.dart)
- Modelos parseables: [lib/models/museum_models.dart](/Users/arne/museum/lib/models/museum_models.dart)
- Home consumiendo API: [lib/features/home/home_screen.dart](/Users/arne/museum/lib/features/home/home_screen.dart)
- Panel real de imagen/video: [lib/widgets/museum_art_panel.dart](/Users/arne/museum/lib/widgets/museum_art_panel.dart)

## 5. Como reemplazar tus URLs por archivos propios

Si quieres servir tus propios archivos desde este repo:

1. Coloca fotos y videos dentro de `api/public/media/`
2. Cambia las URLs en `api/src/data/museum-data.js`
3. Usa rutas como:
   - `http://localhost:4000/media/salas/origen/foto-1.jpg`
   - `http://localhost:4000/media/salas/origen/video-1.mp4`

Hay una nota rapida en [api/public/media/README.md](/Users/arne/museum/api/public/media/README.md).

## Pruebas

```bash
flutter test
```
