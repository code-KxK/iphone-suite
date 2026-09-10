#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

get_device_info() {
    MODEL=$(ideviceinfo 2>/dev/null | grep "ProductType" | cut -d ' ' -f 2)
    if [ -n "$MODEL" ]; then
        IOS_VER=$(ideviceinfo 2>/dev/null | grep "ProductVersion" | cut -d ' ' -f 2)
        NAME=$(ideviceinfo 2>/dev/null | grep "DeviceName" | cut -d ' ' -f 2-)
        INFO_STR="${GREEN}$NAME ($MODEL) | iOS: $IOS_VER | [Modo Normal]${NC}"
        return
    fi
    
    IRECV_MODE=$(irecovery -q 2>/dev/null | grep "MODE:" | cut -d ' ' -f 2)
    if [ -n "$IRECV_MODE" ]; then
        CPID=$(irecovery -q 2>/dev/null | grep "CPID:" | cut -d ' ' -f 2)
        PRODUCT=$(irecovery -q 2>/dev/null | grep "PRODUCT:" | cut -d ' ' -f 2)
        
        if [ "$IRECV_MODE" == "Recovery" ]; then
            INFO_STR="${MAGENTA}Dispositivo en [MODO RECOVERY] | Modelo: $PRODUCT | CPID: $CPID${NC}"
        elif [ "$IRECV_MODE" == "DFU" ]; then
            INFO_STR="${MAGENTA}Dispositivo en [MODO DFU] | Modelo: $PRODUCT | CPID: $CPID${NC}"
        else
            INFO_STR="${MAGENTA}Dispositivo conectado | Modo: $IRECV_MODE${NC}"
        fi
        return
    fi

    INFO_STR="${RED}Ningun dispositivo detectado (Revisa cable o usa Opcion 11)${NC}"
}

check_palera1n() {
    if ! command -v palera1n &> /dev/null; then
        echo -e "${RED}[!] palera1n no está instalado en el sistema. Descargando ahora...${NC}"
        curl -Lo /usr/local/bin/palera1n https://github.com/palera1n/palera1n/releases/latest/download/palera1n-linux-arm64
        chmod +x /usr/local/bin/palera1n
    fi
}

show_menu() {
    clear
    get_device_info
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}   HERRAMIENTAS iOS INTELIGENTES Y UNIVERSALES      ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e " [i] Estado actual: $INFO_STR"
    echo -e "${CYAN}====================================================${NC}"
    echo -e " Selecciona una opcion:"
    echo -e " ----------------------------------------------------"
    echo -e " ${GREEN} 1)${NC} Diagnóstico e Instalación Inteligente de Jailbreak"
    echo -e " ${RED} 2)${NC} Remover Jailbreak (Force Revert - palera1n)"
    echo -e " ${MAGENTA} 3)${NC} USBLiter8 Exploit (A12/A13 Pwn DFU / usbliter8_boot)"
    echo -e " ----------------------------------------------------"
    echo -e " ${GREEN} 4)${NC} Entrar a Recovery         -> (Manda iPhone a Recovery)"
    echo -e " ${GREEN} 5)${NC} Salir de Recovery         -> (Reinicia a Modo Normal)"
    echo -e " ${GREEN} 6)${NC} Ejecutar Gaster (Pwned DFU)-> (Recovery + DFU + checkm8)"
    echo -e " ${GREEN} 7)${NC} Resetear Estado DFU       -> (Gaster reset con verificación)"
    echo -e " ${GREEN} 8)${NC} Salir de DFU              -> (Instrucciones USB + Botones)"
    echo -e " ----------------------------------------------------"
    echo -e " ${GREEN} 9)${NC} Ver Estado del iPhone     -> (Normal, Recovery o DFU)"
    echo -e " ${GREEN}10)${NC} Información Hardware      -> (Datos del chip/ECID)"
    echo -e " ${CYAN}11)${NC} Forzar Emparejamiento   -> (Manda aviso 'Confiar' al iPhone)"
    echo -e " ${CYAN}12)${NC} Ver Logs del Sistema    -> (Syslog en vivo del iPhone)"
    echo -e " ${GREEN}13)${NC} Reiniciar iPhone (Reboot) -> (Universal: Todo iPhone/iOS)"
    echo -e " ----------------------------------------------------"
    echo -e " ${BLUE}14)${NC} Compañía y Liberación    -> (Operador, SIM, Región y Liberado)"
    echo -e " ${BLUE}15)${NC} Diagnóstico Batería Real -> (Capacidad, Ciclos y Porcentaje)"
    echo -e " ${BLUE}16)${NC} Información Detallada   -> (Tabla completa del iPhone)"
    echo -e " ${BLUE}17)${NC} Backup Express (Local)  -> (Copia de seguridad en Orange Pi)"
    echo -e " ${BLUE}18)${NC} Restaurar Backup Local  -> (Inyectar copia de respaldo)"
    echo -e " ----------------------------------------------------"
    echo -e " ${RED}19)${NC} Salir del Menu"
    echo -e "${CYAN}====================================================${NC}"
    echo -e -n "Ingresa tu opcion [1-19]: "
}

