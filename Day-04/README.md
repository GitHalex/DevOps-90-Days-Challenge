# 📅 Día 04/90 - Provisionamiento con Vagrant

> "La mejor forma de aprender DevOps... es haciéndolo." - Roxs.

## ✅ Desafíos del Día 4:

### 1️⃣ 🌎 ¿Qué es el control de Versiones?

#### 🎯 **Comandos basicos de GIT**

- git init
- git add
- git commit
- git status
- git log
- git diff

#### 🎯 **Branching y Merging**

- Crear Ramas (branches) y funsion de cambios
- Estrategias de branching

#### 🎯 **Colaboracion**

- Pull Request
- Repositorios Remotos
- Clonado, fetching, pulling y pushing
- Reslucion de Conflictos

## 1️⃣ Tareas iniciales

### 1.instalacion y configuracion

```bash
# Instalar Git en tu sistema
# Visita: https://git-scm.com/downloads

# Configurar tu nombre de usuario y email
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

### 2. crear el primer repositorio

```bash
# Crear nueva carpeta e inicializar repositorio Git
mkdir git-proyecto && cd git-proyecto
git init

# Crear archivos iniciales
touch index.html style.css
git add .
git commit -m "Commit inicial"
```

### 3. realizar cambios y commit

```bash
# Modificar index.html y verificar cambios
git status
git diff
git add index.html
git commit -m "Actualizado index.html"
```

### 4. verificar historial

```bash
# Verificar historial de commits
git log --oneline
```

### 5. conectar con GitHub

```bash
# Crear repositorio en GitHub, agregar remoto y push
git remote add origin https://github.com/tuusuario/git-proyecto.git
git branch -M main
git push -u origin main
```

## 🔥 Comandos Esenciales

| **COMANDOS**               | **DESCRIPCION**                                        |
| -------------------------- | ------------------------------------------------------ |
| vagrant up                 | crear o inicia la maquina virtual según el Vagrantfile |
| vagrant ssh                | entras a tu VM para trabajar                           |
| vagrant halt               | apagar la VM                                           |
| vagrant destroy            | Eliminar la VM completamente                           |
| vagrant reload --provision | Reiniciar y reejcutar provisionamient                  |

## 🏗️ Primer archivo **Vagrant** 👇

##### **Paso 1:** crear o iniciar la maquian virtual con el comando 👇

```bash
vagrant up
```

\*\*verficar virtualbox y que la maquina este creada

##### **Paso 2:** ingresar a la maquina virtual con el comando 👇
