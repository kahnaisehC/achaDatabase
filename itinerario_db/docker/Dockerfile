# ============================================================
#  Imagen PHP 8.2 + Apache con la extensión MongoDB y Composer.
#  Usamos PHP 8.2 (no el 8.0 de tu XAMPP) para tener la última
#  versión de la extensión y la librería sin problemas de compatibilidad.
# ============================================================
FROM php:8.2-apache

# 1) Dependencias del sistema necesarias para compilar la extensión.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libssl-dev pkg-config git unzip \
    && rm -rf /var/lib/apt/lists/*

# 2) Instalamos y activamos la extensión 'mongodb' del driver de PHP.
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

# 3) Traemos Composer (copiamos el binario desde la imagen oficial).
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# El código se monta acá vía docker-compose (volumen).
WORKDIR /var/www/html

# 4) Al arrancar el contenedor:
#    - si no existe 'vendor/', instalamos las dependencias con Composer;
#    - luego levantamos Apache en primer plano.
CMD bash -c "[ -d vendor ] || composer install --no-interaction; apache2-foreground"
