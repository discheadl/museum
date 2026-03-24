FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY public ./public
COPY src ./src

EXPOSE 4000

CMD ["npm", "start"]
