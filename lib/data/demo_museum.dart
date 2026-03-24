import '../models/museum_models.dart';
import '../services/museum_repository.dart';

class DemoMuseumRepository implements MuseumRepository {
  const DemoMuseumRepository();

  @override
  Future<List<MuseumRoom>> fetchRooms() async {
    return demoRooms;
  }
}

final List<MuseumRoom> demoRooms = <MuseumRoom>[
  MuseumRoom.fromJson(<String, dynamic>{
    'id': 'sala-origen',
    'title': 'Sala Origen',
    'subtitle': 'Rituales, territorio y memoria',
    'accent': '#2D6A4F',
    'coverUrl':
        'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=1200&q=80',
    'exhibits': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'origen-1',
        'title': 'Vasija ceremonial',
        'subtitle': 'Siglo XII',
        'description':
            'Fotografia real del catalogo para sustituir el panel generado por codigo.',
        'accent': '#2D6A4F',
        'mediaType': 'image',
        'mediaUrl':
            'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=1600&q=80',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=480&q=80',
      },
      <String, dynamic>{
        'id': 'origen-2',
        'title': 'Recorrido ritual',
        'subtitle': 'Video curatorial',
        'description':
            'Ejemplo de pieza en video. La app muestra poster en miniatura y reproduce el video en la vista principal.',
        'accent': '#1B4332',
        'mediaType': 'video',
        'mediaUrl': 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?auto=format&fit=crop&w=900&q=80',
      },
      <String, dynamic>{
        'id': 'origen-3',
        'title': 'Mapa de rutas',
        'subtitle': 'Reconstruccion',
        'description':
            'Otra imagen remota lista para venir de la API o de tu propio almacenamiento.',
        'accent': '#40916C',
        'mediaType': 'image',
        'mediaUrl':
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=1600&q=80',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=480&q=80',
      },
    ],
  }),
  MuseumRoom.fromJson(<String, dynamic>{
    'id': 'sala-luz',
    'title': 'Sala Luz',
    'subtitle': 'Fotografia, sombras y tiempo',
    'accent': '#0B7285',
    'coverUrl':
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    'exhibits': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'luz-1',
        'title': 'Placa de plata',
        'subtitle': '1903',
        'description':
            'Imagen en alta resolucion servida por URL, ideal para reemplazar assets locales.',
        'accent': '#0B7285',
        'mediaType': 'image',
        'mediaUrl':
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1600&q=80',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=480&q=80',
      },
      <String, dynamic>{
        'id': 'luz-2',
        'title': 'Sombras en sala',
        'subtitle': 'Instalacion',
        'description':
            'Puedes mezclar fotos y videos dentro de una misma sala sin tocar la navegacion.',
        'accent': '#1971C2',
        'mediaType': 'image',
        'mediaUrl':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1600&q=80',
        'thumbnailUrl':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=480&q=80',
      },
    ],
  }),
];
