#!/system/bin/sh
# service.sh - Versión Minerva M+ (Soporte Android 13/16 + Reloj/Batería + Horarios + Modo Grabación)
ST_DIR="/data/local/tmp/minenet"

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

# Detectar versión de Android (SDK)
SDK=$(getprop ro.build.version.sdk)
# Android 13 = SDK 33 | Android 14 = SDK 34 | Android 15 = SDK 35 | Android 16 = SDK 36

# Siempre actualizar slot 0 y slot 1 — evita que el slot 1 quede fijo con barras llenas
# El fix de Android 13 es solo para el WiFi, no para los slots
SLOTS="0 1"

# Función maestra para sincronizar Icono -> Velocidad (iptables)
sync_network_speed() {
    TYPE="$1"
    iptables -F INPUT 2>/dev/null
    iptables -F OUTPUT 2>/dev/null

    case $TYPE in
        "g")
            iptables -A INPUT -m limit --limit 5/s --limit-burst 4 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 5/s --limit-burst 4 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "s")
            iptables -A INPUT -m limit --limit 8/s --limit-burst 6 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 8/s --limit-burst 6 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
         "sw")
            iptables -A INPUT -m limit --limit 200/s --limit-burst 50 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 200/s --limit-burst 50 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
         "starlink")
            iptables -A INPUT -m limit --limit 2000/s --limit-burst 500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 2000/s --limit-burst 500 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "e+")
            iptables -A INPUT -m limit --limit 250/s --limit-burst 70 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 250/s --limit-burst 70 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "gprs+")
            iptables -A INPUT -m limit --limit 70/s --limit-burst 30 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 70/s --limit-burst 30 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "1x")
            iptables -A INPUT -m limit --limit 10/s --limit-burst 8 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 10/s --limit-burst 8 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "e")
            iptables -A INPUT -m limit --limit 15/s --limit-burst 10 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 15/s --limit-burst 10 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "3g")
            iptables -A INPUT -m limit --limit 150/s --limit-burst 100 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 150/s --limit-burst 100 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "h")
            iptables -A INPUT -m limit --limit 400/s --limit-burst 300 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 400/s --limit-burst 300 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "h+")
            iptables -A INPUT -m limit --limit 800/s --limit-burst 700 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 800/s --limit-burst 700 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "hspa++")
            iptables -A INPUT -m limit --limit 1000/s --limit-burst 500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 1000/s --limit-burst 500 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "lte")
            iptables -A INPUT -m limit --limit 2000/s --limit-burst 1500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 2000/s --limit-burst 1500 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "lte+")
            iptables -A INPUT -m limit --limit 8000/s --limit-burst 8000 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 8000/s --limit-burst 8000 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "5ge")
            iptables -A INPUT -m limit --limit 6000/s --limit-burst 3500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 6000/s --limit-burst 3500 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "5g+")
            iptables -A INPUT -m limit --limit 7000/s --limit-burst 700 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 7000/s --limit-burst 700 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        *)
            iptables -F INPUT 2>/dev/null
            iptables -F OUTPUT 2>/dev/null
            ;;
    esac
}

# Función para ocultar WiFi de forma explícita
# En Android 13, el comando combinado no funciona bien — hay que enviarlo por separado
hide_wifi() {
    am broadcast -a com.android.systemui.demo -e command wifi -e wifi hide
    # Pequeña pausa para que el sistema lo procese antes del comando de red
    sleep 1
}

# --- ARCHIVO DE CONFIGURACIÓN DE HORARIOS ---
# Si no existe, se crea con valores por defecto
SCHEDULE_CONF="$ST_DIR/schedule.conf"
create_default_schedule() {
    mkdir -p "$ST_DIR"
    cat > "$SCHEDULE_CONF" << 'EOF'
# Configuración de perfiles de red por horario
# Formato: HORA_INICIO HORA_FIN TIPO_RED NIVEL
# Horas en formato 24h (0-23)
# Tipos: g, e, 1x, 3g, h, h+, lte, lte+, 5g, 5g+, 5ge
# Nivel: 0-4

# De madrugada — 3G baja señal
00 07 3g 2

# Mañana — 4G buena señal
07 14 lte 4

# Tarde — 5G señal máxima
14 23 5g 4

# Noche — LTE señal media
23 24 lte 3
EOF
}
[ ! -f "$SCHEDULE_CONF" ] && create_default_schedule

