#!/system/bin/sh

ST_DIR="/data/local/tmp/minenet"
mkdir -p $ST_DIR
chmod 777 $ST_DIR

# Valores iniciales de seguridad
[ ! -f $ST_DIR/level1 ] && echo "4" > $ST_DIR/level1
[ ! -f $ST_DIR/level2 ] && echo "4" > $ST_DIR/level2
[ ! -f $ST_DIR/type1 ] && echo "5g" > $ST_DIR/type1
[ ! -f $ST_DIR/type2 ] && echo "5g" > $ST_DIR/type2

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

settings put global sysui_demo_allowed 1
am broadcast -a com.android.systemui.demo -e command enter

while true; do
    # Leer niveles
    L1=$(cat $ST_DIR/level1 2>/dev/null || echo "4")
    L2=$(cat $ST_DIR/level2 2>/dev/null || echo "4")
    
    # Leer redes
    T1=$(cat $ST_DIR/type1 2>/dev/null || echo "5g")
    T2=$(cat $ST_DIR/type2 2>/dev/null || echo "5g")

    # --- SIM 1 ---
    am broadcast -a com.android.systemui.demo \
        -e command network -e slot 0 -e mobile show \
        -e level $L1 -e datatype $T1 -e volte show -e roaming true

    # --- SIM 2 ---
    if [ -f "$ST_DIR/sim2_active" ]; then
        am broadcast -a com.android.systemui.demo \
            -e command network -e slot 1 -e mobile show \
            -e level $L2 -e datatype $T2 -e volte show -e roaming true
    else
        am broadcast -a com.android.systemui.demo \
            -e command network -e slot 1 -e mobile hide
    fi

    sleep 2
done