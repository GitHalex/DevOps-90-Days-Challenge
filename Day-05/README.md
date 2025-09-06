# 📅 Día 05/90 - Automatizando Tareas con Bash Scripting

> "La mejor forma de aprender DevOps... es haciéndolo." - Roxs.

## ✅ Desafíos del Día 5:

### 1️⃣ 🌎 ¿Qué es script Bash?

Es un archivo de texto con instrucciones que ejecutás en una terminal Linux, como si las escribieras vos misma

### 🔁 Estructura básica de un script

```bash
#!/bin/bash

# Comentario
echo "Hola Mundo"

# Variables
NOMBRE="Cloudlex"
echo "Hola $NOMBRE"

# Condicionales
if [ "$NOMBRE" == "Roxs" ]; then
    echo "¡Sos vos!"
else
    echo "¿Y vos quién sos?"
fi

# Bucle
for i in {1..3}; do
    echo "Iteración $i"
done
```

### 📌 Guardalo con la extencion .sh, dale permisos y ejecutalo:

```text
chmod +x script.sh
./script.sh
```

### 🧪 Buenas prácticas

- Usá #!/bin/bash siempre en la primera línea
- Usá set -e para salir si ocurre un error
- Comentá tu código con #
- Probá scripts en entornos controlados (como Vagrant o online)

# 🔥 Desafíos Prácticos

- Desafio 1: Fork y Clone
- Desafio 2: Branching
- Desafio 3: Merging
- Desafio 4: Deshacer Commits
- Desafio 5: Rebase
- Desafio 6: Pull Request (PR)
- Desafio 7: Resolución de Conflictos
- Desafio 8: Git Stash
- Desafio 9: Tagas de Version
-
