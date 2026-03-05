#!/system/bin/sh

ST_DIR="/data/local/tmp/minenet"
mkdir -p $ST_DIR

# Esperar a que el sistema arranque del todo
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 5

while true; do
    # Asegurar que el modo demo esté activo
    settings put global sysui_demo_allowed 1
    am broadcast -a com.android.systemui.demo -e command enter

    # Leer los ajustes guardados o poner valores por defecto
    L=$(cat $ST_DIR/level 2>/dev/null || echo "4")
    T=$(cat $ST_DIR/type 2>/dev/null || echo "5g")
    N=$(cat $ST_DIR/name 2>/dev/null || echo "MineNet") # <--- Aquí lee tu nombre

    # Ocultar el WiFi para que no estorbe
    am broadcast -a com.android.systemui.demo -e command network -e wifi hide

    # SIM 1: Mostramos nivel, tipo y el NOMBRE de operadora
    am broadcast -a com.android.systemui.demo -e command network -e slot 0 -e mobile show -e level $L -e datatype $T -e operator "$N" -e nosim false
    
    # SIM 2: Lo mismo si está activa
    if [ -f "$ST_DIR/sim2_active" ]; then
        am broadcast -a com.android.systemui.demo -e command network -e slot 1 -e mobile show -e level $L -e datatype $T -e operator "$N" -e nosim false
    fi

    sleep 1
done
