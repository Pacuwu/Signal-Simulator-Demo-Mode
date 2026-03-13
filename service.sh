#!/system/bin/sh
# service.sh - Versión Minerva M+ (Soporte para Carrier + Android 16)
ST_DIR="/data/local/tmp/minenet"

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

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
             # Límite de 2MB (aprox 2000kb/s)
            iptables -A INPUT -m limit --limit 200/s --limit-burst 50 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 200/s --limit-burst 50 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
         "starlink")
             # Simular red satelital starlink (aprox 2000kb/s)
            iptables -A INPUT -m limit --limit 2000/s --limit-burst 500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 2000/s --limit-burst 500 -j ACCEPT
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

# --- INICIO DEL MODO DEMO --- 
settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

# --- DETECCIÓN AUTOMÁTICA DE INICIO --- 
mkdir -p "$ST_DIR"
T1=$(cat $ST_DIR/type 2>/dev/null | tr -d '[:space:]' || echo "5g")
L1=$(cat $ST_DIR/level 2>/dev/null | tr -d '[:space:]' || echo "4")
C1=$(cat $ST_DIR/carrier 2>/dev/null || echo "")

# Inicializamos rastreadores con los valores actuales 
PREV_RX=0
PREV_TX=0
LAST_TYPE="$T1"
LAST_LEVEL="$L1"
LAST_CARRIER="$C1"
LAST_ACT="none"

while true; do
    # Leemos configuración actual 
    T1=$(cat $ST_DIR/type 2>/dev/null | tr -d '[:space:]' || echo "5g")
    L1=$(cat $ST_DIR/level 2>/dev/null | tr -d '[:space:]' || echo "4")
    C1=$(cat $ST_DIR/carrier 2>/dev/null || echo "")
    
    # SOLO aplicamos iptables si el tipo cambió 
    if [ "$T1" != "$LAST_TYPE" ]; then
        sync_network_speed "$T1"
        LAST_TYPE="$T1"
    fi

    # DETECCIÓN DE TRÁFICO INTELIGENTE 
    LINE=$(cat /proc/net/dev | grep "wlan0")
    CURR_RX=$(echo $LINE | awk '{print $2}')
    CURR_TX=$(echo $LINE | awk '{print $10}')
    
    if [ "$CURR_RX" -gt "$PREV_RX" ]; then DOWN=true; else DOWN=false; fi
    if [ "$CURR_TX" -gt "$PREV_TX" ]; then UP=true; else UP=false; fi

    if $UP && $DOWN; then ACT="inout"; elif $UP; then ACT="out"; elif $DOWN; then ACT="in"; else ACT="none"; fi

    PREV_RX=$CURR_RX
    PREV_TX=$CURR_TX

        # Lógica dinámica para mostrar/ocultar WiFi o Móvil
    if [ "$T1" = "sw" ]; then
        WIFI_CMD="-e wifi hide"
        MOBILE_CMD="-e mobile show"
    else
        WIFI_CMD="-e wifi hide"
        MOBILE_CMD="-e mobile show"
    fi

    # SOLO enviamos el broadcast si algo visual ha cambiado
    if [ "$ACT" != "$LAST_ACT" ] || [ "$L1" != "$LAST_LEVEL" ] || [ "$C1" != "$LAST_CARRIER" ] || [ "$T1" != "$LAST_TYPE_VISUAL" ]; then
        am broadcast -a com.android.systemui.demo \
            -e command network $WIFI_CMD $MOBILE_CMD -e slot 0 \
            -e level "$L1" -e datatype "$T1" -e carrier "$C1" \
            -e nosim false -e fully true -e activity "$ACT"
        
        LAST_ACT="$ACT"
        LAST_LEVEL="$L1"
        LAST_CARRIER="$C1"
        LAST_TYPE_VISUAL="$T1"
    fi

    sleep 2 
done