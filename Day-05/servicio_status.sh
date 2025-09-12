#!bin/bash

#!/bin/bash
SERVICIO="apache2"

if ! systemctl is-active --quiet $SERVICIO; then
    systemctl start $SERVICIO
    echo "El servicio $SERVICIO fue reiniciado." | mail -s "Reinicio de $SERVICIO" admin@ejemplo.com
fi

revise varios servcios y reporte su estado 
informme cuales estan activos y cuales no
envie un mail si alguno caido ("tip: usá un array y bucle")