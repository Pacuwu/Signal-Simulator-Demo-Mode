#!/system/bin/sh
# service.sh - Versión SIM Única: Iconos + Velocidad Real
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
            # GPRS (G): ~50 Kbps
            iptables -A INPUT -m limit --limit 5/s --limit-burst 10 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 5/s --limit-burst 10 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "1x")
            # 1xRTT (1X): ~100 Kbps
            iptables -A INPUT -m limit --limit 10/s --limit-burst 15 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 10/s --limit-burst 15 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "e")
            # EDGE (E): ~250 Kbps
            iptables -A INPUT -m limit --limit 25/s --limit-burst 30 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 25/s --limit-burst 30 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "3g")
            # 3G clásico: ~2 Mbps
            iptables -A INPUT -m limit --limit 150/s --limit-burst 200 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 150/s --limit-burst 200 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "h")
            # HSDPA (H): ~7 Mbps
            iptables -A INPUT -m limit --limit 600/s --limit-burst 800 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 600/s --limit-burst 800 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "h+")
            # HSPA+ (H+): ~21 Mbps
            iptables -A INPUT -m limit --limit 1500/s --limit-burst 2000 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 1500/s --limit-burst 2000 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "lte")
            # LTE (4G): ~30 Mbps
            iptables -A INPUT -m limit --limit 2500/s --limit-burst 3000 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 2500/s --limit-burst 3000 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "lte+")
            # LTE+ (4G+): ~100 Mbps
            iptables -A INPUT -m limit --limit 7000/s --limit-burst 7500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 7000/s --limit-burst 7500 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "5ge")
            # 5Ge (LTE Advanced): ~70 Mbps
            iptables -A INPUT -m limit --limit 5000/s --limit-burst 5500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 5000/s --limit-burst 5500 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        *)
            # MODO LIBRE: Sin límites
            iptables -F INPUT 2>/dev/null
            iptables -F OUTPUT 2>/dev/null
            ;;
    esac
}

settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

while true; do
    am broadcast -a com.android.systemui.demo -e command network -e wifi hide

    # Leemos y limpiamos datos de la única SIM
    T1=$(cat $ST_DIR/type 2>/dev/null | tr -d '[:space:]' || echo "5g")
    L1=$(cat $ST_DIR/level 2>/dev/null | tr -d '[:space:]' || echo "4")
    
    # Aplicamos velocidad
    sync_network_speed "$T1"

    # Actualizamos Visualmente
    am broadcast -a com.android.systemui.demo \
        -e command network -e slot 0 -e mobile show \
        -e level "$L1" -e datatype "$T1" -e nosim false -e fully true

    sleep 10
done