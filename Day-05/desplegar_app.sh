#!/bin/bash

# desplegar_app.sh - Script para desplegar aplicación Flask Book Library
# con Gunicorn y Nginx en Ubuntu/Bubuntu

# Configuración
LOG="logs_despliegue.txt"
APP_DIR="devops-static-web"
APP_REPO="https://github.com/roxsross/devops-static-web.git"
BRANCH="booklibrary"

# Función para registrar logs
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG
}

# Función para instalar dependencias
instalar_dependencias() {
    log "Instalando dependencias del sistema..."
    
    # Actualizar sistema
    sudo apt update >> $LOG 2>&1
    if [ $? -ne 0 ]; then
        log "ERROR: Falló apt update"
        return 1
    fi
    
    # Instalar paquetes necesarios
    sudo apt install -y python3 python3-pip python3-venv nginx git >> $LOG 2>&1
    if [ $? -ne 0 ]; then
        log "ERROR: Falló la instalación de paquetes"
        return 1
    fi
    
    # Habilitar e iniciar Nginx
    sudo systemctl enable nginx >> $LOG 2>&1
    sudo systemctl start nginx >> $LOG 2>&1
    
    log "Dependencias instaladas correctamente"
}

# Función para clonar la aplicación
clonar_app() {
    log "Clonando aplicación desde GitHub..."
    
    # Verificar si el directorio ya existe
    if [ -d "$APP_DIR" ]; then
        log "El directorio $APP_DIR ya existe, haciendo pull..."
        cd $APP_DIR
        git pull origin $BRANCH >> ../$LOG 2>&1
        cd ..
    else
        git clone -b $BRANCH $APP_REPO >> $LOG 2>&1
        if [ $? -ne 0 ]; then
            log "ERROR: Falló el clone del repositorio"
            return 1
        fi
    fi
    
    log "Aplicación clonada/actualizada correctamente"
}

# Función para configurar entorno virtual
configurar_entorno() {
    log "Configurando entorno virtual Python..."
    
    cd $APP_DIR
    
    # Crear entorno virtual si no existe
    if [ ! -d "venv" ]; then
        python3 -m venv venv >> ../$LOG 2>&1
        if [ $? -ne 0 ]; then
            log "ERROR: Falló la creación del venv"
            return 1
        fi
    fi
    
    # Activar entorno virtual
    source venv/bin/activate
    
    # Instalar dependencias Python
    pip install --upgrade pip >> ../$LOG 2>&1
    pip install -r requirements.txt >> ../$LOG 2>&1
    pip install gunicorn >> ../$LOG 2>&1
    
    if [ $? -ne 0 ]; then
        log "ERROR: Falló la instalación de dependencias Python"
        return 1
    fi
    
    log "Entorno virtual configurado correctamente"
    cd ..
}

# Función para configurar Gunicorn
configurar_gunicorn() {
    log "Configurando Gunicorn..."
    
    cd $APP_DIR
    source venv/bin/activate
    
    # Detener Gunicorn si ya está corriendo
    pkill -f "gunicorn.*library_site" >> ../$LOG 2>&1
    
    # Iniciar Gunicorn en background
    nohup venv/bin/gunicorn -w 4 -b 127.0.0.1:8000 library_site:app >> ../$LOG 2>&1 &
    
    # Esperar a que inicie
    sleep 5
    
    # Verificar si Gunicorn está corriendo
    if pgrep -f "gunicorn.*library_site" > /dev/null; then
        log "Gunicorn iniciado correctamente"
    else
        log "ERROR: Gunicorn no se pudo iniciar"
        return 1
    fi
    
    cd ..
}

# Función para configurar Nginx
configurar_nginx() {
    log "Configurando Nginx..."
    
    # Remover configuración por defecto
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Crear configuración para la aplicación
    sudo tee /etc/nginx/sites-available/booklibrary > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /static/ {
        alias $(pwd)/$APP_DIR/static/;
        expires 30d;
    }
    
    access_log /var/log/nginx/booklibrary_access.log;
    error_log /var/log/nginx/booklibrary_error.log;
}
EOF
    
    # Habilitar sitio
    sudo ln -sf /etc/nginx/sites-available/booklibrary /etc/nginx/sites-enabled/
    
    # Verificar configuración y recargar
    sudo nginx -t >> $LOG 2>&1
    if [ $? -eq 0 ]; then
        sudo systemctl reload nginx >> $LOG 2>&1
        log "Nginx configurado y recargado correctamente"
    else
        log "ERROR: Configuración de Nginx inválida"
        return 1
    fi
}

# Función para verificar servicios
verificar_servicios() {
    log "Verificando servicios..."
    
    echo "=== ESTADO DE SERVICIOS ===" | tee -a $LOG
    
    # Verificar Nginx
    if systemctl is-active --quiet nginx; then
        echo "✓ Nginx está activo y corriendo" | tee -a $LOG
    else
        echo "✗ Nginx NO está activo" | tee -a $LOG
    fi
    
    # Verificar Gunicorn
    if pgrep -f "gunicorn.*library_site" > /dev/null; then
        echo "✓ Gunicorn está corriendo" | tee -a $LOG
    else
        echo "✗ Gunicorn NO está corriendo" | tee -a $LOG
    fi
    
    # Verificar puerto 8000
    if ss -tln | grep -q ":8000"; then
        echo "✓ Puerto 8000 está en escucha" | tee -a $LOG
    else
        echo "✗ Puerto 8000 NO está en escucha" | tee -a $LOG
    fi
    
    # Probar conexión a la aplicación
    if curl -s http://127.0.0.1:8000 > /dev/null; then
        echo "✓ Aplicación responde en localhost:8000" | tee -a $LOG
    else
        echo "✗ Aplicación NO responde en localhost:8000" | tee -a $LOG
    fi
    
    # Probar conexión a través de Nginx
    if curl -s http://localhost > /dev/null; then
        echo "✓ Nginx sirve la aplicación correctamente" | tee -a $LOG
    else
        echo "✗ Nginx NO puede servir la aplicación" | tee -a $LOG
    fi
}

# Función principal
main() {
    echo "==========================================" | tee $LOG
    echo " INICIANDO DESPLIEGUE DE BOOK LIBRARY" | tee -a $LOG
    echo " Fecha: $(date)" | tee -a $LOG
    echo "==========================================" | tee -a $LOG
    
    # Ejecutar pasos en orden
    instalar_dependencias
    if [ $? -ne 0 ]; then exit 1; fi
    
    clonar_app
    if [ $? -ne 0 ]; then exit 1; fi
    
    configurar_entorno
    if [ $? -ne 0 ]; then exit 1; fi
    
    configurar_gunicorn
    if [ $? -ne 0 ]; then exit 1; fi
    
    configurar_nginx
    if [ $? -ne 0 ]; then exit 1; fi
    
    # Esperar un poco para que todo esté listo
    sleep 3
    
    verificar_servicios
    
    echo "==========================================" | tee -a $LOG
    echo " DESPLIEGUE COMPLETADO" | tee -a $LOG
    echo "==========================================" | tee -a $LOG
    
    # Mostrar información de acceso
    IP=$(hostname -I | awk '{print $1}')
    echo "🎉 La aplicación está desplegada!" | tee -a $LOG
    echo "📚 Accede a: http://$IP" | tee -a $LOG
    echo "📚 O localmente: http://localhost" | tee -a $LOG
    echo "📋 Logs detallados en: $LOG" | tee -a $LOG
}

# Ejecutar función principal
main "$@"