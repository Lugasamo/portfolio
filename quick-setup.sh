#!/bin/bash

# Script de setup rápido para proyecto GRAV Portfolio Luis en Kamatera
# Uso: curl -sSL https://raw.githubusercontent.com/Lugasamo/portfolio/main/quick-setup.sh | bash

set -e

# CONFIGURACIÓN - CAMBIAR ESTOS VALORES POR LOS TUYOS
GITHUB_REPO="https://github.com/Lugasamo/portfolio"
DOMAIN="saavedral.au"
ADMIN_EMAIL="nofxuis@gmail.com"
PROJECT_DIR="/var/www/grav"
PHP_VERSION="8.1"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${BLUE}[SETUP]${NC} $1"; }

# ASCII Art
echo -e "${BLUE}"
cat << "EOF"
 ____   ___  ____ _____ _____ ___  _     ___ ___  
|  _ \ / _ \|  _ \_   _|  ___/ _ \| |   |_ _/ _ \ 
| |_) | | | | |_) || | | |_ | | | | |    | | | | |
|  __/| |_| |  _ < | | |  _|| |_| | |___ | | |_| |
|_|    \___/|_| \_\|_| |_|   \___/|_____|___\___/ 
                                                  
     GRAV CMS - Despliegue Automático v2.1
     Portfolio Luis Saavedra - Kamatera Deploy
EOF
echo -e "${NC}"

# Verificar root
if [[ $EUID -ne 0 ]]; then
    print_error "Este script debe ejecutarse como root"
    print_status "Usa: sudo bash quick-setup.sh"
    exit 1
fi

print_header "🚀 Iniciando setup de Portfolio GRAV con tema Luis..."

# Detectar SO y mostrar info
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$NAME
    print_status "Sistema detectado: $OS $VERSION_ID"
else
    print_error "No se puede detectar el sistema operativo"
    exit 1
fi

# Crear directorio de backups
mkdir -p /backups/grav

# Instalar dependencias básicas
print_status "📦 Instalando dependencias del sistema..."
if [[ $OS == *"Ubuntu"* ]] || [[ $OS == *"Debian"* ]]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y nginx php${PHP_VERSION} php${PHP_VERSION}-fpm php${PHP_VERSION}-cli \
                       php${PHP_VERSION}-gd php${PHP_VERSION}-curl php${PHP_VERSION}-zip \
                       php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring php${PHP_VERSION}-json \
                       php${PHP_VERSION}-yaml php${PHP_VERSION}-opcache php${PHP_VERSION}-apcu \
                       unzip wget curl git rsync software-properties-common certbot \
                       python3-certbot-nginx htop nano
    
    # Habilitar servicios
    systemctl enable nginx php${PHP_VERSION}-fpm
    systemctl start nginx php${PHP_VERSION}-fpm
    
elif [[ $OS == *"CentOS"* ]] || [[ $OS == *"Rocky"* ]] || [[ $OS == *"AlmaLinux"* ]]; then
    yum update -y -q
    yum install -y epel-release
    yum install -y nginx php php-fpm php-gd php-curl php-zip php-xml \
                   php-mbstring php-json php-opcache unzip wget curl git rsync
    
    systemctl enable nginx php-fpm
    systemctl start nginx php-fpm
else
    print_error "Sistema operativo no soportado: $OS"
    exit 1
fi

# Instalar Composer
print_status "🎼 Verificando Composer..."
if ! command -v composer &> /dev/null; then
    print_status "Instalando Composer..."
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
else
    print_status "Composer ya está instalado: $(composer --version)"
fi

# Instalar Node.js LTS para Tailwind CSS
print_status "📗 Instalando Node.js LTS para Tailwind CSS..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
fi

print_status "Node.js instalado: $(node --version)"
print_status "NPM instalado: $(npm --version)"

# Clonar el proyecto
print_status "📥 Clonando tu proyecto Portfolio desde GitHub..."
if [ -d "$PROJECT_DIR" ]; then
    print_warning "Directorio existente encontrado, creando backup..."
    tar -czf /backups/grav/backup_before_setup_$(date +%Y%m%d_%H%M%S).tar.gz -C /var/www grav
    rm -rf $PROJECT_DIR
fi

# Clonar repositorio
git clone $GITHUB_REPO $PROJECT_DIR
cd $PROJECT_DIR

print_status "📁 Estructura del proyecto clonada:"
ls -la

# Verificar si necesita GRAV core
if [ ! -f "index.php" ] || [ ! -d "system" ]; then
    print_status "🔧 Tu proyecto no incluye GRAV core, descargando..."
    cd /tmp
    wget -q -O grav.zip https://getgrav.org/download/core/grav-admin/latest
    unzip -q grav.zip
    
    # Mover core preservando tu contenido user/
    print_status "Integrando GRAV core con tu contenido..."
    rsync -av --exclude='user/' grav-admin/ $PROJECT_DIR/
    rm -rf grav-admin grav.zip
    cd $PROJECT_DIR
    
    print_status "✅ GRAV core integrado con tu proyecto"
