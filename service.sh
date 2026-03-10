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
        "s")
            # SATÉLITE (SOS): ~12-24 Kbps (Rango real: 0.5 - 32 Kbps)
            # Solo 1 paquete por segundo para simular la angustia del espacio
            iptables -A INPUT -m limit --limit 2/s --limit-burst 4 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 2/s --limit-burst 4 -j ACCEPT
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
            # EDGE (E): Bajamos de 25 a 15 paquetes/s (~180 Kbps)
            # Para que se note más lento que el 3G pero mejor que el 1x
            iptables -A INPUT -m limit --limit 15/s --limit-burst 20 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 15/s --limit-burst 20 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "3g")
            # 3G Realista: ~2 Mbps (Para que no suba a 5.5 Mbps)
            iptables -A INPUT -m limit --limit 150/s --limit-burst 200 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 150/s --limit-burst 200 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "h")
            # HSDPA (H): Bajamos de 600 a 400 paquetes/s (~5 Mbps)
            # Para que se aleje de los 7-8 Mbps que te daba antes
            iptables -A INPUT -m limit --limit 400/s --limit-burst 500 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 400/s --limit-burst 500 -j ACCEPT
            iptables -A OUTPUT -j DROP
            ;;
        "h+")
            # HSPA+ (H+): Bajamos de 1500 a 800 paquetes/s (~10 Mbps)
            # Así evitas que sature el procesador y se note la mejora sobre el modo H
            iptables -A INPUT -m limit --limit 800/s --limit-burst 1000 -j ACCEPT
            iptables -A INPUT -j DROP
            iptables -A OUTPUT -m limit --limit 800/s --limit-burst 1000 -j ACCEPT
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