#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
REPO_DIR="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"

echo -e "${CYAN}[+] Copiando scripts y herramientas locales...${NC}"
if [ -f "$SCRIPT_DIR/install.sh" ]; then
    cp "$SCRIPT_DIR/install.sh" /root/iphone-suite/install.sh
fi

GASTER_FILE=$(find "$REPO_DIR" -name "gaster" -type f 2>/dev/null | head -n 1)
if [ -n "$GASTER_FILE" ]; then
    cp "$GASTER_FILE" /usr/local/bin/gaster
    chmod +x /usr/local/bin/gaster
    echo -e "${GREEN}[✔] Herramienta Gaster instalada en /usr/local/bin/gaster.${NC}"
fi

if [ -d "$REPO_DIR/usbliter8" ]; then
    cp -r "$REPO_DIR/usbliter8" /opt/
    chmod +x /opt/usbliter8/* 2>/dev/null
    echo -e "${GREEN}[✔] Herramienta USBLiter8 restaurada.${NC}"
fi

# --- SELECCIÓN INTERACTIVA DE VERSIÓN DE PALERA1N ---
echo -e "\n${CYAN}====================================================${NC}"
echo -e "${YELLOW}       SELECCIÓN DE VERSIÓN DE PALERA1N             ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e " Selecciona la versión que deseas descargar e instalar:"
echo -e "  1) v2.4 (Estable - Recomendada para uso general)"
echo -e "  2) v3.0.0 beta 2 (Beta / Experimental con nuevas funciones)"
echo -e "  3) Descarga automática de la última versión oficial (Latest)"
echo -e "${CYAN}====================================================${NC}"
echo -n "Elige una opción [1-3] (Por defecto [1]): "
read -r palera_choice

ARCH=$(uname -m)
BIN_NAME="palera1n-linux-arm64"
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    BIN_NAME="palera1n-linux-x86_64"
fi

case $palera_choice in
    2)
        echo -e "${YELLOW}[+] Descargando palera1n v3.0.0-beta.2...${NC}"
        URL="https://github.com/palera1n/palera1n/releases/download/v3.0.0-beta.2/$BIN_NAME"
        ;;
    3)
        echo -e "${CYAN}[+] Descargando última versión registrada en GitHub...${NC}"
        URL="https://github.com/palera1n/palera1n/releases/latest/download/$BIN_NAME"
        ;;
    *)
        echo -e "${GREEN}[+] Descargando palera1n v2.4 (Estable)...${NC}"
        URL="https://github.com/palera1n/palera1n/releases/download/v2.4/$BIN_NAME"
        ;;
esac

curl -Lo /usr/local/bin/palera1n "$URL"

# Validación de descarga correcta (si es 404 o archivo corrupto, usa fallback)
if [ ! -s /usr/local/bin/palera1n ] || grep -q "Not Found" /usr/local/bin/palera1n; then
    echo -e "${RED}[!] Error al descargar la versión seleccionada. Reintentando con versión estable (v2.4)...${NC}"
    curl -Lo /usr/local/bin/palera1n "https://github.com/palera1n/palera1n/releases/download/v2.4/$BIN_NAME"
fi

chmod +x /usr/local/bin/palera1n
echo -e "${GREEN}[✔] Binario palera1n instalado correctamente en /usr/local/bin/palera1n${NC}"

echo -e "${CYAN}[+] Limpiando caracteres CRLF (formato Windows) de scripts...${NC}"
dos2unix /root/iphone-suite/install.sh 2>/dev/null

echo -e "${CYAN}[+] Configurando permisos y acceso directo global 'iphone'...${NC}"
chmod +x /root/iphone-suite/install.sh
ln -sf /root/iphone-suite/install.sh /usr/local/bin/iphone
ln -sf /root/iphone-suite/install.sh /usr/local/bin/iphone-suite

echo -e "${CYAN}[+] Reiniciando servicio usbmuxd...${NC}"
systemctl restart usbmuxd 2>/dev/null

echo -e "\n${GREEN}[✔] ¡Instalación completa y autónoma! Ya puedes usar el comando 'iphone' o 'iphone-suite'.${NC}\n"