# Función para leer el perfil activo según la hora actual
get_schedule_profile() {
    CURRENT_HOUR=$(date +%H | sed 's/^0//')
    # Leer schedule.conf línea por línea (ignorar comentarios y vacías)
    while IFS= read -r line; do
        # Saltar comentarios y líneas vacías
        echo "$line" | grep -qE '^\s*#|^\s*$' && continue
        SCH_START=$(echo "$line" | awk '{print $1}' | sed 's/^0//')
        SCH_END=$(echo "$line" | awk '{print $2}' | sed 's/^0//')
        SCH_TYPE=$(echo "$line" | awk '{print $3}')
        SCH_LEVEL=$(echo "$line" | awk '{print $4}')
        [ -z "$SCH_TYPE" ] && continue
        if [ "$CURRENT_HOUR" -ge "$SCH_START" ] && [ "$CURRENT_HOUR" -lt "$SCH_END" ]; then
            echo "$SCH_TYPE $SCH_LEVEL"
            return
        fi
    done < "$SCHEDULE_CONF"
}

# --- INICIO DEL MODO DEMO ---
settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter
am broadcast -a com.android.systemui.demo -e command status -e tty show

# NFC activo por defecto al arrancar
am broadcast -a com.android.systemui.demo -e command status -e nfc show

# En Android 13: ocultar WiFi inmediatamente al arrancar
if [ "$SDK" -le 33 ]; then
    hide_wifi
fi

# --- PREPARACIÓN DE BUCLE ---
mkdir -p "$ST_DIR"
LAST_RX=0
LAST_TX=0
LAST_TYPE="5g"

