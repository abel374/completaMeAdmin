# Usar imagem oficial do Flutter
FROM ghcr.io/cirruslabs/flutter:latest AS build

# Criar diretório
WORKDIR /app

# Copiar tudo
COPY . .

# Fazer o build do Flutter Web
RUN flutter build web --release

# Etapa 2: Servir o site com NGINX
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
