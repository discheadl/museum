import 'package:flutter/material.dart';

import '../models/museum_models.dart';

class DemoMuseum {
  static List<MuseumRoom> rooms() {
    return const <MuseumRoom>[
      MuseumRoom(
        id: 'sala-origen',
        title: 'Sala Origen',
        subtitle: 'Rituales, territorio y memoria',
        accent: Color(0xFF2D6A4F),
        exhibits: <MuseumExhibit>[
          MuseumExhibit(
            id: 'origen-1',
            title: 'Vasija ceremonial',
            subtitle: 'Siglo XII',
            description:
                'Una pieza de referencia para introducir la colección. En esta base la "imagen" es un panel generado; más adelante se reemplaza por assets o fotos.',
            accent: Color(0xFF2D6A4F),
          ),
          MuseumExhibit(
            id: 'origen-2',
            title: 'Máscara de obsidiana',
            subtitle: 'Siglo XIV',
            description:
                'Pensada para navegación por swipe en horizontal, con textos cortos y claros.',
            accent: Color(0xFF1B4332),
          ),
          MuseumExhibit(
            id: 'origen-3',
            title: 'Mapa de rutas',
            subtitle: 'Reconstrucción',
            description:
                'Placeholder para un futuro "mapa" interactivo o menú visual.',
            accent: Color(0xFF40916C),
          ),
        ],
      ),
      MuseumRoom(
        id: 'sala-luz',
        title: 'Sala Luz',
        subtitle: 'Fotografía, sombras y tiempo',
        accent: Color(0xFF0B7285),
        exhibits: <MuseumExhibit>[
          MuseumExhibit(
            id: 'luz-1',
            title: 'Placa de plata',
            subtitle: '1903',
            description:
                'Estructura preparada para que cada pieza tenga su imagen, título y descripción.',
            accent: Color(0xFF0B7285),
          ),
          MuseumExhibit(
            id: 'luz-2',
            title: 'Sala oscura',
            subtitle: 'Instalación',
            description:
                'Los "thumbnails" inferiores sirven como navegación rápida por imágenes.',
            accent: Color(0xFF1971C2),
          ),
        ],
      ),
      MuseumRoom(
        id: 'sala-materia',
        title: 'Sala Materia',
        subtitle: 'Texturas, metales y escala',
        accent: Color(0xFF9C6644),
        exhibits: <MuseumExhibit>[
          MuseumExhibit(
            id: 'materia-1',
            title: 'Herramienta de bronce',
            subtitle: 'Periodo clásico',
            description:
                'Este es un demo de contenido: reemplázalo por tu catálogo real.',
            accent: Color(0xFF9C6644),
          ),
          MuseumExhibit(
            id: 'materia-2',
            title: 'Fragmento de mural',
            subtitle: 'Pigmentos naturales',
            description:
                'La UI está pensada en formato horizontal desde el inicio.',
            accent: Color(0xFFB08968),
          ),
        ],
      ),
    ];
  }
}
