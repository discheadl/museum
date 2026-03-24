# Museum (Flutter)

Base para una app de museo pensada para usarse en horizontal (landscape) y navegar por imagenes.

## Que incluye esta base

- Orientacion bloqueada a horizontal desde `lib/main.dart` (landscapeLeft/right).
- Navegacion principal por swipe (PageView) con “tarjetas tipo imagen”:
  - Home: carrusel de salas (tap abre la sala).
  - Sala: piezas navegables por swipe + thumbnails para saltar directo.
- “Imagen” placeholder generada en codigo (`MuseumArtPanel`) lista para reemplazarse por fotos reales.
- Datos demo en memoria para que el flujo funcione desde el dia 1.

## Como correrlo

```bash
flutter pub get
flutter run
```

Tests:

```bash
flutter test
```

## Estructura de carpetas

- `lib/app/`: `MuseumApp` y tema.
- `lib/features/`: pantallas por feature (`home/`, `room/`).
- `lib/models/`: modelos (`MuseumRoom`, `MuseumExhibit`).
- `lib/data/`: datos demo (luego puedes conectarlo a API o DB).
- `lib/widgets/`: widgets compartidos (placeholder de “imagen”).

## Reemplazar placeholders por imagenes reales

Ahora mismo las tarjetas usan `MuseumArtPanel` como placeholder visual.
Para usar imagenes reales lo comun es:

1. Agregar assets:

   - Crea `assets/images/` y coloca tus imagenes.
   - Declara los assets en `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

2. Cambiar el widget:

   - Reemplaza `MuseumArtPanel(...)` por `Image.asset(...)` o `Image.network(...)` en:
     - `lib/features/home/widgets/room_card.dart`
     - `lib/features/room/widgets/exhibit_thumbnail.dart`
     - `lib/features/room/room_screen.dart`

## Notas de orientacion

- iOS ya permite landscape en `ios/Runner/Info.plist`.
- Android se bloquea via `SystemChrome.setPreferredOrientations(...)` en `lib/main.dart`.

## Siguientes pasos tipicos

- Definir el tipo de menu (overlay flotante, mapa por salas, barra lateral, etc.).
- Sustituir `lib/data/demo_museum.dart` por tu catalogo real.
- Agregar rutas/navegacion nombrada si el proyecto crece.
