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
    jq \
    dos2unix \
    libusb-1.0-0-dev \
    python3 \
    python3-pip 2>/dev/null || apt-get install -y libimobiledevice-utils irecovery usbmuxd build-essential git curl jq dos2unix libusb-1.0-0-dev python3 python3-pip

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

# --- DETECCIÓN DINÁMICA DE VERSIONES VÍA API DE GITHUB ---
echo -e "\n${CYAN}[+] Consultando últimas versiones en GitHub de palera1n...${NC}"

ARCH=$(uname -m)
BIN_NAME="palera1n-linux-arm64"
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    BIN_NAME="palera1n-linux-x86_64"
fi

# Obtener los tags reales de las últimas publicaciones desde la API
RELEASES_JSON=$(curl -s "https://api.github.com/repos/palera1n/palera1n/releases")
LATEST_STABLE=$(echo "$RELEASES_JSON" | grep -v '"prerelease": true' | grep -m 1 '"tag_name":' | cut -d '"' -f 4)
LATEST_BETA=$(echo "$RELEASES_JSON" | grep -m 1 '"tag_name":' | cut -d '"' -f 4)

[ -z "$LATEST_STABLE" ] && LATEST_STABLE="v2.4"
[ -z "$LATEST_BETA" ] && LATEST_BETA="v3.0.0-beta.1"

echo -e "\n${CYAN}====================================================${NC}"
echo -e "${YELLOW}   DETECTOR DINÁMICO DE VERSIONES PALERA1N          ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e " Versiones detectadas en tiempo real:"
echo -e "  1) Última versión ESTABLE  -> [ $LATEST_STABLE ]"
echo -e "  2) Última versión BETA / PRE  -> [ $LATEST_BETA ]"
echo -e "  3) Descarga automática directa (Latest generic)"
echo -e "${CYAN}====================================================${NC}"
echo -n "Selecciona cuál instalar [1-3] (Por defecto [1]): "
read -r palera_choice

case $palera_choice in
    2)
        SELECTED_TAG="$LATEST_BETA"
        echo -e "${YELLOW}[+] Instalando versión Beta detectada ($SELECTED_TAG)...${NC}"
        URL="https://github.com/palera1n/palera1n/releases/download/$SELECTED_TAG/$BIN_NAME"
        ;;
    3)
        echo -e "${CYAN}[+] Instalando versión 'Latest'...${NC}"
        URL="https://github.com/palera1n/palera1n/releases/latest/download/$BIN_NAME"
        ;;
    *)
        SELECTED_TAG="$LATEST_STABLE"
        echo -e "${GREEN}[+] Instalando versión Estable detectada ($SELECTED_TAG)...${NC}"
        URL="https://github.com/palera1n/palera1n/releases/download/$SELECTED_TAG/$BIN_NAME"
        ;;
esac

curl -Lo /usr/local/bin/palera1n "$URL"

# Respaldo de seguridad si el asset en la beta no existe con ese nombre exacto
if [ ! -s /usr/local/bin/palera1n ] || grep -q "Not Found" /usr/local/bin/palera1n; then
    echo -e "${RED}[!] Archivo no encontrado en la API para esa versión. Aplicando descarga de respaldo...${NC}"
    curl -Lo /usr/local/bin/palera1n "https://github.com/palera1n/palera1n/releases/latest/download/$BIN_NAME"
fi

chmod +x /usr/local/bin/palera1n
echo -e "${GREEN}[✔] Binario palera1n guardado correctamente en /usr/local/bin/palera1n${NC}"

echo -e "${CYAN}[+] Limpiando caracteres CRLF de scripts...${NC}"
dos2unix /root/iphone-suite/install.sh 2>/dev/null

echo -e "${CYAN}[+] Configurando permisos y acceso directo global 'iphone'...${NC}"
chmod +x /root/iphone-suite/install.sh
ln -sf /root/iphone-suite/install.sh /usr/local/bin/iphone
ln -sf /root/iphone-suite/install.sh /usr/local/bin/iphone-suite

echo -e "${CYAN}[+] Reiniciando servicio usbmuxd...${NC}"
systemctl restart usbmuxd 2>/dev/null

echo -e "\n${GREEN}[✔] ¡Instalación completa y autónoma! Ya puedes usar el comando 'iphone' o 'iphone-suite'.${NC}\n"
