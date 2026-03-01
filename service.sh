#!/system/bin/sh

# Carpeta de comunicación (persistente y accesible)
ST_DIR="/data/local/tmp/minenet"
mkdir -p $ST_DIR
chmod 777 $ST_DIR

# Valores iniciales
echo "4" > $ST_DIR/level
echo "5g" > $ST_DIR/type

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

# Leer valores guardados
    LVL=$(cat $ST_DIR/level 2>/dev/null || echo "4")
    TYP=$(cat $ST_DIR/type 2>/dev/null || echo "5g")

    # Aplicar al Modo Demo
    am broadcast -a com.android.systemui.demo \
        -e command network \
        -e mobile show \
        -e level $LVL \
        -e datatype $TYP \
        -e wifi hide

    sleep 2
done
