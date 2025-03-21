# Stage 1: Build Stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json ./

RUN npm install --only=production

COPY bin/ bin/
COPY src/ src/

# Stage 2: Runtime Stage
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/node_modules node_modules/
COPY --from=builder /app/bin bin/
COPY --from=builder /app/src src/
COPY package.json .


EXPOSE 3000

# Start the Node.js application
CMD ["node", "src/000.js"]  