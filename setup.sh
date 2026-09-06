#!/bin/bash

echo "[+] Actualizando repositorios e instalando dependencias del sistema..."
apt-get update && apt-get install -y libimobiledevice-utils irecovery usbmuxd build-essential git libusb-1.0-0-dev

echo "[+] Creando directorios del sistema..."
mkdir -p /root/iphone-suite
mkdir -p /opt/usbliter8

echo "[+] Copiando scripts y herramientas locales..."
cp install.sh /root/iphone-suite/install.sh
chmod +x /root/iphone-suite/install.sh

# Copiar Gaster si está en el repositorio local
if [ -d "gaster" ]; then
    cp -r gaster /root/
    chmod +x /root/gaster/gaster 2>/dev/null
    echo "[✔] Herramienta Gaster restaurada."
fi

# Copiar USBLiter8 si está en el repositorio local
if [ -d "usbliter8" ]; then
    cp -r usbliter8 /opt/
    chmod +x /opt/usbliter8/* 2>/dev/null
    echo "[✔] Herramienta USBLiter8 restaurada."
fi

echo "[+] Creando acceso directo global 'iphone'..."
ln -sf /root/iphone-suite/install.sh /usr/local/bin/iphone
chmod +x /usr/local/bin/iphone

echo -e "\n[✔] ¡Instalación completa y autónoma! Ya puedes usar el comando 'iphone'."