smart_jailbreak() {
    check_palera1n
    echo -e "\n${YELLOW}[+] Analizando dispositivo conectado...${NC}"
    MODEL=$(ideviceinfo 2>/dev/null | grep "ProductType" | cut -d ' ' -f 2)
    IOS_VER=$(ideviceinfo 2>/dev/null | grep "ProductVersion" | cut -d ' ' -f 2)
    
    if [ -z "$MODEL" ]; then
        echo -e "${RED}[!] No se detecto dispositivo en Modo Normal.${NC}"
        echo -e "${YELLOW}[i] Si el equipo esta en DFU Mode:${NC}"
        echo -e "    - Para A7-A11 (iPhone 7, X, etc.): Selecciona la Opcion 6 (Gaster checkm8)."
        echo -e "    - Para A12-A13: Selecciona la Opcion 3 (USBLiter8)."
        return
    fi
    
    echo -e "${GREEN}[+] Dispositivo detectado: $MODEL con iOS $IOS_VER${NC}"
    
    case $MODEL in
        iPhone6,*|iPhone7,*|iPhone8,*|iPhone9,*|iPhone10,*)
            echo -e "${CYAN}[i] Arquitectura A7-A11 detectada.${NC}"
            echo -e "${GREEN}[=>] Recomendacion: Utilizar palera1n.${NC}"
            echo -e "\n${YELLOW}Selecciona la modalidad de Jailbreak para palera1n:${NC}"
            echo -e "  1) Rootless  (-l) [Recomendado para iOS 15/16/17]"
            echo -e "  2) Rootful   (-f) [Tradicional / FakeFS]"
            echo -n "Opción [1-2]: "
            read -r jb_type
            
            if [ "$jb_type" == "2" ]; then
                echo -e "\n${GREEN}[+] Iniciando palera1n (Rootful -f)...${NC}"
                palera1n -f
            else
                echo -e "\n${GREEN}[+] Iniciando palera1n (Rootless -l)...${NC}"
                palera1n -l
            fi
            ;;
        iPhone11,*|iPhone12,*)
            echo -e "${CYAN}[i] Arquitectura A12/A13 detectada ($MODEL).${NC}"
            echo -e "${YELLOW}[=>] Recomendacion:${NC}"
            echo -e "     1. Pon el equipo en MODO DFU."
            echo -e "     2. Utiliza la OPCION 3 (USBLiter8 Exploit) en el menu."
            echo -e "     3. En sistema operativo activo puedes usar Dopamine (iOS 15.0 - 16.5.1)."
            ;;
        *)
            echo -e "${CYAN}[i] Modelo $MODEL detectado.${NC}"
            echo -e "${YELLOW}[i] Verifica compatibilidad segun tu version de iOS ($IOS_VER).${NC}"
            ;;
    esac
}

