# Definir permisos para el binario de control
# set_perm <archivo> <dueño> <grupo> <permiso>
set_perm $MODPATH/system/bin/minenet 0 0 0755

# Mensaje estético durante la instalación
ui_print "- Configurando MineNet Control..."
ui_print "- Ahora podrás usar el comando 'minenet' en Termux."
ui_print "- esta version tendrá como red predeterminada el 5g, esto es para evitar el crash"
