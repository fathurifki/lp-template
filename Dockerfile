FROM node:alpine3.19 AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-optional --max-old-space-size=512

COPY . .
RUN npm run build --max-old-space-size=512

FROM node:alpine3.19-slim AS production
WORKDIR /app

COPY --from=build /app/package.json /app/package-lock.json ./
RUN npm ci --no-audit --no-optional --only=production --max-old-space-size=512

COPY --from=build /app/dist ./dist

ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321
CMD ["node", "--max-old-space-size=512", "dist/server/entry.mjs"]