else
    print_status "✅ Tu proyecto ya incluye GRAV core"
fi

# Crear directorios necesarios
print_status "📂 Creando estructura de directorios..."
mkdir -p cache logs tmp backup
mkdir -p user/accounts user/data

# Instalar dependencias PHP
if [ -f "composer.json" ]; then
    print_status "🎵 Instalando dependencias PHP con Composer..."
    composer install --no-dev --optimize-autoloader --no-interaction
else
    print_status "No se encontró composer.json, saltando dependencias PHP"
fi

# Instalar dependencias Node.js y construir assets
if [ -f "package.json" ]; then
    print_status "📦 Instalando dependencias Node.js..."
    npm install
    
    # Construir Tailwind CSS para producción
    if [ -f "tailwind.config.js" ]; then
        print_status "🎨 Construyendo Tailwind CSS para producción..."
        npm run tailwind:build
        print_status "✅ Assets de Tailwind generados"
    fi
    
    # Ejecutar build general si existe
    if npm run-script --silent 2>/dev/null | grep -q "build"; then
        print_status "🏗️ Ejecutando script de build..."
        npm run build
    fi
else
    print_warning "No se encontró package.json, creando configuración básica para Tailwind..."
    npm init -y
    npm install --save-dev tailwindcss@3.4.17 @tailwindcss/typography
fi

# Configurar permisos específicos para GRAV
print_status "🔒 Configurando permisos optimizados para GRAV..."
chown -R www-data:www-data $PROJECT_DIR

# Permisos base
find $PROJECT_DIR -type f -exec chmod 644 {} \;
find $PROJECT_DIR -type d -exec chmod 755 {} \;

# Permisos específicos para GRAV
chmod -R 775 $PROJECT_DIR/cache
chmod -R 775 $PROJECT_DIR/logs  
chmod -R 775 $PROJECT_DIR/tmp
chmod -R 775 $PROJECT_DIR/user
chmod -R 775 $PROJECT_DIR/images 2>/dev/null || true
chmod -R 775 $PROJECT_DIR/assets 2>/dev/null || true

# Permisos especiales
chmod +x $PROJECT_DIR/bin/grav 2>/dev/null || true
chmod +x $PROJECT_DIR/bin/gpm 2>/dev/null || true

# Configurar Nginx optimizado para Portfolio + Tailwind
print_status "🌐 Configurando Nginx para Portfolio GRAV con Tailwind..."
cat > /etc/nginx/sites-available/grav << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    root $PROJECT_DIR;
    index index.php index.html;

    # Logs específicos
    access_log /var/log/nginx/grav_access.log;
    error_log /var/log/nginx/grav_error.log;

    # GRAV URL handling
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # PHP processing optimizado
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        
        # Optimizaciones para GRAV
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_connect_timeout 60s;
        fastcgi_send_timeout 60s;
        fastcgi_read_timeout 60s;
    }

    # Security - Deny access to sensitive files
    location ~ /\. { deny all; }
    location ~* /(\.git|cache|bin|logs|backup|tests|node_modules)/.*\$ { deny all; }
    location ~* /(system|vendor)/.*\.(txt|xml|md|html|yaml|yml|php|pl|py|cgi|twig|sh|bat)\$ { deny all; }
    location ~* /user/.*\.(txt|md|yaml|yml|php|pl|py|cgi|twig|sh|bat)\$ { deny all; }

    # Portfolio assets - Imágenes optimizadas
    location ~* \.(jpg|jpeg|gif|png|webp|svg|ico|avif)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
        access_log off;
    }

    # CSS y JS - Especial para Tailwind
    location ~* \.(css|js)\$ {
        expires 1M;
        add_header Cache-Control "public";
        add_header Vary Accept-Encoding;
        access_log off;
        
        # Compresión específica para CSS generado por Tailwind
        gzip_static on;
    }

    # Fonts - Important for portfolio typography
    location ~* \.(woff|woff2|ttf|eot|otf)\$ {
        expires 1y;
        add_header Cache-Control "public";
        add_header Access-Control-Allow-Origin "*";
        access_log off;
    }

    # Gzip compression optimizado
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json
        application/ld+json
        image/svg+xml;
}
EOF

# Activar sitio
ln -sf /etc/nginx/sites-available/grav /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Optimizar PHP para GRAV + Tailwind assets
print_status "⚙️ Optimizando PHP para GRAV CMS..."
PHP_INI="/etc/php/${PHP_VERSION}/fpm/php.ini"

# Backup de configuración
cp $PHP_INI $PHP_INI.backup