force_revert_menu() {
    check_palera1n
    echo -e "\n${RED}[!] Opción de Remoción de Jailbreak (Force Revert - palera1n)${NC}"
    echo -e "${YELLOW}Selecciona la modalidad con la que se hizo el Jailbreak en este equipo:${NC}"
    echo -e "  1) Rootless  (-l --force-revert)"
    echo -e "  2) Rootful   (-f --force-revert)"
    echo -n "Opción [1-2]: "
    read -r rev_type
    
    if [ "$rev_type" == "2" ]; then
        echo -e "\n${RED}[+] Ejecutando Force Revert en modo Rootful...${NC}"
        palera1n -f --force-revert
    else
        echo -e "\n${RED}[+] Ejecutando Force Revert en modo Rootless...${NC}"
        palera1n -l --force-revert
    fi
}

run_usbliter8() {
    echo -e "\n${YELLOW}[+] Verificando compatibilidad con USBLiter8 (A12/A13)...${NC}"
    CPID=$(irecovery -q 2>/dev/null | grep "CPID:" | cut -d ' ' -f 2)
    
    if [ "$CPID" == "0x8020" ] || [ "$CPID" == "0x8030" ]; then
        echo -e "${GREEN}[+] Chip compatible detectado ($CPID). Iniciando Suite...${NC}"
        if [ -x "/opt/usbliter8/usbliter8_boot" ]; then
            cd /opt/usbliter8 && ./usbliter8_boot
        elif [ -x "/opt/usbliter8/usbliter8" ]; then
            cd /opt/usbliter8 && ./usbliter8
        else
            echo -e "${RED}[!] No se encontró el binario compilado en /opt/usbliter8.${NC}"
        fi
    else
        echo -e "${RED}[!] Dispositivo incompatible con USBLiter8 (CPID detectado: $CPID).${NC}"
        echo -e "${YELLOW}[i] USBLiter8 es exclusivo para chips A12 y A13.${NC}"
        echo -e "${YELLOW}[i] Tu dispositivo actual es un iPhone 7 (A10 - CPID 0x8010). Usa la Opción 6 (Gaster) y palera1n.${NC}"
    fi
    echo -e "\nPresiona Enter para continuar..."
    read -r
}

opcion_6() {
    echo -e "\n${CYAN}[+] Enviando el dispositivo a Modo Recovery...${NC}"
    UDID=$(idevice_id -l 2>/dev/null | head -n 1)
    if [ -n "$UDID" ]; then
        ideviceenterrecovery "$UDID" 2>/dev/null
    fi
    
    echo -e "\n${YELLOW}====================================================${NC}"
    echo -e "${YELLOW}INSTRUCCIONES PARA MODO DFU (iPhone 7):${NC}"
    echo -e "1. Presiona MANTENER encendido + VOLUMEN ABAJO por 10 seg."
    echo -e "2. Suelta ENCENDIDO pero MANTÉN VOLUMEN ABAJO por 5 seg."
    echo -e "3. La pantalla debe quedar COMPLETAMENTE EN NEGRO."
    echo -e "${YELLOW}====================================================${NC}"
    read -r -p "Presiona Enter cuando la pantalla esté en negro para aplicar Gaster..."
    
    GASTER_BIN=""
    if [ -x "/root/iphone-suite/gaster" ]; then
        GASTER_BIN="/root/iphone-suite/gaster"
    elif [ -x "/root/gaster/gaster" ]; then
        GASTER_BIN="/root/gaster/gaster"
    elif command -v gaster &>/dev/null; then
        GASTER_BIN="gaster"
    fi

    if [ -n "$GASTER_BIN" ]; then
        $GASTER_BIN pwn
    else
        echo -e "${RED}[!] gaster no está instalado o no se encontró en las rutas del sistema.${NC}"
    fi
}

