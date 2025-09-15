#!/bin/bash

# Configuración
LOG="logs_pm2.txt"
APP_DIR="devops-static-web"
APP_REPO="https://github.com/roxsross/devops-static-web.git"
BRANCH="ecommerce-ms"
APP_NAME="ecommerce-app"
PORT=3000

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging con colores
log() {
    echo -e "${BLUE}$(date '+%Y-%m-%d %H:%M:%S')${NC} - $1" | tee -a $LOG
}

success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a $LOG
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a $LOG
}

error() {
    echo -e "${RED}✗ $1${NC}" | tee -a $LOG
}

# Función para verificar e instalar Node.js
instalar_node() {
    log "Verificando Node.js y npm..."
    
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        success "Node.js $(node -v) y npm $(npm -v) ya están instalados"
        return 0
    fi
    
    log "Instalando Node.js y npm..."
    
    # Intentar instalar Node.js desde los repositorios oficiales
    if curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - >> $LOG 2>&1; then
        if sudo apt install -y nodejs >> $LOG 2>&1; then
            success "Node.js $(node -v) y npm $(npm -v) instalados correctamente"
            return 0
        fi
    fi
    
    # Fallback: intentar instalar desde repositorios de Ubuntu
    warning "Falló instalación desde Nodesource, intentando con repositorios Ubuntu..."
    if sudo apt update >> $LOG 2>&1 && sudo apt install -y nodejs npm >> $LOG 2>&1; then
        success "Node.js y npm instalados desde repositorios Ubuntu"
        return 0
    fi
    
    error "No se pudo instalar Node.js"
    return 1
}

# Función para instalar PM2
instalar_pm2() {
    log "Verificando PM2..."
    
    if command -v pm2 >/dev/null 2>&1; then
        success "PM2 ya está instalado"
        return 0
    fi
    
    log "Instalando PM2 globalmente..."
    if sudo npm install -g pm2 >> $LOG 2>&1; then
        success "PM2 instalado correctamente"
        return 0
    else
        error "Falló la instalación de PM2"
        return 1
    fi
}

# Función para clonar la aplicación
clonar_app() {
    log "Clonando aplicación Node.js..."
    
    if [ -d "$APP_DIR" ]; then
        warning "El directorio $APP_DIR ya existe, actualizando..."
        cd $APP_DIR
        git fetch origin >> ../$LOG 2>&1
        git checkout $BRANCH >> ../$LOG 2>&1
        git pull origin $BRANCH >> ../$LOG 2>&1
        cd ..
        success "Aplicación actualizada"
    else
        if git clone -b $BRANCH $APP_REPO >> $LOG 2>&1; then
            success "Aplicación clonada correctamente"
        else
            error "Falló el clone del repositorio"
            return 1
        fi
    fi
}

# Función para instalar dependencias
instalar_dependencias() {
    log "Instalando dependencias de Node.js..."
    
    cd $APP_DIR
    
    if [ ! -f "package.json" ]; then
        error "No se encuentra package.json en $APP_DIR"
        return 1
    fi
    
    if npm install >> ../$LOG 2>&1; then
        success "Dependencias instaladas correctamente"
        cd ..
        return 0
    else
        error "Falló la instalación de dependencias"
        cd ..
        return 1
    fi
}

# Función para configurar PM2
configurar_pm2() {
    log "Configurando PM2..."
    
    cd $APP_DIR
    
    # Detener la app si ya está corriendo con PM2
    pm2 stop $APP_NAME >> ../$LOG 2>&1 || true
    pm2 delete $APP_NAME >> ../$LOG 2>&1 || true
    
    # Iniciar la aplicación con PM2
    if pm2 start npm --name "$APP_NAME" -- start >> ../$LOG 2>&1; then
        success "Aplicación iniciada con PM2"
        
        # Guardar configuración para reinicio automático
        pm2 save >> ../$LOG 2>&1
        success "Configuración de PM2 guardada"
        
        # Configurar inicio automático con systemd
        if pm2 startup | grep -q "systemd"; then
            pm2 startup systemd -u $(whoami) --hp $(eval echo ~$USER) >> ../$LOG 2>&1
            success "Inicio automático configurado"
        fi
        
        cd ..
        return 0
    else
        error "Falló al iniciar la aplicación con PM2"
        cd ..
        return 1
    fi
}

