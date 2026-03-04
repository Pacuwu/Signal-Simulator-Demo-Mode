#!/system/bin/sh

ST_DIR="/data/local/tmp/minenet"
mkdir -p $ST_DIR
chmod 777 $ST_DIR

# Valores por defecto
echo "4" > $ST_DIR/level
echo "5g" > $ST_DIR/type

# Esperar al sistema
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

# Activar modo demo
settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

# BUCLE INFINITO
while true; do
    LVL=$(cat $ST_DIR/level 2>/dev/null || echo "4")
    TYP=$(cat $ST_DIR/type 2>/dev/null || echo "5g")

    # SIM 1 (Slot 0)
    am broadcast -a com.android.systemui.demo \
        -e command network \
        -e slot 0 \
        -e mobile show \
        -e level $LVL \
        -e datatype $TYP \
        -e wifi hide

    # SIM 2 (Slot 1)
    am broadcast -a com.android.systemui.demo \
        -e command network \
        -e slot 1 \
        -e mobile show \
        -e level $LVL \
        -e datatype $TYP \
        -e wifi hide

    sleep 2
done
