#!/system/bin/sh

# Esperar a que el sistema arranque completamente
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 5
done

# Esperar un poco más para asegurar que SystemUI esté listo
sleep 10

# Habilitar permisos globales para el modo demo
settings put global sysui_demo_allowed 1

# Entrar en demo mode y limpiar la barra
am broadcast -a com.android.systemui.demo -e command enter

# Bucle infinito para la señal dinámica
LAST_LEVEL=4

while true; do
  # 1. Generar nivel aleatorio entre 0 y 4
  LEVEL=$((RANDOM % 5))

  # Evitar saltos bruscos de señal
  DIFF=$((LEVEL - LAST_LEVEL))
  if [ ${DIFF#-} -gt 2 ]; then
      LEVEL=$LAST_LEVEL
  fi

  # 2. Lógica de tecnología de red (Datatype)
  case $LEVEL in
    0)
      # Con 0 barras, alta probabilidad de Edge (E)
      PROB=$((RANDOM % 10))
      [ $PROB -le 7 ] && TYPE="e" || TYPE="h+"
      ;;
    1)
      # Con 1 barra, oscila entre H+ y LTE
      PROB=$((RANDOM % 2))
      [ $PROB -eq 0 ] && TYPE="h+" || TYPE="lte"
      ;;
    2|3|4)
      # Con buena señal, casi siempre es LTE
      TYPE="lte"
      ;;
  esac

  # 3. Simular movimiento de datos (flechitas activity)
  # Elige al azar entre: in (bajada), out (subida), inout (ambas) o nada
  ACT_LIST="in out inout none"
  ACTIVITY=$(echo $ACT_LIST | tr ' ' '\n' | shuf -n 1)
  [ "$ACTIVITY" = "none" ] && ACTIVITY=""

  # 4. ENVIAR COMANDO FINAL
  am broadcast -a com.android.systemui.demo \
    -e command network \
    -e mobile show \
    -e fully true \
    -e level $LEVEL \
    -e datatype $TYPE \
    -e activity "$ACTIVITY"

  LAST_LEVEL=$LEVEL

  # Esperar 30 segundos antes del siguiente cambio
  sleep 30
done