opcion_7() {
    echo -e "\n${CYAN}[+] Verificando/Reseteando comunicación USB...${NC}"
    GASTER_BIN=""
    if [ -x "/root/iphone-suite/gaster" ]; then
        GASTER_BIN="/root/iphone-suite/gaster"
    elif [ -x "/root/gaster/gaster" ]; then
        GASTER_BIN="/root/gaster/gaster"
    elif command -v gaster &>/dev/null; then
        GASTER_BIN="gaster"
    fi

    if [ -n "$GASTER_BIN" ]; then
        SALIDA=$($GASTER_BIN reset 2>&1)
        if echo "$SALIDA" | grep -q "Found the USB handle"; then
            echo -e "\n${GREEN}[✔] ÉXITO: El bus USB y el estado DFU se comunicaron correctamente.${NC}"
        else
            echo -e "\n${RED}[✖] ERROR: No se pudo verificar el dispositivo en USB/DFU.${NC}"
        fi
    else
        echo -e "${RED}[!] Executable 'gaster' no encontrado.${NC}"
    fi
}

check_carrier_info() {
    echo -e "\n${CYAN}====================================================${NC}"
    echo -e "${YELLOW}      DIAGNÓSTICO DE COMPAÑÍA, SIM Y LIBERACIÓN     ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    
    RAW_INFO=$(ideviceinfo 2>/dev/null)
    
    if [ -z "$RAW_INFO" ]; then
        echo -e "${RED}[!] Desbloquea el iPhone y acepta el aviso 'Confiar'.${NC}"
        return
    fi

    MODEL_REGION=$(echo "$RAW_INFO" | grep "RegionInfo" | cut -d ' ' -f 2)
    CARRIER=$(echo "$RAW_INFO" | grep "CarrierBundleInfo" | cut -d ' ' -f 2-)
    SIM_STATUS=$(echo "$RAW_INFO" | grep "SIMStatus" | cut -d ' ' -f 2)
    ICCID=$(echo "$RAW_INFO" | grep "IntegratedCircuitCardIdentity" | cut -d ' ' -f 2)
    IMEI=$(echo "$RAW_INFO" | grep "InternationalMobileEquipmentIdentity" | cut -d ' ' -f 2)

    echo -e " IMEI:                  ${GREEN}${IMEI:-No disponible}${NC}"
    echo -e " Estado de Tarjeta SIM: ${YELLOW}${SIM_STATUS:-No detectada}${NC}"
    
    if [ -n "$CARRIER" ]; then
        echo -e " Compañía del Chip:     ${GREEN}$CARRIER${NC}"
    else
        echo -e " Compañía del Chip:     ${RED}Sin SIM o Compañía Desconocida${NC}"
    fi

    case "$MODEL_REGION" in
        *LL*|*LL/A*) ORIGEN="Estados Unidos (Americano)" ;;
        *MX*|*MX/A*) ORIGEN="México (Nacional)" ;;
        *E*|*E/A*)   ORIGEN="México / Latinoamérica" ;;
        *)           ORIGEN="Internacional ($MODEL_REGION)" ;;
    esac
    echo -e " Origen del Equipo:     ${CYAN}$ORIGEN${NC}"

    if [ "$SIM_STATUS" == "kCTSIMSupportSIMStatusReady" ]; then
        echo -e " Estado de Red:         ${GREEN}[✔] SIM Activa y Reconocida (Posiblemente Liberado / Compatible)${NC}"
    else
        echo -e " Estado de Red:         ${YELLOW}[!] Insertar un chip para validar compatibilidad de red.${NC}"
    fi
    echo -e "${CYAN}====================================================${NC}"
}

