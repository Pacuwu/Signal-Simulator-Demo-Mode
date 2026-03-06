#!/system/bin/sh

ST_DIR="/data/local/tmp/minenet"
mkdir -p $ST_DIR

# Esperar el arranque
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 5

while true; do
    # Forzar modo demo en silencio
    settings put global sysui_demo_allowed 1 >/dev/null 2>&1
    am broadcast -a com.android.systemui.demo -e command enter >/dev/null 2>&1

    # Cargar ajustes SIM 1
    L=$(cat $ST_DIR/level 2>/dev/null || echo "4")
    T=$(cat $ST_DIR/type 2>/dev/null || echo "5g")
    N=$(cat $ST_DIR/name 2>/dev/null || echo "MineNet")

    # Cargar ajustes SIM 2 (NUEVO)
    L2=$(cat $ST_DIR/level2 2>/dev/null || echo "$L")
    T2=$(cat $ST_DIR/type2 2>/dev/null || echo "$T")
    N2=$(cat $ST_DIR/name2 2>/dev/null || echo "$N")

    # Ocultar WiFi
    am broadcast -a com.android.systemui.demo -e command network -e wifi hide >/dev/null 2>&1

    # SIM 1: Añadimos 'fully true'
    am broadcast -a com.android.systemui.demo -e command network -e slot 0 -e mobile show -e level $L -e datatype $T -e operator "$N" -e nosim false -e fully true >/dev/null 2>&1
    
    # SIM 2: Independiente con 'fully true'
    if [ -f "$ST_DIR/sim2_active" ]; then
        am broadcast -a com.android.systemui.demo -e command network -e slot 1 -e mobile show -e level $L2 -e datatype $T2 -e operator "$N2" -e nosim false -e fully true >/dev/null 2>&1
    fi

    sleep 1
done
