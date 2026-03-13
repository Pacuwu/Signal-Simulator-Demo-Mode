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
        "e+")
            # Evolved EDGE: Límite de 2.5 Mbps (250/s)
            iptables -A INPUT -m limit --limit 250/s --limit-burst 70 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 250/s --limit-burst 70 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "gprs+")
            # Evolved GPRS: Límite de 700 kbps (70/s)
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
            # Evolved HSPA+: Límite de 1000/s
            iptables -A INPUT -m limit --limit  1000/s --limit-burst 500 -j ACCEPT
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

# --- INICIO DEL MODO DEMO --- 
settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

# --- PREPARACIÓN DE BUCLE --- 
mkdir -p "$ST_DIR"
LAST_TYPE=""
LAST_ACT="none"

while true; do
    # Leemos configuración actual generada por minenet
    T1=$(cat $ST_DIR/type 2>/dev/null | tr -d '[:space:]' || echo "5g")
    L1=$(cat $ST_DIR/level 2>/dev/null | tr -d '[:space:]' || echo "4")
    C1=$(cat $ST_DIR/carrier 2>/dev/null || echo "")
    
    # 🔥 ACTIVADOR DE VELOCIDAD: Si cambias de red, aplicamos el nuevo límite
    if [ "$T1" != "$LAST_TYPE" ]; then
        sync_network_speed "$T1"
        LAST_TYPE="$T1"
    fi

    # Lógica dinámica visual para las redes "Evolved"
    if [ "$T1" = "sw" ]; then
        WIFI_CMD="-e wifi show"
        MOBILE_CMD="-e mobile hide"
        DTYPE="sw"
    elif [ "$T1" = "starlink" ]; then
        WIFI_CMD="-e wifi hide"
        MOBILE_CMD="-e mobile show"
        DTYPE="starlink"
    elif [ "$T1" = "e+" ]; then
        WIFI_CMD="-e wifi hide"
        MOBILE_CMD="-e mobile show"
        DTYPE="e" 
    elif [ "$T1" = "gprs+" ]; then
        WIFI_CMD="-e wifi hide"
        MOBILE_CMD="-e mobile show"
        DTYPE="g" 
    elif [ "$T1" = "hspa++" ]; then
        WIFI_CMD="-e wifi hide"
        MOBILE_CMD="-e mobile show"
        DTYPE="h+" 
    else
        # Esto es lo que debe ir en el else para todas las demás redes
        WIFI_CMD="-e wifi hide"
        MOBILE_CMD="-e mobile show"
        DTYPE="$T1"
    fi

    # Enviamos el broadcast solo si algo cambió
    am broadcast -a com.android.systemui.demo \
        -e command network $WIFI_CMD $MOBILE_CMD -e slot 0 \
        -e level "$L1" -e datatype "$DTYPE" -e carrier "$C1" \
        -e nosim false -e fully true -e activity "none"
    
    sleep 2 
done
