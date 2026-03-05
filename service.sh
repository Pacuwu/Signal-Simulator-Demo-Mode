#!/system/bin/sh

ST_DIR="/data/local/tmp/minenet"
mkdir -p $ST_DIR

# Valores iniciales si los archivos no existen
[ ! -f $ST_DIR/level ] && echo "4" > $ST_DIR/level
[ ! -f $ST_DIR/type1 ] && echo "5g" > $ST_DIR/type1
[ ! -f $ST_DIR/type2 ] && echo "5g" > $ST_DIR/type2

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

# Activar modo demo
settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

while true; do
    # LEER EL NIVEL SINCRONIZADO (El mismo que usa el binario)
    L=$(cat $ST_DIR/level 2>/dev/null || echo "4")
    T1=$(cat $ST_DIR/type1 2>/dev/null || echo "5g")
    T2=$(cat $ST_DIR/type2 2>/dev/null || echo "5g")

    # SIM 1
    am broadcast -a com.android.systemui.demo -e command network -e slot 0 -e mobile show -e level $L -e datatype $T1 -e volte show

    # SIM 2
    if [ -f "$ST_DIR/sim2_active" ]; then
        am broadcast -a com.android.systemui.demo -e command network -e slot 1 -e mobile show -e level $L -e datatype $T2 -e volte show
    else
        am broadcast -a com.android.systemui.demo -e command network -e slot 1 -e mobile hide
    fi

    sleep 3  # Un poco más de tiempo para no saturar
done