battery_diagnostics() {
    echo -e "\n${CYAN}====================================================${NC}"
    echo -e "${YELLOW}        DIAGNÓSTICO DETALLADO DE BATERÍA            ${NC}"
    echo -e "${CYAN}====================================================${NC}"
    
    BAT_DATA=$(ideviceinfo -q com.apple.mobile.battery 2>/dev/null)
    
    if [ -z "$BAT_DATA" ]; then
        echo -e "${RED}[!] No se pudo leer la batería. Desbloquea la pantalla del iPhone.${NC}"
        return
    fi

    CAP_ACTUAL=$(echo "$BAT_DATA" | grep "BatteryCurrentCapacity" | cut -d ' ' -f 2)
    CHARGING=$(echo "$BAT_DATA" | grep "BatteryIsCharging" | cut -d ' ' -f 2)
    FULLY_CHARGED=$(echo "$BAT_DATA" | grep "FullyCharged" | cut -d ' ' -f 2)
    CYCLES=$(echo "$BAT_DATA" | grep "CycleCount" | cut -d ' ' -f 2)
    MAX_CAP=$(echo "$BAT_DATA" | grep "MaximumCapacityPercent" | cut -d ' ' -f 2)
    DESIGN_CAP=$(echo "$BAT_DATA" | grep "DesignCapacity" | cut -d ' ' -f 2)

    [ "$CHARGING" == "true" ] && ESTADO_CARGA="Cargando actualmente" || ESTADO_CARGA="Desconectado de la corriente"
    [ "$FULLY_CHARGED" == "true" ] && CARGA_COMPLETA="Sí (100%)" || CARGA_COMPLETA="No"

    echo -e " Porcentaje de Carga Actual: ${GREEN}${CAP_ACTUAL:-N/A}%${NC}"
    echo -e " Estado de la Carga:         ${YELLOW}$ESTADO_CARGA${NC}"
    echo -e " Carga Completa Alcanzada:  ${CYAN}$CARGA_COMPLETA${NC}"
    echo " ----------------------------------------------------"
    
    if [ -n "$CYCLES" ]; then
        echo -e " Ciclos de Carga Completados: ${GREEN}$CYCLES ciclos${NC}"
    else
        echo -e " Ciclos de Carga Completados: ${YELLOW}Consulta no permitida directamente por iOS${NC}"
    fi

    if [ -n "$MAX_CAP" ]; then
        echo -e " Condición / Salud de Batería: ${GREEN}$MAX_CAP%${NC}"
    else
        echo -e " Condición / Salud de Batería: ${YELLOW}Abre Ajustes > Batería > Salud en el iPhone${NC}"
    fi

    if [ -n "$DESIGN_CAP" ]; then
        echo -e " Capacidad de Fábrica (mAh):  ${CYAN}$DESIGN_CAP mAh${NC}"
    fi
    echo -e "${CYAN}====================================================${NC}"
}

opcion_detallada() {
    echo -e "\n${CYAN}[+] Información detallada del dispositivo:${NC}"
    echo "----------------------------------------"
    echo "Nombre:          $(ideviceinfo -k DeviceName 2>/dev/null)"
    echo "Modelo:          $(ideviceinfo -k ProductType 2>/dev/null)"
    echo "Versión iOS:     $(ideviceinfo -k ProductVersion 2>/dev/null)"
    echo "Número de Serie: $(ideviceinfo -k SerialNumber 2>/dev/null)"
    echo "UDID:            $(ideviceinfo -k UniqueDeviceID 2>/dev/null)"
    echo "Activado:        $(ideviceinfo -k ActivationState 2>/dev/null)"
    echo "----------------------------------------"
}

backup_express() {
    echo -e "\n${YELLOW}[+] Iniciando Copia de Seguridad local (Backup Express)...${NC}"
    mkdir -p /opt/iphone_backups
    BACKUP_DIR="/opt/iphone_backups/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo -e "${CYAN}[i] El respaldo se guardará en: $BACKUP_DIR${NC}"
    
    if command -v idevicebackup2 &> /dev/null; then
        idevicebackup2 backup "$BACKUP_DIR"
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}[✔] ¡Copia de seguridad completada con éxito!${NC}"
        else
            echo -e "\n${RED}[!] Error al realizar el respaldo.${NC}"
        fi
    else
        echo -e "${RED}[!] La herramienta 'idevicebackup2' no está instalada.${NC}"
    fi
}