# Función para verificar el despliegue
verificar_despliegue() {
    log "Verificando despliegue..."
    
    echo "=== ESTADO DEL DESPLIEGUE ===" | tee -a $LOG
    
    # Verificar PM2
    if pm2 status | grep -q "$APP_NAME"; then
        success "PM2 está gestionando la aplicación"
    else
        error "PM2 no está gestionando la aplicación"
    fi
    
    # Verificar proceso Node.js
    if pgrep -f "node.*$APP_NAME" > /dev/null; then
        success "Proceso Node.js está corriendo"
    else
        error "Proceso Node.js no está corriendo"
    fi
    
    # Verificar puerto
    if ss -tln | grep -q ":$PORT"; then
        success "Puerto $PORT está en escucha"
    else
        warning "Puerto $PORT no está en escucha"
    fi
    
    # Probar la aplicación
    sleep 2 # Dar tiempo a que la app inicie
    if curl -s http://localhost:$PORT > /dev/null; then
        success "Aplicación responde en http://localhost:$PORT"
    else
        warning "Aplicación no responde inmediatamente, puede estar iniciando"
    fi
    
    # Mostrar información de PM2
    echo "" | tee -a $LOG
    echo "=== INFORMACIÓN PM2 ===" | tee -a $LOG
    pm2 show $APP_NAME | head -20 | tee -a $LOG
}

# Función para mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  start    - Iniciar aplicación"
    echo "  stop     - Detener aplicación"
    echo "  restart  - Reiniciar aplicación"
    echo "  status   - Ver estado"
    echo "  logs     - Ver logs en tiempo real"
    echo ""
    echo "Sin comando: Despliegue completo"
}

# Función principal
main() {
    echo "==========================================" | tee $LOG
    echo "   DESPLIEGUE APP NODE.JS CON PM2" | tee -a $LOG
    echo "   $(date)" | tee -a $LOG
    echo "==========================================" | tee -a $LOG
    
    # Verificar argumentos
    case "${1:-}" in
        start)
            cd $APP_DIR
            pm2 start $APP_NAME
            exit 0
            ;;
        stop)
            pm2 stop $APP_NAME
            exit 0
            ;;
        restart)
            pm2 restart $APP_NAME
            exit 0
            ;;
        status)
            pm2 status
            exit 0
            ;;
        logs)
            pm2 logs $APP_NAME
            exit 0
            ;;
        help|--help|-h)
            mostrar_ayuda
            exit 0
            ;;
        *)
            # Continuar con despliegue completo
            ;;
    esac
    
    # Ejecutar pasos del despliegue
    instalar_node || exit 1
    instalar_pm2 || exit 1
    clonar_app || exit 1
    instalar_dependencias || exit 1
    configurar_pm2 || exit 1
    
    # Esperar un poco y verificar
    sleep 3
    verificar_despliegue
    
    echo "==========================================" | tee -a $LOG
    success "DESPLIEGUE COMPLETADO" | tee -a $LOG
    echo "==========================================" | tee -a $LOG
    
    # Mostrar información útil
    IP=$(hostname -I | awk '{print $1}')
    echo "🌐 Aplicación disponible en:" | tee -a $LOG
    echo "   Local: http://localhost:$PORT" | tee -a $LOG
    echo "   Red:   http://$IP:$PORT" | tee -a $LOG
    echo "" | tee -a $LOG
    echo "📋 Comandos útiles:" | tee -a $LOG
    echo "   $0 status          # Ver estado" | tee -a $LOG
    echo "   $0 logs            # Ver logs en tiempo real" | tee -a $LOG
    echo "   pm2 monitor $APP_NAME  # Monitor en tiempo real" | tee -a $LOG
    echo "" | tee -a $LOG
    echo "📊 Logs detallados en: $LOG" | tee -a $LOG
}

# Manejar señales de interrupción
trap 'echo ""; error "Script interrumpido por el usuario"; exit 1' INT TERM

# Ejecutar función principal
main "$@"