export const museumRooms = [
  {
    id: 'sala-origen',
    title: 'Sala Origen',
    subtitle: 'Rituales, territorio y memoria',
    accent: '#2D6A4F',
    coverUrl:
      'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=1200&q=80',
    exhibits: [
      {
        id: 'origen-1',
        title: 'Vasija ceremonial',
        subtitle: 'Siglo XII',
        description:
          'La API ya entrega URLs reales para que Flutter cargue la foto directamente.',
        accent: '#2D6A4F',
        mediaType: 'image',
        mediaUrl:
          'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=1600&q=80',
        thumbnailUrl:
          'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=480&q=80',
      },
      {
        id: 'origen-2',
        title: 'Recorrido ritual',
        subtitle: 'Video curatorial',
        description:
          'Ejemplo de video que la app reproduce en la vista principal y muestra con poster en miniatura.',
        accent: '#1B4332',
        mediaType: 'video',
        mediaUrl: 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
        thumbnailUrl:
          'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?auto=format&fit=crop&w=900&q=80',
      },
      {
        id: 'origen-3',
        title: 'Mapa de rutas',
        subtitle: 'Reconstruccion',
        description:
          'Tercera pieza de ejemplo para mantener el swipe horizontal con datos remotos.',
        accent: '#40916C',
        mediaType: 'image',
        mediaUrl:
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=1600&q=80',
        thumbnailUrl:
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=480&q=80',
      },
    ],
  },
  {
    id: 'sala-luz',
    title: 'Sala Luz',
    subtitle: 'Fotografia, sombras y tiempo',
    accent: '#0B7285',
    coverUrl:
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    exhibits: [
      {
        id: 'luz-1',
        title: 'Placa de plata',
        subtitle: '1903',
        description:
          'La foto principal puede venir de S3, Cloudinary o de cualquier CDN propia.',
        accent: '#0B7285',
        mediaType: 'image',
        mediaUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1600&q=80',
        thumbnailUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=480&q=80',
      },
      {
        id: 'luz-2',
        title: 'Sombras en sala',
        subtitle: 'Instalacion',
        description:
          'Cada pieza mantiene titulo, subtitulo y descripcion junto con la URL de su media.',
        accent: '#1971C2',
        mediaType: 'image',
        mediaUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1600&q=80',
        thumbnailUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=480&q=80',
      },
    ],
  },
];
