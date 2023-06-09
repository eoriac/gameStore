# Usa una imagen base con Node.js
FROM node:18-alpine as build

RUN apk add chromium
ENV CHROME_BIN=/usr/bin/chromium-browser

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de configuración del proyecto
COPY package.json package-lock.json /app/

# Instala las dependencias del proyecto
RUN npm install

# Copia el código fuente de la aplicación
COPY . /app

# Ejecuta las pruebas unitarias
RUN npm run test-headless

# Construye la aplicación Angular
RUN npm run build --prod


# Imagen de nginx
FROM nginx:latest AS ngi

# Copying compiled code and nginx config to different folder
# NOTE: This path may change according to your project's output folder 
COPY --from=build /app/dist/game-store /usr/share/nginx/html

COPY /nginx.conf  /etc/nginx/conf.d/default.conf

# Exposing a port, here it means that inside the container 
# the app will be using Port 80 while running
EXPOSE 80