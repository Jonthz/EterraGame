.data

# Declarar un buffer para almacenar la entrada del jugador
input_buffer: .space 4    # Reservar espacio para hasta 4 caracteres (suficiente para numeros de 1 a 4)

# Mensajes generales del juego
msg_titulo:           .asciiz "Juego de Estrategia por Turnos!\n"
msg_menu:             .asciiz "Selecciona una accion:\n1. Atacar  2. Construir  3. Pasar\n"
msg_invalido:         .asciiz "Opcion invalida. Intenta de nuevo.\n"
msg_estado:           .asciiz "Estado actual del jugador: HP = "
msg_construir_ok:     .asciiz "Has aumentado tu ataque!\n"
msg_atacar_ok:        .asciiz "Has atacado al enemigo!\n"
msg_pasar_ok:         .asciiz "Has pasado el turno y ganado 2 recursos.\n"
msg_newline: 	      .asciiz "\n"

# Mensajes de combate
msg_cpu_turno:        .asciiz "\n--- Turno de la CPU ---\n"
msg_cpu_construir:    .asciiz "La CPU ha aumentado su ataque.\n"
msg_cpu_atacar:       .asciiz "La CPU ha atacado al jugador.\n"
msg_cpu_pasar:        .asciiz "La CPU ha pasado su turno y ganado recursos.\n"
msg_estado_combate: .asciiz "=== ESTADO DEL COMBATE ===\n"
msg_hp_enemigo: .asciiz "HP Enemigo: "
msg_enemigo_aparece: .asciiz "Un enemigo salvaje aparece!\n"

# Mensajes para eventos del mapa
msg_recurso_obtenido: .asciiz "Has encontrado un recurso! Has ganado 3 recursos.\n"
msg_arma_obtenida:    .asciiz "Has obtenido un arma! Tu ataque ha aumentado.\n"
msg_jefe_turno:       .asciiz "\n--- El Jefe esta atacando ---\n"
msg_jefe_derrotado:    .asciiz "\nHas derrotado al Jefe! Eterra esta salvado!\n"
msg_jefe_derrota:      .asciiz "\nEl Jefe te ha derrotado. El balance de Eterra se ha perdido!\n"

# Mensajes del jugador
msg_jugador_gana:     .asciiz "\nGanaste! Has derrotado a todos los enemigos.\n"
msg_cpu_gana:         .asciiz "\nPerdiste. La CPU te derroto.\n"
msg_exploracion:      .asciiz "\nContinuas explorando...\n"
intro_msg:            .asciiz "\nEn un mundo destruido por el abuso de los cristales del clima,\nKael, el ultimo guardian, se enfrenta a la corrupcion final.\nSu espiritu puro es su unica arma...\nProtege Eterra o cae con ella!\n"
msg_turno_jugador:    .asciiz "Es tu turno! Elige una accion.\n"

# Mensajes de exploracion y mapa
msg_mapa: .asciiz "Mapa del juego: \n[Jugador en Fila: 0, Columna: 0]\n"
msg_ingresa_direccion: .asciiz "Ingresa una direccion para moverte (1=arriba, 2=abajo, 3=izquierda, 4=derecha): \n"
msg_mapa_inicio: .asciiz "Iniciando mapa... \nExplora y encuentra los eventos."
msg_mapa_estado: .asciiz "Estado del mapa actualizado. Sigue explorando!"
msg_enemigo_encontrado: .asciiz "Enemigo encontrado! Preparate para luchar."
msg_casilla_explorada: .asciiz "Esta casilla ya fue explorada.\n"
msg_posicion_actual: .asciiz "Posicion actual:"
msg_coma: .asciiz ", "


# Mensajes para el estado del jugador
msg_estado_jugador: .asciiz "Estado actual del jugador:\n"
msg_hp_jugador: .asciiz "HP: "
msg_recursos_jugador: .asciiz "Recursos: "
msg_ataque_jugador: .asciiz "Ataque: "


#Lineas separadoras
separador_largo: .asciiz "\n========================\n"
separador_corto: .asciiz "\n---------------\n"

# Mapa de casillas exploradas (3x3 = 9 casillas)
# 0 = no explorada, 1 = explorada
mapa_explorado: .word 0, 0, 0, 0, 0, 0, 0, 0, 0

# Mapa de eventos (3x3 = 9 casillas)
# 0 = recurso, 1 = arma, 2 = enemigo, 3 = vacio
mapa_eventos: .word 3, 3, 3, 3, 3, 3, 3, 3, 3