FROM node:alpine3.19 AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:alpine3.19 AS production
WORKDIR /app

COPY --from=build /app/package.json /app/package-lock.json ./
RUN npm ci --only=production

COPY --from=build /app/dist ./dist

ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321
CMD ["node", "dist/server/entry.mjs"]
