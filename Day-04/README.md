# 📅 Día 04/90 - Provisionamiento con Vagrant

> "La mejor forma de aprender DevOps... es haciéndolo." - Roxs.

## ✅ Desafíos del Día 4:

#### 🎯 **Comandos basicos de GIT**

- git init
- git add
- git commit
- git status
- git log
- git diff

### 1️⃣ Instalacion y Configuración

```bash
# Instalar Git en tu sistema
# Visita: https://git-scm.com/downloads

# Configurar tu nombre de usuario y email
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

#### 2️⃣ Crear tu primer repositorio

```bash
# Crear nueva carpeta e inicializar repositorio Git
mkdir git-proyecto && cd git-proyecto
git init

# Crear archivos iniciales
touch index.html style.css
git add .
git commit -m "Commit inicial"

```

#### 3️⃣ Realizar cambios y Commit

```bash
# Modificar index.html y verificar cambios
git status
git diff
git add index.html
git commit -m "Actualizado index.html"
```

#### 4️⃣ Verificar Historial

```bash
# Verificar historial de commits
git log --oneline
```

#### 5️⃣ Conectar con GitHub

```bash
# Crear repositorio en GitHub, agregar remoto y push
git remote add origin https://github.com/tuusuario/git-proyecto.git
git branch -M main
git push -u origin main
```

## **🔥** Desafios Prácticos 👇

- Desafio 1: Fork y Clone
- Desafio 2: Branching
- Desafio 3: Merging
- Desafio 4: Deshacer Commits
- Desafio 5: Rebase
- Desafio 6: Pull Request
- Desafio 7: Resolucion de Conflictos
- Desafio 8: Git Stash
- Desafio 9: Tags de Version
- Desafio 10: Editar Commits Pasados
