FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/src/index.html /usr/share/nginx/html/
COPY --from=builder /app/src/style.css /usr/share/nginx/html/
COPY --from=builder /app/dist/app.js /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
