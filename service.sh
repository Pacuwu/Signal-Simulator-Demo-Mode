#!/system/bin/sh

# Esperar a que el sistema arranque
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 5
done

# En AOSP 10 segundos suelen bastar
sleep 10

# Habilitar permisos
settings put global sysui_demo_allowed 1

# Entrar en modo demo
am broadcast -a com.android.systemui.demo -e command enter

# Estado inicial
CURRENT_LEVEL=4

while true; do
  # --- LÓGICA HUMANA ---
  CHANCE=$(( (RANDOM % 100) + 1 ))

  if [ $CHANCE -le 70 ]; then
    NEW_LEVEL=$CURRENT_LEVEL
  elif [ $CHANCE -le 85 ]; then
    NEW_LEVEL=$((CURRENT_LEVEL + 1))
  else
    NEW_LEVEL=$((CURRENT_LEVEL - 1))
  fi

  # Ajustar límites
  [ $NEW_LEVEL -gt 4 ] && NEW_LEVEL=4
  [ $NEW_LEVEL -lt 0 ] && NEW_LEVEL=0
  CURRENT_LEVEL=$NEW_LEVEL


  # --- ACTIVIDAD DE DATOS REALISTA ---
  ACT_RAND=$((RANDOM % 10))
  if [ $ACT_RAND -gt 7 ]; then
     ACTIVITY="inout"
  elif [ $ACT_RAND -gt 4 ]; then
     ACTIVITY="in"
  else
     ACTIVITY="" # Reposo
  fi

  # --- COMANDO AOSP ---
  # En AOSP, un solo comando suele bastar para todo
  am broadcast -a com.android.systemui.demo \
    -e command network \
    -e mobile show \
    -e fully true \
    -e level $CURRENT_LEVEL \
    -e datatype h \
    -e activity "$ACTIVITY" \
    -e roaming true

  # Tiempo de espera aleatorio (entre 15 y 120 segundos)
  SLEEP_TIME=$(( (RANDOM % 105) + 15 ))
  sleep $SLEEP_TIME
done