while true; do
    # 1. MODO GRABACIÓN — tiene prioridad sobre todo lo demás
    # Activar: touch /data/local/tmp/minenet/record
    # Desactivar: rm /data/local/tmp/minenet/record
    if [ -f "$ST_DIR/record" ]; then
        RECORD_MODE="true"
    else
        RECORD_MODE="false"
    fi

    # NFC — activo por defecto, se oculta si existe el archivo "nonfc"
    if [ -f "$ST_DIR/nonfc" ]; then
        am broadcast -a com.android.systemui.demo -e command status -e nfc hide
    else
        am broadcast -a com.android.systemui.demo -e command status -e nfc show
    fi

    # 2. LECTURA DE DATOS (o preset de grabación)
    if [ "$RECORD_MODE" = "true" ]; then
        # En modo grabación todo está fijo y limpio
        T1="lte"
        L1="4"
        C1=""
        R1="false"
        BATT_OVERRIDE="100"
        BATT_PLUGGED_OVERRIDE="false"
        CLOCK_OVERRIDE="1200"
    else
        # Modo normal — leer archivos de control
        T1=$(cat $ST_DIR/type 2>/dev/null | tr -d '[:space:]')

        # Si no hay tipo manual, aplicar perfil de horario
        if [ -z "$T1" ]; then
            SCHED=$(get_schedule_profile)
            if [ -n "$SCHED" ]; then
                T1=$(echo "$SCHED" | awk '{print $1}')
                SCHED_LEVEL=$(echo "$SCHED" | awk '{print $2}')
            fi
        fi
        [ -z "$T1" ] && T1="5g"

        L1=$(cat $ST_DIR/level 2>/dev/null | tr -d '[:space:]')
        # Si no hay nivel manual pero sí hay horario activo, usar el del horario
        [ -z "$L1" ] && L1="${SCHED_LEVEL:-4}"

        C1=$(cat $ST_DIR/carrier 2>/dev/null || echo "")
        R1=$(cat $ST_DIR/roaming 2>/dev/null | tr -d '[:space:]' || echo "false")
        BATT_OVERRIDE=""
        BATT_PLUGGED_OVERRIDE=""
        CLOCK_OVERRIDE=""
    fi

    # 3. RADAR DE TRÁFICO DIRECCIONAL
    NET_STATS=$(cat /proc/net/dev | grep -E "wlan0|rmnet_data0")
    CURRENT_RX=$(echo "$NET_STATS" | awk '{s+=$2} END {print s}')
    CURRENT_TX=$(echo "$NET_STATS" | awk '{s+=$10} END {print s}')

    if [ "$CURRENT_RX" != "$LAST_RX" ] && [ "$CURRENT_TX" != "$LAST_TX" ]; then
        ACTIVITY="inout"
    elif [ "$CURRENT_RX" != "$LAST_RX" ]; then
        ACTIVITY="in"
    elif [ "$CURRENT_TX" != "$LAST_TX" ]; then
        ACTIVITY="out"
    else
        ACTIVITY="none"
    fi

    LAST_RX=$CURRENT_RX
    LAST_TX=$CURRENT_TX

    # 4. ACTIVADOR DE VELOCIDAD (solo si cambió el tipo)
    if [ "$T1" != "$LAST_TYPE" ]; then
        sync_network_speed "$T1"
        LAST_TYPE="$T1"
    fi

    # 5. LÓGICA DE ICONOS
    if [ "$T1" = "sw" ]; then
        MOBILE_CMD="-e mobile show"; DTYPE="sw"
    elif [ "$T1" = "starlink" ]; then
        MOBILE_CMD="-e mobile show"; DTYPE="starlink"
    elif [ "$T1" = "e+" ]; then
        MOBILE_CMD="-e mobile show"; DTYPE="e"
    elif [ "$T1" = "gprs+" ]; then
        MOBILE_CMD="-e mobile show"; DTYPE="g"
    elif [ "$T1" = "hspa++" ]; then
        MOBILE_CMD="-e mobile show"; DTYPE="h+"
    else
        MOBILE_CMD="-e mobile show"; DTYPE="$T1"
    fi

    # 6. RELOJ EN TIEMPO REAL (o fijo en grabación)
    if [ -n "$CLOCK_OVERRIDE" ]; then
        am broadcast -a com.android.systemui.demo -e command clock -e hhmm "$CLOCK_OVERRIDE"
    else
        CLOCK_NOW=$(date +%H%M)
        am broadcast -a com.android.systemui.demo -e command clock -e hhmm "$CLOCK_NOW"
    fi

    # 6b. BATERÍA EN TIEMPO REAL (o fija al 100 en grabación)
    if [ -n "$BATT_OVERRIDE" ]; then
        BATT_LEVEL="$BATT_OVERRIDE"
        BATT_PLUGGED="$BATT_PLUGGED_OVERRIDE"
    else
        BATT_LEVEL=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null | tr -d '[:space:]')
        if [ -z "$BATT_LEVEL" ]; then
            BATT_LEVEL=$(dumpsys battery 2>/dev/null | grep "level:" | awk '{print $2}' | tr -d '[:space:]')
        fi
        [ -z "$BATT_LEVEL" ] && BATT_LEVEL="50"
        BATT_STATUS=$(cat /sys/class/power_supply/battery/status 2>/dev/null | tr -d '[:space:]')
        if [ "$BATT_STATUS" = "Charging" ] || [ "$BATT_STATUS" = "Full" ]; then
            BATT_PLUGGED="true"
        else
            BATT_PLUGGED="false"
        fi
    fi

    am broadcast -a com.android.systemui.demo \
        -e command battery \
        -e level "$BATT_LEVEL" \
        -e plugged "$BATT_PLUGGED"

    # 7. FIX ANDROID 13: Ocultar WiFi ANTES del comando de red
    # En Android 13 el parámetro "-e wifi hide" dentro del comando network no funciona bien
    if [ "$SDK" -le 33 ]; then
        am broadcast -a com.android.systemui.demo -e command wifi -e wifi hide
    fi

    # 8. LIMPIEZA DE SLOTS EXTRA (slots 2 y 3 siempre vacíos)
    am broadcast -a com.android.systemui.demo -e command network -e slot 2 -e nosim true
    am broadcast -a com.android.systemui.demo -e command network -e slot 3 -e nosim true

    # 9. LANZAMIENTO DE ICONOS (slots según versión de Android)
    # Leer type2 y level2 si existen, si no siguen al slot 0
    L2=$(cat $ST_DIR/level2 2>/dev/null | tr -d '[:space:]')
    [ -z "$L2" ] && L2="$L1"

    T2=$(cat $ST_DIR/type2 2>/dev/null | tr -d '[:space:]')
    [ -z "$T2" ] && T2="$T1"

    # Calcular DTYPE para slot 1 (igual que slot 0 pero con T2)
    if [ "$T2" = "sw" ] || [ "$T2" = "starlink" ]; then
        DTYPE2="$T2"
    elif [ "$T2" = "e+" ]; then
        DTYPE2="e"
    elif [ "$T2" = "gprs+" ]; then
        DTYPE2="g"
    elif [ "$T2" = "hspa++" ]; then
        DTYPE2="h+"
    else
        DTYPE2="$T2"
    fi

    for SLOT in $SLOTS; do
        if [ "$SLOT" = "1" ]; then
            SLOT_LEVEL="$L2"
            SLOT_DTYPE="$DTYPE2"
        else
            SLOT_LEVEL="$L1"
            SLOT_DTYPE="$DTYPE"
        fi
        am broadcast -a com.android.systemui.demo \
            -e command network \
            -e wifi hide \
            -e mobile show \
            -e slot $SLOT \
            -e level "$SLOT_LEVEL" \
            -e datatype "$SLOT_DTYPE" \
            -e carrier "$C1" \
            -e roaming "$R1" \
            -e activity "$ACTIVITY" \
            -e nosim false \
            -e fully true
    done

    sleep 2
done
