import 'package:flutter/material.dart';

enum VirtualTourHotspotKind { navigation, info }

@immutable
class VirtualTourScene {
  const VirtualTourScene({
    required this.id,
    required this.title,
    required this.caption,
    required this.assetPath,
    required this.initialLongitude,
    required this.initialLatitude,
    required this.hotspots,
    this.panoramaUrl,
  });

  final String id;
  final String title;
  final String caption;
  final String assetPath;
  final double initialLongitude;
  final double initialLatitude;
  final List<VirtualTourHotspot> hotspots;

  /// URL remota del panorama (Supabase). Si esta presente y no es vacia,
  /// debe usarse en lugar del [assetPath] local.
  final String? panoramaUrl;

  VirtualTourScene copyWith({
    String? title,
    String? caption,
    String? panoramaUrl,
  }) {
    return VirtualTourScene(
      id: id,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      assetPath: assetPath,
      initialLongitude: initialLongitude,
      initialLatitude: initialLatitude,
      hotspots: hotspots,
      panoramaUrl: panoramaUrl ?? this.panoramaUrl,
    );
  }
}

@immutable
class VirtualTourHotspot {
  const VirtualTourHotspot.navigation({
    required this.id,
    required this.label,
    required this.targetSceneId,
    required this.longitude,
    required this.latitude,
    required this.tint,
  }) : kind = VirtualTourHotspotKind.navigation,
       artwork = null;

  const VirtualTourHotspot.info({
    required this.id,
    required this.label,
    required this.artwork,
    required this.longitude,
    required this.latitude,
    required this.tint,
  }) : kind = VirtualTourHotspotKind.info,
       targetSceneId = null;

  final String id;
  final String label;
  final VirtualTourHotspotKind kind;
  final String? targetSceneId;
  final VirtualTourArtwork? artwork;
  final double longitude;
  final double latitude;
  final Color tint;
}

