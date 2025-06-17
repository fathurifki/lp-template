# FROM node:alpine3.19 AS build
# WORKDIR /app

# COPY package.json package-lock.json ./
# # Remove existing node_modules and package-lock.json if they exist
# RUN rm -rf node_modules package-lock.json
# # Install dependencies with legacy-peer-deps flag and force option
# RUN npm install --legacy-peer-deps --force

# COPY . .
# # Build with increased memory limit and production flag
# RUN NODE_ENV=production npm run build --max-old-space-size=4096

# FROM node:alpine AS production
# WORKDIR /app

# COPY --from=build /app/package.json /app/package-lock.json ./
# RUN npm ci --no-audit --no-optional --only=production --max-old-space-size=512

# COPY --from=build /app/dist ./dist

# ENV HOST=0.0.0.0
# ENV PORT=4321
# EXPOSE 4321
# CMD ["node", "--max-old-space-size=512", "dist/server/entry.mjs"]

FROM node:alpine3.19 AS base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine AS runtime
# Remove the line that copies the non-existent nginx.conf file
COPY --from=base /app/dist /usr/share/nginx/html
EXPOSE 8080

# Add this line to start Nginx
CMD ["nginx", "-g", "daemon off;"]