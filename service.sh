#!/system/bin/sh
# service.sh - Versión Minerva M+ (Estabilizada para Android 16)
ST_DIR="/data/local/tmp/minenet"

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

# Tu función maestra intacta
sync_network_speed() {
    TYPE="$1"
    iptables -F INPUT 2>/dev/null
    iptables -F OUTPUT 2>/dev/null

    case $TYPE in
        "g")
            iptables -A INPUT -m limit --limit 5/s --limit-burst 10 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 5/s --limit-burst 10 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "s")
            iptables -A INPUT -m limit --limit 3/s --limit-burst 6 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 3/s --limit-burst 6 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "1x")
            iptables -A INPUT -m limit --limit 13/s --limit-burst 18 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 13/s --limit-burst 18 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "e")
            iptables -A INPUT -m limit --limit 15/s --limit-burst 20 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 15/s --limit-burst 20 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "3g")
            iptables -A INPUT -m limit --limit 150/s --limit-burst 200 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 150/s --limit-burst 200 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "h")
            iptables -A INPUT -m limit --limit 400/s --limit-burst 500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 400/s --limit-burst 500 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "h+")
            iptables -A INPUT -m limit --limit 800/s --limit-burst 1000 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 800/s --limit-burst 1000 -j ACCEPT
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
            iptables -A INPUT -m limit --limit 7000/s --limit-burst 7000 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 7000/s --limit-burst 7000 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        *)
            iptables -F INPUT 2>/dev/null
            iptables -F OUTPUT 2>/dev/null
            ;;
    esac
}

# --- INICIO DEL MODO DEMO Y ARRANQUE SEGURO ---
settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

# Preparamos el terreno con el modo Satélite (el más estable para Android 16)
mkdir -p "$ST_DIR"
echo "5g" > "$ST_DIR/type"
echo "4" > "$ST_DIR/level"

# Aplicamos configuración inicial manualmente para evitar el crash
sync_network_speed "s"
am broadcast -a com.android.systemui.demo \
    -e command network -e wifi hide -e slot 0 -e mobile show \
    -e level 0 -e datatype s -e nosim false -e fully true -e activity none

# Pausa de estabilización
sleep 5

# Inicializamos rastreadores
PREV_RX=0
PREV_TX=0
LAST_TYPE="5g"
LAST_LEVEL="4"
LAST_ACT="none"

while true; do
    # Leemos configuración
    T1=$(cat $ST_DIR/type 2>/dev/null | tr -d '[:space:]' || echo "lte")
    L1=$(cat $ST_DIR/level 2>/dev/null | tr -d '[:space:]' || echo "4")
    
    # SOLO aplicamos iptables si el tipo cambió
    if [ "$T1" != "$LAST_TYPE" ]; then
        sync_network_speed "$T1"
        LAST_TYPE="$T1"
    fi

    # DETECCIÓN DE TRÁFICO
    LINE=$(cat /proc/net/dev | grep "wlan0")
    CURR_RX=$(echo $LINE | awk '{print $2}')
    CURR_TX=$(echo $LINE | awk '{print $10}')
    
    if [ "$CURR_RX" -gt "$PREV_RX" ]; then DOWN=true; else DOWN=false; fi
    if [ "$CURR_TX" -gt "$PREV_TX" ]; then UP=true; else UP=false; fi

    if $UP && $DOWN; then ACT="inout"; elif $UP; then ACT="out"; elif $DOWN; then ACT="in"; else ACT="none"; fi

    PREV_RX=$CURR_RX
    PREV_TX=$CURR_TX

    # SOLO enviamos el broadcast si algo visual cambió
    if [ "$ACT" != "$LAST_ACT" ] || [ "$L1" != "$LAST_LEVEL" ] || [ "$T1" != "$LAST_TYPE_VISUAL" ]; then
        am broadcast -a com.android.systemui.demo \
            -e command network -e wifi hide -e slot 0 -e mobile show \
            -e level "$L1" -e datatype "$T1" -e nosim false -e fully true \
            -e activity "$ACT"
        
        LAST_ACT="$ACT"
        LAST_LEVEL="$L1"
        LAST_TYPE_VISUAL="$T1"
    fi

    sleep 2
done