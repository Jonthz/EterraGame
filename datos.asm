.data

# Declarar un buffer para almacenar la entrada del jugador
input_buffer: .space 4    # Reservar espacio para hasta 4 caracteres (suficiente para números de 1 a 4)

# Mensajes generales del juego
msg_titulo:           .asciiz "¡Juego de Estrategia por Turnos!\n"
msg_menu:             .asciiz "Selecciona una accion:\n1. Atacar  2. Construir  3. Pasar\n"
msg_invalido:         .asciiz "Opción invalida. Intenta de nuevo.\n"
msg_estado:           .asciiz "Estado actual del jugador: HP = "
msg_construir_ok:     .asciiz "¡Has aumentado tu ataque!\n"
msg_atacar_ok:        .asciiz "¡Has atacado al enemigo!\n"
msg_pasar_ok:         .asciiz "Has pasado el turno y ganado 2 recursos.\n"
msg_newline: 	      .asciiz "\n"

# Mensajes de combate
msg_cpu_turno:        .asciiz "\n--- Turno de la CPU ---\n"
msg_cpu_construir:    .asciiz "La CPU ha aumentado su ataque.\n"
msg_cpu_atacar:       .asciiz "La CPU ha atacado al jugador.\n"
msg_cpu_pasar:        .asciiz "La CPU ha pasado su turno y ganado recursos.\n"

# Mensajes para eventos del mapa
msg_recurso_obtenido: .asciiz "Â¡Has encontrado un recurso! Has ganado 3 recursos.\n"
msg_arma_obtenida:    .asciiz "Â¡Has obtenido un arma! Tu ataque ha aumentado.\n"
msg_jefe_turno:       .asciiz "\n--- El Jefe está atacando ---\n"
msg_jefe_derrotado:    .asciiz "\n¡Has derrotado al Jefe! Â¡Eterra estÃ¡ salvado!\n"
msg_jefe_derrota:      .asciiz "\nEl Jefe te ha derrotado. Â¡El balance de Eterra se ha perdido!\n"

# Mensajes del jugador
msg_jugador_gana:     .asciiz "\nÂ¡Ganaste! Has derrotado a todos los enemigos.\n"
msg_cpu_gana:         .asciiz "\nPerdiste. La CPU te derrotó³.\n"
msg_exploracion:      .asciiz "\nContinÃºas explorando...\n"
intro_msg:            .asciiz "\nEn un mundo destruido por el abuso de los cristales del clima,\nKael, el último guardian, se enfrenta a la corrupcion final.\nSu espiritu puro es su unica arma...\n¡Protege Eterra o cae con ella!\n"
msg_turno_jugador:    .asciiz "Â¡Es tu turno! Elige una acciÃ³n.\n"

# Mensajes de exploración y mapa
msg_mapa: .asciiz "Mapa del juego: \n[Jugador en Fila: 0, Columna: 0]\n"
msg_ingresa_direccion: .asciiz "Ingresa una dirección para moverte (1=arriba, 2=abajo, 3=izquierda, 4=derecha): \n"
msg_mapa_inicio: .asciiz "Iniciando mapa... \nExplora y encuentra los eventos."
msg_mapa_estado: .asciiz "Estado del mapa actualizado. ¡Sigue explorando!"
msg_enemigo_encontrado: .asciiz "¡Enemigo encontrado! Prepárate para luchar."


# Mensajes para el estado del jugador
msg_estado_jugador: .asciiz "Estado actual del jugador:\n"
msg_hp_jugador: .asciiz "HP: "
msg_recursos_jugador: .asciiz "Recursos: "
msg_ataque_jugador: .asciiz "Ataque: "