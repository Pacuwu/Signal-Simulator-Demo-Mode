#!/system/bin/sh
# service.sh - Versión Minerva M+ (Soporte Android 13 / 16)
ST_DIR="/data/local/tmp/minenet"

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

# Detectar versión de Android (SDK)
SDK=$(getprop ro.build.version.sdk)
# Android 13 = SDK 33 | Android 14 = SDK 34 | Android 15 = SDK 35 | Android 16 = SDK 36

# En Android 13, solo usar slot 0 para evitar bugs con slot 1
if [ "$SDK" -le 33 ]; then
    SLOTS="0"
else
    SLOTS="0 1"
fi

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

# --- INICIO DEL MODO DEMO ---
settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter
am broadcast -a com.android.systemui.demo -e command status -e tty show

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
    # 1. LECTURA DE DATOS
    T1=$(cat $ST_DIR/type 2>/dev/null | tr -d '[:space:]')
    [ -z "$T1" ] && T1="5g"

    L1=$(cat $ST_DIR/level 2>/dev/null | tr -d '[:space:]' || echo "4")
    C1=$(cat $ST_DIR/carrier 2>/dev/null || echo "")
    R1=$(cat $ST_DIR/roaming 2>/dev/null | tr -d '[:space:]' || echo "false")

    # 2. RADAR DE TRÁFICO DIRECCIONAL
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

    # 3. ACTIVADOR DE VELOCIDAD (solo si cambió el tipo)
    if [ "$T1" != "$LAST_TYPE" ]; then
        sync_network_speed "$T1"
        LAST_TYPE="$T1"
    fi

    # 4. Lógica de iconos
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

    # 5. FIX ANDROID 13: Ocultar WiFi ANTES de enviar el comando de red
    # En Android 13 el parámetro "-e wifi hide" dentro del comando network no funciona bien
    if [ "$SDK" -le 33 ]; then
        am broadcast -a com.android.systemui.demo -e command wifi -e wifi hide
    fi

    # 6. LIMPIEZA DE SLOTS EXTRA (Android 16+)
    if [ "$SDK" -gt 33 ]; then
        am broadcast -a com.android.systemui.demo -e command network -e slot 2 -e nosim true
        am broadcast -a com.android.systemui.demo -e command network -e slot 3 -e nosim true
    fi

    # 7. LANZAMIENTO DE ICONOS (slots según versión de Android)
    for SLOT in $SLOTS; do
        am broadcast -a com.android.systemui.demo \
            -e command network \
            -e wifi hide \
            $MOBILE_CMD \
            -e slot $SLOT \
            -e level "$L1" \
            -e datatype "$DTYPE" \
            -e carrier "$C1" \
            -e roaming "$R1" \
            -e activity "$ACTIVITY" \
            -e nosim false \
            -e fully true
    done

    sleep 2
done