restore_backup() {
    echo -e "\n${YELLOW}[+] Buscando respaldos locales disponibles...${NC}"
    if [ ! -d "/opt/iphone_backups" ]; then
        echo -e "${RED}[!] No existe la carpeta de respaldos.${NC}"
        return
    fi
    
    BACKUPS=( /opt/iphone_backups/backup_* )
    if [ ${#BACKUPS[@]} -eq 0 ] || [ ! -d "${BACKUPS[0]}" ]; then
        echo -e "${RED}[!] No hay respaldos locales guardados.${NC}"
    else
        echo -e "${GREEN}[+] Respaldos encontrados:${NC}"
        i=1
        for bkp in "${BACKUPS[@]}"; do
            echo -e "  $i) $(basename "$bkp")"
            ((i++))
        done
        echo -n "Elige número de respaldo a restaurar (0 para cancelar): "
        read -r bkp_choice
        if [[ "$bkp_choice" =~ ^[0-9]+$ ]] && [ "$bkp_choice" -gt 0 ] && [ "$bkp_choice" -le "${#BACKUPS[@]}" ]; then
            SELECTED_BKP="${BACKUPS[$((bkp_choice-1))]}"
            echo -e "${YELLOW}[+] Restaurando respaldo desde $(basename "$SELECTED_BKP")...${NC}"
            idevicebackup2 restore "$SELECTED_BKP"
        fi
    fi
}

enter_recovery() {
    echo -e "\n${YELLOW}[+] Buscando UDID del dispositivo...${NC}"
    UDID=$(idevice_id -l 2>/dev/null | head -n 1)
    if [ -z "$UDID" ]; then
        UDID=$(ideviceinfo 2>/dev/null | grep "UniqueDeviceID" | cut -d ' ' -f 2)
    fi
    
    if [ -n "$UDID" ]; then
        echo -e "${GREEN}[+] Enviando dispositivo $UDID a Modo Recovery...${NC}"
        ideviceenterrecovery "$UDID"
    else
        echo -e "${RED}[!] No se pudo obtener el UDID.${NC}"
    fi
}

while true; do
    show_menu
    read -r choice
    case $choice in
        1) smart_jailbreak; echo -e "\nPresiona Enter..."; read -r ;;
        2) force_revert_menu; echo -e "\nPresiona Enter..."; read -r ;;
        3) run_usbliter8 ;;
        4) enter_recovery; echo -e "\nPresiona Enter..."; read -r ;;
        5) irecovery -n ; read -r ;;
        6) opcion_6; echo -e "\nPresiona Enter..."; read -r ;;
        7) opcion_7; echo -e "\nPresiona Enter..."; read -r ;;
        8) echo -e "\n${YELLOW}Desconecta el USB y manten Bajar Volumen + Encendido para salir de DFU.${NC}" ; read -r ;;
        9) 
            if ideviceinfo &>/dev/null; then
                ideviceinfo | grep -E "ActivationState|ProductVersion|Mode" 2>/dev/null
            else
                echo -e "${YELLOW}[i] El dispositivo no está en Modo Normal. Verificando estado Recovery/DFU...${NC}"
                irecovery -q 2>/dev/null || echo -e "${RED}[!] No se detecta ningún dispositivo conectado.${NC}"
            fi
            read -r 
            ;;
        10) ideviceinfo | grep -E "DeviceName|ProductType|UniqueDeviceID|HardwareModel|CPUArchitecture" 2>/dev/null ; read -r ;;
        11) echo -e "\n${YELLOW}[+] Por favor, acepta el mensaje de 'Confiar' en la pantalla del iPhone.${NC}"; idevicepair pair; read -r ;;
        12) echo -e "\n${YELLOW}[+] Mostrando logs en vivo. Presiona Ctrl+C para salir.${NC}"; sleep 2; idevicesyslog ;;
        13) idevicediagnostics restart 2>/dev/null ; read -r ;;
        14) check_carrier_info; echo -e "\nPresiona Enter..."; read -r ;;
        15) battery_diagnostics; echo -e "\nPresiona Enter..."; read -r ;;
        16) opcion_detallada; echo -e "\nPresiona Enter..."; read -r ;;
        17) backup_express; echo -e "\nPresiona Enter..."; read -r ;;
        18) restore_backup; echo -e "\nPresiona Enter..."; read -r ;;
        19) echo -e "\n${GREEN}Saliendo del menú...${NC}\n" ; exit 0 ;;
        *) echo -e "\n${RED}Opción inválida.${NC}" ; sleep 1 ;;
    esac
done