# Optimizaciones específicas
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' $PHP_INI
sed -i 's/post_max_size = .*/post_max_size = 64M/' $PHP_INI
sed -i 's/max_execution_time = .*/max_execution_time = 300/' $PHP_INI
sed -i 's/max_input_vars = .*/max_input_vars = 5000/' $PHP_INI
sed -i 's/memory_limit = .*/memory_limit = 512M/' $PHP_INI

# OPcache para mejor rendimiento
sed -i 's/;opcache.enable=1/opcache.enable=1/' $PHP_INI
sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=256/' $PHP_INI
sed -i 's/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=20000/' $PHP_INI

# Test y reiniciar servicios
print_status "🔄 Verificando y reiniciando servicios..."
nginx -t
if [ $? -eq 0 ]; then
    systemctl reload nginx
    systemctl restart php${PHP_VERSION}-fpm
    print_status "✅ Servicios reiniciados correctamente"
else
    print_error "Error en configuración de Nginx"
    exit 1
fi

# Crear usuario administrador
print_status "👤 Configurando usuario administrador..."
if [ ! -f "$PROJECT_DIR/user/accounts/admin.yaml" ]; then
    ADMIN_PASSWORD=$(openssl rand -base64 24)
    
    cat > $PROJECT_DIR/user/accounts/admin.yaml << EOF
email: $ADMIN_EMAIL
fullname: 'Luis Saavedra'
title: 'Portfolio Administrator'
state: enabled
access:
  admin:
    login: true
    super: true
hashed_password: $(php -r "echo password_hash('$ADMIN_PASSWORD', PASSWORD_DEFAULT);")
EOF

    # Guardar credenciales
    cat > /root/grav-admin-credentials.txt << EOF
=====================================
GRAV PORTFOLIO - Credenciales Admin
=====================================
Sitio: http://$DOMAIN
Admin: http://$DOMAIN/admin

Usuario: admin
Email: $ADMIN_EMAIL
Password: $ADMIN_PASSWORD

Tema: portfolio-luis
Tailwind: ✅ Configurado
=====================================
⚠️  CAMBIA LA CONTRASEÑA DESPUÉS DEL PRIMER LOGIN
EOF
    
    chmod 600 /root/grav-admin-credentials.txt
    print_status "👤 Usuario administrador creado"
    print_warning "📋 Credenciales en /root/grav-admin-credentials.txt"
else
    print_status "👤 Usuario administrador ya existe"
fi

# Configurar firewall
print_status "🔥 Configurando firewall..."
if command -v ufw &> /dev/null; then
    ufw --force reset
    ufw --force enable
    ufw allow ssh
    ufw allow 'Nginx Full'
    print_status "✅ UFW configurado"
fi

# Limpiar cache y generar inicial
print_status "🧹 Limpiando cache y generando inicial..."
rm -rf $PROJECT_DIR/cache/*
if [ -f "$PROJECT_DIR/bin/grav" ]; then
    cd $PROJECT_DIR
    sudo -u www-data bin/grav cache
fi

# Crear script de actualización automática
cat > /usr/local/bin/update-portfolio << 'EOF'
#!/bin/bash
cd /var/www/grav
git pull origin main
sudo -u www-data composer install --no-dev --optimize-autoloader
npm install
npm run tailwind:build
sudo -u www-data bin/grav cache
systemctl reload nginx
echo "Portfolio actualizado: $(date)"
EOF

chmod +x /usr/local/bin/update-portfolio

# Mensaje final
print_header "🎉 ¡DESPLIEGUE COMPLETADO EXITOSAMENTE!"
echo ""
echo -e "${GREEN}🌐 Tu Portfolio está disponible en:${NC}"
echo -e "   👉 ${BLUE}http://$DOMAIN${NC}"
echo ""
echo -e "${GREEN}🔐 Panel de administración:${NC}"
echo -e "   👉 ${BLUE}http://$DOMAIN/admin${NC}"
echo ""
echo -e "${GREEN}🎨 Características activadas:${NC}"
echo -e "   ✅ Tema portfolio-luis"
echo -e "   ✅ Tailwind CSS $(cd $PROJECT_DIR && npm list tailwindcss 2>/dev/null | grep tailwindcss || echo 'configurado')"
echo -e "   ✅ Assets optimizados"
echo -e "   ✅ PHP ${PHP_VERSION} + OPcache"
echo -e "   ✅ Nginx optimizado"
echo ""
print_warning "📋 Próximos pasos:"
echo "1. 🌍 Configurar DNS: $DOMAIN → IP del servidor"
echo "2. 🔒 SSL: certbot --nginx -d $DOMAIN -d www.$DOMAIN"  
echo "3. 👤 Cambiar contraseña admin"
echo "4. 🎨 Personalizar contenido del portfolio"
echo "5. 🔄 Actualizar: /usr/local/bin/update-portfolio"
echo ""
print_status "📄 Credenciales: /root/grav-admin-credentials.txt"
print_status "🚀 ¡Tu portfolio está listo para impresionar!"