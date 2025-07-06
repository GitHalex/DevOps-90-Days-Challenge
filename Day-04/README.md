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

#### 🧑‍💻 Comandos Esenciales

| **COMANDOS**               | **DESCRIPCION**                                        |
| -------------------------- | ------------------------------------------------------ |
| vagrant up                 | crear o inicia la maquina virtual según el Vagrantfile |
| vagrant ssh                | entras a tu VM para trabajar                           |
| vagrant halt               | apagar la VM                                           |
| vagrant destroy            | Eliminar la VM completamente                           |
| vagrant reload --provision | Reiniciar y reejcutar provisionamient                  |

## 🏗️ Primer archivo **Vagrant** 👇

```bash
Vagrant.configure("2") do |config|
  # Usa una imagen ligera de Ubuntu 22.04
  config.vm.box = "ubuntu/jammy64"

  # Configuración de red (accesible via IP)
  config.vm.network "private_network", ip: "192.168.56.10"

  # Provisionamiento con Shell
  config.vm.provision "shell", inline: <<-SHELL
    echo "¡Hola desde el provisionamiento!" > /tmp/hola.txt
    apt update && apt install -y nginx
    systemctl start nginx
  SHELL
end
```

##### **Paso 1:** crear o iniciar la maquian virtual con el comando 👇

```bash
vagrant up
```

\*\*verficar virtualbox y que la maquina este creada

##### **Paso 2:** ingresar a la maquina virtual con el comando 👇
