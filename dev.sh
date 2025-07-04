#!/bin/bash

# Limpiar caché de Grav (opcional pero recomendado)
echo "🧹 Limpiando caché de Grav..."
rm -rf cache/*

# Iniciar servidor PHP local
echo "🚀 Iniciando servidor local..."
php -S localhost:8000 system/router.php &
PHP_PID=$!

# Compilar Tailwind CSS en modo observador
echo "👀 Compilando Tailwind CSS en modo observador..."
npx tailwindcss -i ./user/themes/portfolio-luis/css/input.css -o ./user/themes/portfolio-luis/css/output.css --watch &
TAILWIND_PID=$!

echo "✅ Servidor listo en http://localhost:8000"
echo "✅ Tailwind está escuchando cambios..."

# Detener ambos procesos al salir
trap "kill $PHP_PID $TAILWIND_PID" EXIT

# Mantener script corriendo
wait