@immutable
class VirtualTourArtwork {
  const VirtualTourArtwork({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.author,
    required this.dateLabel,
    required this.locationLabel,
    required this.context,
    required this.imagePath,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String author;
  final String dateLabel;
  final String locationLabel;
  final String context;
  final String imagePath;
}

const List<VirtualTourScene> demoVirtualTourScenes = <VirtualTourScene>[
  VirtualTourScene(
    id: 'vestibulo',
    title: 'Vestibulo',
    caption: 'Entrada principal del museo y punto de orientacion.',
    assetPath: 'assets/panoramas/vestibulo.jpg',
    initialLongitude: -12,
    initialLatitude: 10,
    hotspots: <VirtualTourHotspot>[
      VirtualTourHotspot.navigation(
        id: 'vestibulo_galeria',
        label: 'Ir a galeria central',
        targetSceneId: 'galeria',
        longitude: 6,
        latitude: -8,
        tint: Color(0xFF2A9D8F),
      ),
      VirtualTourHotspot.navigation(
        id: 'vestibulo_pasillo',
        label: 'Pasillo lateral',
        targetSceneId: 'pasillo',
        longitude: 112,
        latitude: -10,
        tint: Color(0xFF2A9D8F),
      ),
      VirtualTourHotspot.info(
        id: 'vestibulo_mapa',
        label: 'Mapa de bienvenida',
        longitude: -38,
        latitude: 10,
        tint: Color(0xFFF4A261),
        artwork: VirtualTourArtwork(
          id: 'mapa-bienvenida',
          title: 'Mapa de bienvenida',
          subtitle: 'Panel de orientacion del recorrido',
          description:
              'Panel introductorio que explica el sentido general del museo, el recorrido y la distribucion de las salas.',
          author: 'Equipo curatorial',
          dateLabel: '2026',
          locationLabel: 'Vestibulo',
          context:
              'Se recomienda usar esta pieza como punto de entrada para visitantes nuevos. Puedes reemplazar la imagen por una foto real o por la ficha oficial de la obra.',
          imagePath: 'assets/panoramas/vestibulo.jpg',
        ),
      ),
    ],
  ),
  VirtualTourScene(
    id: 'galeria',
    title: 'Galeria central',
    caption: 'Sala principal con piezas destacadas y conexion al mirador.',
    assetPath: 'assets/panoramas/galeria.jpg',
    initialLongitude: 28,
    initialLatitude: 10,
    hotspots: <VirtualTourHotspot>[
      VirtualTourHotspot.navigation(
        id: 'galeria_vestibulo',
        label: 'Regresar al vestibulo',
        targetSceneId: 'vestibulo',
        longitude: -134,
        latitude: -8,
        tint: Color(0xFF2A9D8F),
      ),
      VirtualTourHotspot.navigation(
        id: 'galeria_mirador',
        label: 'Seguir al mirador',
        targetSceneId: 'mirador',
        longitude: 76,
        latitude: -4,
        tint: Color(0xFF2A9D8F),
      ),
      VirtualTourHotspot.info(
        id: 'galeria_pieza_1',
        label: 'Obra destacada',
        longitude: 14,
        latitude: 8,
        tint: Color(0xFFF4A261),
        artwork: VirtualTourArtwork(
          id: 'obra-destacada',
          title: 'Coleccion de acceso',
          subtitle: 'Serie introductoria',
          description:
              'Conjunto de piezas que resume los ejes narrativos del museo: territorio, memoria e identidad visual.',
          author: 'Coleccion permanente',
          dateLabel: 'Siglos XIX-XXI',
          locationLabel: 'Galeria central',
          context:
              'Este hotspot representa un punto de informacion de obra. Puedes usar imagen local o URL remota en `imagePath` para mostrar una ficha detallada.',
          imagePath: 'assets/panoramas/galeria.jpg',
        ),
      ),
    ],
  ),
  VirtualTourScene(
    id: 'pasillo',
    title: 'Pasillo lateral',
    caption: 'Zona de transicion con lectura contextual y acceso cruzado.',
    assetPath: 'assets/panoramas/pasillo.jpg',
    initialLongitude: 148,
    initialLatitude: 10,
    hotspots: <VirtualTourHotspot>[
      VirtualTourHotspot.navigation(
        id: 'pasillo_vestibulo',
        label: 'Volver al vestibulo',
        targetSceneId: 'vestibulo',
        longitude: -32,
        latitude: -8,
        tint: Color(0xFF2A9D8F),
      ),
      VirtualTourHotspot.navigation(
        id: 'pasillo_mirador',
        label: 'Cruzar al mirador',
        targetSceneId: 'mirador',
        longitude: 104,
        latitude: -6,
        tint: Color(0xFF2A9D8F),
      ),
      VirtualTourHotspot.info(
        id: 'pasillo_linea_tiempo',
        label: 'Linea de tiempo',
        longitude: 66,
        latitude: 11,
        tint: Color(0xFFF4A261),
        artwork: VirtualTourArtwork(
          id: 'linea-tiempo',
          title: 'Linea de tiempo del museo',
          subtitle: 'Cronologia de colecciones y expansion',
          description:
              'Resume los momentos clave de adquisicion, restauracion y apertura de salas del museo.',
          author: 'Archivo del museo',
          dateLabel: '1890-2026',
          locationLabel: 'Pasillo lateral',
          context:
              'Este ejemplo funciona bien para piezas documentales, paneles de texto o archivos historicos que necesiten contexto adicional.',
          imagePath: 'assets/panoramas/pasillo.jpg',
        ),
      ),
    ],
  ),
  VirtualTourScene(
    id: 'mirador',
    title: 'Mirador',
    caption: 'Cierre del circuito con vista general y retorno a otras salas.',
    assetPath: 'assets/panoramas/mirador.jpg',
    initialLongitude: 24,
    initialLatitude: 10,
    hotspots: <VirtualTourHotspot>[
      VirtualTourHotspot.navigation(
        id: 'mirador_galeria',
        label: 'Volver a galeria',
        targetSceneId: 'galeria',
        longitude: -90,
        latitude: -10,
        tint: Color(0xFF2A9D8F),
      ),
      VirtualTourHotspot.navigation(
        id: 'mirador_pasillo',
        label: 'Ir al pasillo',
        targetSceneId: 'pasillo',
        longitude: 118,
        latitude: -12,
        tint: Color(0xFF2A9D8F),
      ),
      VirtualTourHotspot.info(
        id: 'mirador_contexto',
        label: 'Contexto arquitectonico',
        longitude: 0,
        latitude: 16,
        tint: Color(0xFFF4A261),
        artwork: VirtualTourArtwork(
          id: 'contexto-arquitectonico',
          title: 'Arquitectura del mirador',
          subtitle: 'Lectura espacial del edificio',
          description:
              'Describe la relacion entre circulacion, iluminacion y puntos de observacion dentro del recorrido del museo.',
          author: 'Area de mediacion',
          dateLabel: '2026',
          locationLabel: 'Mirador',
          context:
              'Los hotspots naranjas deben usarse para abrir una ficha en overlay. Si necesitas una pieza con varios recursos, puedes extender este modelo con audio, video o enlaces.',
          imagePath: 'assets/panoramas/mirador.jpg',
        ),
      ),
    ],
  ),
];
