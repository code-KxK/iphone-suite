#!/bin/bash

echo "[+] Instalando git si no está presente..."
apt-get update -y && apt-get install -y git dos2unix

echo "[+] Preparando e instalando iphone-suite..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Si el usuario ejecuta el instalador vía curl/bash directo
if [ -d "$SCRIPT_DIR/root" ]; then
    cd "$SCRIPT_DIR/root"
    chmod +x *.sh gaster 2>/dev/null
    dos2unix *.sh 2>/dev/null
    ./setup.sh
fi
