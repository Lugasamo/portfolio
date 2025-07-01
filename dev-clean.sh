#!/bin/bash
clear
echo "🚀 Luis Saavedra Portfolio - Servidor de Desarrollo"
echo "📍 http://localhost:8000"
echo "✨ Ejecutando sin warnings de deprecación"
echo ""
php -d error_reporting=0 -d display_errors=0 -S localhost:8000 system/router.php 2>/dev/null
