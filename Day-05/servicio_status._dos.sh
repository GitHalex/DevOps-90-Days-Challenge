#!/bin/bash

# Configuración
SERVICIOS=("apache2" "nginx" "mysql" "docker" "ssh")
EMAIL_DESTINO="yijodop236@mirarmax.com"
ASUNTO_EMAIL="Reporte de Estado de Servicios - $(hostname)"

# Arrays para almacenar estados
SERVICIOS_ACTIVOS=()
SERVICIOS_INACTIVOS=()

# Función para verificar servicios
verificar_servicios() {
    echo "🔍 Verificando estado de servicios..."
    echo "========================================"
    
    for SERVICIO in "${SERVICIOS[@]}"; do
        if systemctl is-active --quiet "$SERVICIO"; then
            echo "✅ $SERVICIO: ACTIVO"
            SERVICIOS_ACTIVOS+=("$SERVICIO")
        else
            echo "❌ $SERVICIO: INACTIVO"
            SERVICIOS_INACTIVOS+=("$SERVICIO")
            
            # Intentar reiniciar el servicio (opcional)
            echo "🔄 Intentando reiniciar $SERVICIO..."
            systemctl start "$SERVICIO"
        fi
    done
    
    echo "========================================"
}

# Función para enviar email de alerta
enviar_alerta() {
    if [ ${#SERVICIOS_INACTIVOS[@]} -gt 0 ]; then
        MENSAJE="Reporte de Estado de Servicios - $(date)"
        MENSAJE+="\nHost: $(hostname)"
        MENSAJE+="\n\n❌ SERVICIOS INACTIVOS:"
        
        for servicio in "${SERVICIOS_INACTIVOS[@]}"; do
            MENSAJE+="\n- $servicio"
        done
        
        MENSAJE+="\n\n✅ SERVICIOS ACTIVOS:"
        for servicio in "${SERVICIOS_ACTIVOS[@]}"; do
            MENSAJE+="\n- $servicio"
        done
        
        MENSAJE+="\n\nSe intentó reiniciar los servicios caídos automáticamente."
        
        # Enviar email
        echo -e "$MENSAJE" | mail -s "$ASUNTO_EMAIL" "$EMAIL_DESTINO"
        echo "📧 Email de alerta enviado a $EMAIL_DESTINO"
    fi
}

# Función para mostrar resumen
mostrar_resumen() {
    echo "📊 RESUMEN:"
    echo "Servicios activos: ${#SERVICIOS_ACTIVOS[@]}"
    echo "Servicios inactivos: ${#SERVICIOS_INACTIVOS[@]}"
    
    if [ ${#SERVICIOS_INACTIVOS[@]} -eq 0 ]; then
        echo "🎉 Todos los servicios están funcionando correctamente!"
    else
        echo "⚠️  Hay servicios que requieren atención!"
    fi
}

# Ejecutar las funciones
verificar_servicios
enviar_alerta
mostrar_resumen