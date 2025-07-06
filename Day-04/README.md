# 📅 Día 04/90 - Provisionamiento con Vagrant

> "La mejor forma de aprender DevOps... es haciéndolo." - Roxs.

## ✅ Desafíos del Día 3:

### 1️⃣ 🌎 ¿Qué Es Vagrant?

Vagrant es una herramienta que permite **crear** y **configurar** entornos de desarrollo virtualizados de forma sencilla, reproducible y automatizado

#### 🎯 ¿Por que usar Vagrant?

- Automatizas el entorno desde cero
- probas sin miedo (puedes destruir y volver a levantar en segundos)
- es ideal para testear scripts, Ansible, Docker o configuraciones
- Funciona igual en todos los sistemas operativas

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
