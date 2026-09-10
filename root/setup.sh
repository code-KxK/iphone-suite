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

# Copiar Gaster al sistema
GASTER_FILE=$(find "$SCRIPT_DIR" -name "gaster" -type f 2>/dev/null | head -n 1)
if [ -n "$GASTER_FILE" ]; then
    cp "$GASTER_FILE" /usr/local/bin/gaster
    chmod +x /usr/local/bin/gaster
    echo -e "${GREEN}[✔] Herramienta Gaster vinculada en /usr/local/bin/gaster.${NC}"
fi

# Copiar USBLiter8 si existe
if [ -d "$SCRIPT_DIR/usbliter8" ]; then
    cp -r "$SCRIPT_DIR/usbliter8" /opt/
    chmod +x /opt/usbliter8/* 2>/dev/null
    echo -e "${GREEN}[✔] Herramienta USBLiter8 restaurada.${NC}"
fi

# --- DETECCIÓN DINÁMICA DE VERSIONES Y ASSETS ---
echo -e "\n${CYAN}[+] Consultando publicaciones disponibles en la API de GitHub...${NC}"

RELEASES_JSON=$(curl -sSL "https://api.github.com/repos/palera1n/palera1n/releases")

LATEST_STABLE=$(echo "$RELEASES_JSON" | jq -r '.[] | select(.prerelease == false and (.tag_name | contains("beta") | not)) | .tag_name' 2>/dev/null | head -n 1)
LATEST_BETA=$(echo "$RELEASES_JSON" | jq -r '.[] | select(.prerelease == true or (.tag_name | contains("beta"))) | .tag_name' 2>/dev/null | head -n 1)

[ -z "$LATEST_STABLE" ] || [ "$LATEST_STABLE" == "null" ] && LATEST_STABLE="v2.4"
[ -z "$LATEST_BETA" ] || [ "$LATEST_BETA" == "null" ] && LATEST_BETA="v3.0.0-beta.2"

while true; do
    echo -e "\n${CYAN}====================================================${NC}"
    echo -e "${YELLOW}   DETECTOR DINÁMICO DE VERSIONES PALERA1N          ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e " Versiones detectadas en tiempo real:"
    echo -e "  1) Última versión ESTABLE  -> [ $LATEST_STABLE ]"
    echo -e "  2) Última versión BETA / PRE  -> [ $LATEST_BETA ]"
    echo -e "  3) Descarga directa (Latest generic release)"
    echo -e "${CYAN}====================================================${NC}"

    echo -n "Selecciona cuál instalar [1-3] (Por defecto [1]): "
    exec 3< /dev/tty
    read -r -u 3 palera_choice
    exec 3<&-

    case $palera_choice in
        2)
            SELECTED_TAG="$LATEST_BETA"
            echo -e "${YELLOW}[+] Analizando archivos adjuntos de $SELECTED_TAG...${NC}"
            ;;
        3)
            SELECTED_TAG="latest"
            echo -e "${CYAN}[+] Obteniendo enlace de la última versión generic...${NC}"
            ;;
        *)
            SELECTED_TAG="$LATEST_STABLE"
            echo -e "${GREEN}[+] Analizando archivos adjuntos de $SELECTED_TAG...${NC}"
            ;;
    esac

    # Búsqueda dinámica del asset ARM64 dentro del JSON de la release
    if [ "$SELECTED_TAG" == "latest" ]; then
        DOWNLOAD_URL="https://github.com/palera1n/palera1n/releases/latest/download/palera1n-linux-arm64"
    else
        RELEASE_INFO=$(echo "$RELEASES_JSON" | jq -r --arg TAG "$SELECTED_TAG" '.[] | select(.tag_name == $TAG)')
        DOWNLOAD_URL=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | test("arm64|aarch64"; "i")) | .browser_download_url' 2>/dev/null | head -n 1)
    fi

    if [ -n "$DOWNLOAD_URL" ] && [ "$DOWNLOAD_URL" != "null" ]; then
        echo -e "${CYAN}[+] Descargando desde: $DOWNLOAD_URL${NC}"
        curl -sSL -o /tmp/palera1n_temp "$DOWNLOAD_URL"
        
        # Si viene en tar.gz / zip, se descomprime automáticamente
        if file /tmp/palera1n_temp | grep -q "gzip compressed"; then
            tar -xzf /tmp/palera1n_temp -C /tmp/
            EXTRACTED=$(find /tmp -type f -name "palera1n*" ! -name "*.gz" | head -n 1)
            mv "$EXTRACTED" /usr/local/bin/palera1n
            rm -f /tmp/palera1n_temp
        else
            mv /tmp/palera1n_temp /usr/local/bin/palera1n
        fi

        chmod +x /usr/local/bin/palera1n

        # Validar que sea un binario ejecutable y no un error HTML
        if [ -s /usr/local/bin/palera1n ] && ! grep -q "Not Found" /usr/local/bin/palera1n; then
            echo -e "${GREEN}[✔] Binario palera1n guardado correctamente en /usr/local/bin/palera1n${NC}"
            break
        else
            rm -f /usr/local/bin/palera1n
            echo -e "${RED}[!] El archivo descargado está corrupto o no es válido.${NC}"
        fi
    else
        echo -e "${RED}[!] No se encontró ningún ejecutable ARM64 adjunto en la versión $SELECTED_TAG.${NC}"
    fi

    echo -e "${YELLOW}[i] Por favor, selecciona otra opción del menú.${NC}\n"
    sleep 2
done

# Configurar el acceso directo del menú
dos2unix "$SCRIPT_DIR/root/install.sh" 2>/dev/null
chmod +x "$SCRIPT_DIR/root/install.sh"
ln -sf "$SCRIPT_DIR/root/install.sh" /usr/local/bin/iphone
ln -sf "$SCRIPT_DIR/root/install.sh" /usr/local/bin/iphone-suite

systemctl restart usbmuxd 2>/dev/null

echo -e "\n${GREEN}[✔] ¡Instalación completa y exitosa!${NC}"
echo -e "${YELLOW}[i] Escribe 'iphone' en cualquier momento para iniciar el menú.${NC}\n"
