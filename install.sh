#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [ -d "$SCRIPT_DIR/root" ]; then
    cd "$SCRIPT_DIR/root"
    chmod +x *.sh gaster 2>/dev/null
    dos2unix *.sh 2>/dev/null
    ./setup.sh
else
    echo "[!] Error: No se encontró la carpeta 'root' del proyecto."
fi
