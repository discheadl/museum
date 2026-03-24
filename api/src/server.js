import cors from 'cors';
import express from 'express';
import { fileURLToPath } from 'node:url';

import { museumRooms } from './data/museum-data.js';

const app = express();
const port = process.env.PORT || 4000;
const mediaDir = fileURLToPath(new URL('../public/media', import.meta.url));

app.use(cors());
app.use(express.json());
app.use('/media', express.static(mediaDir));

app.get('/api/health', (_request, response) => {
  response.json({ ok: true, service: 'museum-api' });
});

app.get('/api/rooms', (_request, response) => {
  response.json({ rooms: museumRooms });
});

app.listen(port, () => {
  console.log(`Museum API listening on http://localhost:${port}`);
});
