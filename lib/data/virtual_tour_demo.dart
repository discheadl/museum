import 'package:flutter/material.dart';

@immutable
class VirtualTourScene {
  const VirtualTourScene({
    required this.id,
    required this.title,
    required this.caption,
    required this.assetPath,
    required this.imageUrl,
    required this.sourceUrl,
    required this.initialLongitude,
    required this.initialLatitude,
    required this.hotspots,
  });

  final String id;
  final String title;
  final String caption;
  final String assetPath;
  final String imageUrl;
  final String sourceUrl;
  final double initialLongitude;
  final double initialLatitude;
  final List<VirtualTourHotspot> hotspots;
}

@immutable
class VirtualTourHotspot {
  const VirtualTourHotspot({
    required this.label,
    required this.targetSceneId,
    required this.longitude,
    required this.latitude,
    required this.tint,
  });

  final String label;
  final String targetSceneId;
  final double longitude;
  final double latitude;
  final Color tint;
}

const List<VirtualTourScene> demoVirtualTourScenes = <VirtualTourScene>[
  VirtualTourScene(
    id: 'vestibulo',
    title: 'Vestibulo',
    caption: 'Entrada principal del recorrido. Usa los puntos para moverte.',
    assetPath: 'assets/panoramas/vestibulo.jpg',
    imageUrl:
        'https://commons.wikimedia.org/wiki/Special:FilePath/Bexhill%20Railway%20Station%20%28360%20panorama%29.jpg',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Bexhill_Railway_Station_(360_panorama).jpg',
    initialLongitude: -12,
    initialLatitude: 10,
    hotspots: <VirtualTourHotspot>[
      VirtualTourHotspot(
        label: 'Ir a la galeria',
        targetSceneId: 'galeria',
        longitude: 6,
        latitude: -8,
        tint: Color(0xFFB85C38),
      ),
      VirtualTourHotspot(
        label: 'Pasillo lateral',
        targetSceneId: 'pasillo',
        longitude: 112,
        latitude: -10,
        tint: Color(0xFF386641),
      ),
    ],
  ),
  VirtualTourScene(
    id: 'galeria',
    title: 'Galeria de acceso',
    caption:
        'Acceso panoramico limpio al museo para navegar sin artefactos negros.',
    assetPath: 'assets/panoramas/galeria.jpg',
    imageUrl:
        'https://commons.wikimedia.org/wiki/Special:FilePath/360%20panorama%20Entrance%20mall%20side%20National%20Air%20and%20Space%20museum%20Washington%20DC%202025-08-17%2008-25-34%201.jpg',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:360_panorama_Entrance_mall_side_National_Air_and_Space_museum_Washington_DC_2025-08-17_08-25-34_1.jpg',
    initialLongitude: 28,
    initialLatitude: 10,
    hotspots: <VirtualTourHotspot>[
      VirtualTourHotspot(
        label: 'Regresar al vestibulo',
        targetSceneId: 'vestibulo',
        longitude: -134,
        latitude: -8,
        tint: Color(0xFF355070),
      ),
      VirtualTourHotspot(
        label: 'Seguir al mirador',
        targetSceneId: 'mirador',
        longitude: 76,
        latitude: -4,
        tint: Color(0xFFD97706),
      ),
    ],
  ),
  VirtualTourScene(
    id: 'pasillo',
    title: 'Pasillo lateral',
    caption: 'Zona de transicion con otro acceso directo al recorrido.',
    assetPath: 'assets/panoramas/pasillo.jpg',
    imageUrl:
        'https://commons.wikimedia.org/wiki/Special:FilePath/Bexhill%20Station%20Cycle%20Hub%20%28360%20panorama%29.jpg',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Bexhill_Station_Cycle_Hub_(360_panorama).jpg',
    initialLongitude: 148,
    initialLatitude: 10,
    hotspots: <VirtualTourHotspot>[
      VirtualTourHotspot(
        label: 'Volver al vestibulo',
        targetSceneId: 'vestibulo',
        longitude: -32,
        latitude: -8,
        tint: Color(0xFF355070),
      ),
      VirtualTourHotspot(
        label: 'Cruzar al mirador',
        targetSceneId: 'mirador',
        longitude: 104,
        latitude: -6,
        tint: Color(0xFFB85C38),
      ),
    ],
  ),
  VirtualTourScene(
    id: 'mirador',
    title: 'Mirador',
    caption:
        'Ultimo punto del mini tour. Desde aqui puedes cerrar el circuito.',
    assetPath: 'assets/panoramas/mirador.jpg',
    imageUrl:
        'https://commons.wikimedia.org/wiki/Special:FilePath/Footbridge%20Gallery%2C%20Bexhill-on-Sea%20%28360%20panorama%29.jpg',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Footbridge_Gallery,_Bexhill-on-Sea_(360_panorama).jpg',
    initialLongitude: 24,
    initialLatitude: 10,
    hotspots: <VirtualTourHotspot>[
      VirtualTourHotspot(
        label: 'Volver a la galeria',
        targetSceneId: 'galeria',
        longitude: -90,
        latitude: -10,
        tint: Color(0xFF386641),
      ),
      VirtualTourHotspot(
        label: 'Ir al pasillo',
        targetSceneId: 'pasillo',
        longitude: 118,
        latitude: -12,
        tint: Color(0xFF7C3AED),
      ),
    ],
  ),
];
