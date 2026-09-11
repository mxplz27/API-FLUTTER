# Despliegue de la versión web de la app Flutter (servicio "web" en Railway).
# Requiere la variable API_URL, por ejemplo: https://mi-api.up.railway.app/api

# ---- Etapa 1: compilar Flutter Web ----
FROM debian:bookworm-slim AS build

RUN apt-get update \
 && apt-get install -y --no-install-recommends git curl unzip xz-utils ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Misma versión de Flutter usada en desarrollo (ver pubspec.lock).
ARG FLUTTER_VERSION=3.44.7
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --no-analytics --enable-web && flutter precache --web

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
ARG API_URL
RUN test -n "$API_URL" || (echo "ERROR: define la variable API_URL en Railway" && exit 1)
RUN flutter build web --release --dart-define=API_URL=${API_URL}

# ---- Etapa 2: servir los archivos estáticos ----
FROM nginx:1.27-alpine

# La imagen de nginx reemplaza ${PORT} en las plantillas al arrancar.
COPY deploy/nginx.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/build/web /usr/share/nginx/html

ENV PORT=8080
EXPOSE 8080
