#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[+] Actualizando repositorios e instalando dependencias del sistema...${NC}"
apt-get update && apt-get install -y \
    libimobiledevice-utils \
    libimobiledevice-1.0-6 \
    irecovery \
    usbmuxd \
    build-essential \
    git \
    curl \
    dos2unix \
    libusb-1.0-0-dev \
    python3 \
    python3-pip 2>/dev/null || apt-get install -y libimobiledevice-utils irecovery usbmuxd build-essential git curl dos2unix libusb-1.0-0-dev python3 python3-pip

echo -e "${CYAN}[+] Creando directorios del sistema...${NC}"
mkdir -p /root/iphone-suite
mkdir -p /opt/usbliter8
mkdir -p /opt/iphone_backups

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo -e "${CYAN}[+] Copiando scripts y herramientas locales...${NC}"
if [ -f "$SCRIPT_DIR/install.sh" ]; then
    cp "$SCRIPT_DIR/install.sh" /root/iphone-suite/install.sh
fi

if [ -f "$SCRIPT_DIR/gaster" ]; then
    cp "$SCRIPT_DIR/gaster" /root/iphone-suite/gaster
    chmod +x /root/iphone-suite/gaster
fi

if [ -d "$SCRIPT_DIR/gaster" ]; then
    cp -r "$SCRIPT_DIR/gaster" /root/
    chmod +x /root/gaster/gaster 2>/dev/null
    echo -e "${GREEN}[✔] Herramienta Gaster restaurada.${NC}"
fi

if [ -d "$SCRIPT_DIR/usbliter8" ]; then
    cp -r "$SCRIPT_DIR/usbliter8" /opt/
    chmod +x /opt/usbliter8/* 2>/dev/null
    echo -e "${GREEN}[✔] Herramienta USBLiter8 restaurada.${NC}"
fi

echo -e "${CYAN}[+] Descargando e instalando palera1n oficial (ARM64 para Orange Pi)...${NC}"
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    curl -Lo /usr/local/bin/palera1n https://github.com/palera1n/palera1n/releases/latest/download/palera1n-linux-arm64
    chmod +x /usr/local/bin/palera1n
    echo -e "${GREEN}[✔] Binario palera1n instalado en /usr/local/bin/palera1n${NC}"
else
    echo -e "${RED}[!] Arquitectura $ARCH detectada. Intentando descargar versión x86_64...${NC}"
    curl -Lo /usr/local/bin/palera1n https://github.com/palera1n/palera1n/releases/latest/download/palera1n-linux-x86_64
    chmod +x /usr/local/bin/palera1n
fi

echo -e "${CYAN}[+] Limpiando caracteres CRLF (formato Windows) de scripts...${NC}"
dos2unix /root/iphone-suite/install.sh 2>/dev/null

echo -e "${CYAN}[+] Configurando permisos y acceso directo global 'iphone'...${NC}"
chmod +x /root/iphone-suite/install.sh
ln -sf /root/iphone-suite/install.sh /usr/local/bin/iphone
ln -sf /root/iphone-suite/install.sh /usr/local/bin/iphone-suite

echo -e "${CYAN}[+] Reiniciando servicio usbmuxd...${NC}"
systemctl restart usbmuxd 2>/dev/null

echo -e "\n${GREEN}[✔] ¡Instalación completa y autónoma! Ya puedes usar el comando 'iphone' o 'iphone-suite'.${NC}\n"
