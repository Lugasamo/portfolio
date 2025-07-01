echo "🚀 Servidor de desarrollo - Luis Saavedra Portfolio"
echo "📍 http://localhost:8000"
echo "⚠️  Warnings de Twig ocultos durante desarrollo"
echo ""
php -d error_reporting="E_ALL & ~E_DEPRECATED & ~E_STRICT" -d display_errors=Off -S localhost:8000 system/router.php
