#!/system/bin/sh

# Carpeta de comunicación (persistente y accesible)
ST_DIR="/data/local/tmp/minenet"
mkdir -p $ST_DIR
chmod 777 $ST_DIR

# Valores iniciales
echo "4" > $ST_DIR/level
echo "5g" > $ST_DIR/type
echo "true" > $ST_DIR/roaming

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

while true; do
    # Leer valores actuales de los "archivos bandera"
    LVL=$(cat $ST_DIR/level)
    TYP=$(cat $ST_DIR/type)
    ROM=$(cat $ST_DIR/roaming)

    # Aplicar configuración
    am broadcast -a com.android.systemui.demo \
        -e command network \
        -e mobile show \
        -e fully true \
        -e level $LVL \
        -e datatype $TYP \
        -e roaming $ROM \
        -e wifi hide

    sleep 2
done
