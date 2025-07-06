.include "datos.asm"  # Incluir los mensajes desde datos.asm

.text
.globl main

# Registros:
# $s0 = HP jugador
# $s1 = Recursos jugador
# $s2 = Ataque jugador
# $s3 = HP CPU (enemigo generico o jefe)
# $s4 = Recursos CPU
# $s5 = Ataque CPU
# $s6 = Fila (coordenada Y) del jugador
# $s7 = Columna (coordenada X) del jugador
# $t6 = Bandera para verificar si el jugador esta en la casilla del jefe
# $t7 = Tamano del mapa (3x3)

main:
    # Inicializacion
    li $s0, 15      # HP jugador (aumentado para balance)
    li $s1, 5       # Recursos jugador
    li $s2, 3       # Ataque jugador

    li $s3, 8       # HP CPU (enemigo generico)
    li $s4, 5       # Recursos CPU
    li $s5, 2       # Ataque CPU

    li $t6, 0       # Bandera para verificar si el jugador esta en la casilla del jefe
    li $t7, 3       # Tamano del mapa (3x3)

    li $s6, 0       # Fila inicial (Y) del jugador
    li $s7, 0       # Columna inicial (X) del jugador

    # Limpiar pantalla visualmente
    jal imprimir_separador
    
    # Mostrar titulo
    li $v0, 4
    la $a0, msg_titulo
    syscall
    
    jal imprimir_separador

    # Mostrar mensaje introductorio
    li $v0, 4
    la $a0, intro_msg
    syscall
    
    jal imprimir_separador
    
    #Inicializacion del mapa
    jal inicializar_mapa
    
    # Comienza la exploracion
    j bucle_principal

# Bucle principal del juego
bucle_principal:
    # Verificar si el jugador esta muerto
    blez $s0, fin_cpu_gana
    
    # Limpiar pantalla visualmente
    jal imprimir_separador
    
    # Mostrar estado del jugador
    jal mostrar_estado_jugador
    
    jal imprimir_linea_separadora
    
    # Mostrar mapa actual
    jal mostrar_mapa
    
    jal imprimir_linea_separadora
    
    # Verificar si llegamos al jefe (posicion 2,2)
    li $t0, 2
    beq $s6, $t0, verificar_jefe_y
    j continuar_exploracion

verificar_jefe_y:
    beq $s7, $t0, batalla_jefe
    j continuar_exploracion

continuar_exploracion:
    # Pedir direccion al jugador
    jal pedir_direccion
    
    # Mover al jugador
    jal mover_jugador
    
    # Explorar la nueva casilla
    jal explorar_casilla
    
    # Continuar el bucle
    j bucle_principal
 
# Función para inicializar el mapa con eventos aleatorios
inicializar_mapa:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Marcar la casilla inicial (0,0) como explorada
    li $t0, 0    # fila 0
    li $t1, 0    # columna 0
    jal marcar_casilla_explorada
    
    # La casilla inicial (0,0) no tiene evento
    li $t0, 0
    li $t1, 0
    li $t2, 3    # 3 = vacío
    jal establecer_evento_casilla
    
    # La casilla del jefe (2,2) no tiene evento aleatorio
    li $t0, 2
    li $t1, 2
    li $t2, 3    # 3 = vacío
    jal establecer_evento_casilla
    
    # Generar eventos aleatorios para todas las casillas disponibles
    # Array temporal para verificar que tenemos al menos uno de cada tipo
    # contadores: [recursos, armas, enemigos]
    li $t8, 0    # contador de recursos
    li $t9, 0    # contador de armas  
    li $s4, 0    # contador de enemigos (usando $s4 temporalmente)
    
generar_mapa_aleatorio:
    # Resetear contadores
    li $t8, 0
    li $t9, 0
    li $s4, 0
    
    # Generar eventos para las 7 casillas disponibles
    # Casillas: (0,1), (0,2), (1,0), (1,1), (1,2), (2,0), (2,1)
    
    # Casilla (0,1)
    li $v0, 42
    li $a1, 3
    syscall
    li $t0, 0
    li $t1, 1
    move $t2, $a0
    jal establecer_evento_casilla
    jal contar_tipo_evento
    
    # Casilla (0,2)
    li $v0, 42
    li $a1, 3
    syscall
    li $t0, 0
    li $t1, 2
    move $t2, $a0
    jal establecer_evento_casilla
    jal contar_tipo_evento
    
    # Casilla (1,0)
    li $v0, 42
    li $a1, 3
    syscall
    li $t0, 1
    li $t1, 0
    move $t2, $a0
    jal establecer_evento_casilla
    jal contar_tipo_evento
    
    # Casilla (1,1)
    li $v0, 42
    li $a1, 3
    syscall
    li $t0, 1
    li $t1, 1
    move $t2, $a0
    jal establecer_evento_casilla
    jal contar_tipo_evento
    
    # Casilla (1,2)
    li $v0, 42
    li $a1, 3
    syscall
    li $t0, 1
    li $t1, 2
    move $t2, $a0
    jal establecer_evento_casilla
    jal contar_tipo_evento
    
    # Casilla (2,0)
    li $v0, 42
    li $a1, 3
    syscall
    li $t0, 2
    li $t1, 0
    move $t2, $a0
    jal establecer_evento_casilla
    jal contar_tipo_evento
    
    # Casilla (2,1)
    li $v0, 42
    li $a1, 3
    syscall
    li $t0, 2
    li $t1, 1
    move $t2, $a0
    jal establecer_evento_casilla
    jal contar_tipo_evento
    
    # Verificar que tenemos al menos uno de cada tipo
    beqz $t8, generar_mapa_aleatorio  # Si no hay recursos, regenerar
    beqz $t9, generar_mapa_aleatorio  # Si no hay armas, regenerar
    beqz $s4, generar_mapa_aleatorio  # Si no hay enemigos, regenerar
    
    # Mapa válido generado
    j fin_generar_mapa

# Función auxiliar para contar tipos de evento
contar_tipo_evento:
    beqz $t2, incrementar_recursos
    li $t3, 1
    beq $t2, $t3, incrementar_armas
    li $t3, 2
    beq $t2, $t3, incrementar_enemigos
    jr $ra
    
incrementar_recursos:
    addi $t8, $t8, 1
    jr $ra
    
incrementar_armas:
    addi $t9, $t9, 1
    jr $ra
    
incrementar_enemigos:
    addi $s4, $s4, 1
    jr $ra

fin_generar_mapa:
    
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para verificar si una casilla ya fue explorada
# Entrada: $t0 = fila, $t1 = columna
# Salida: $v0 = 1 si explorada, 0 si no
verificar_casilla_explorada:
    # Calcular índice: fila * 3 + columna
    mul $t2, $t0, 3
    add $t2, $t2, $t1
    
    # Obtener valor del mapa
    la $t3, mapa_explorado
    sll $t2, $t2, 2    # multiplicar por 4 (tamaño de word)
    add $t3, $t3, $t2
    lw $v0, 0($t3)
    
    jr $ra

# Función para marcar una casilla como explorada
# Entrada: $t0 = fila, $t1 = columna
marcar_casilla_explorada:
    # Calcular índice: fila * 3 + columna
    mul $t2, $t0, 3
    add $t2, $t2, $t1
    
    # Marcar como explorada
    la $t3, mapa_explorado
    sll $t2, $t2, 2    # multiplicar por 4 (tamaño de word)
    add $t3, $t3, $t2
    li $t4, 1
    sw $t4, 0($t3)
    
    jr $ra

# Función para establecer evento en una casilla
# Entrada: $t0 = fila, $t1 = columna, $t2 = tipo evento
establecer_evento_casilla:
    # Calcular índice: fila * 3 + columna
    mul $t3, $t0, 3
    add $t3, $t3, $t1
    
    # Establecer evento
    la $t4, mapa_eventos
    sll $t3, $t3, 2    # multiplicar por 4 (tamaño de word)
    add $t4, $t4, $t3
    sw $t2, 0($t4)
    
    jr $ra

# Función para obtener evento de una casilla
# Entrada: $t0 = fila, $t1 = columna
# Salida: $v0 = tipo evento
obtener_evento_casilla:
    # Calcular índice: fila * 3 + columna
    mul $t2, $t0, 3
    add $t2, $t2, $t1
    
    # Obtener evento
    la $t3, mapa_eventos
    sll $t2, $t2, 2    # multiplicar por 4 (tamaño de word)
    add $t3, $t3, $t2
    lw $v0, 0($t3)
    
    jr $ra

# Mostrar el mapa actual
mostrar_mapa:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, msg_mapa
    syscall
    
    # Mostrar posición actual
    li $v0, 4
    la $a0, msg_posicion_actual
    syscall
    
    move $a0, $s6
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_coma
    syscall
    
    move $a0, $s7
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Mostrar mapa visual
    li $t0, 0  # fila actual
    
mostrar_fila:
    li $t1, 0  # columna actual
    
mostrar_columna:
    # Verificar si es la posición del jugador
    bne $t0, $s6, no_es_jugador
    bne $t1, $s7, no_es_jugador
    
    # Es la posición del jugador
    li $v0, 11
    li $a0, 80  # 'P' de Player
    syscall
    j siguiente_columna
    
no_es_jugador:
    # Verificar si es la posición del jefe (2,2)
    li $t2, 2
    bne $t0, $t2, no_es_jefe
    bne $t1, $t2, no_es_jefe
    
    # Es la posición del jefe
    li $v0, 11
    li $a0, 66  # 'B' de Boss
    syscall
    j siguiente_columna
    
no_es_jefe:
    # Verificar si fue explorada
    jal verificar_casilla_explorada
    beqz $v0, casilla_no_explorada_visual
    
    # Casilla explorada - mostrar tipo
    jal obtener_evento_casilla
    move $t3, $v0
    
    beqz $t3, mostrar_recurso_visual
    li $t4, 1
    beq $t3, $t4, mostrar_arma_visual
    li $t4, 2
    beq $t3, $t4, mostrar_enemigo_visual
    
    # Vacío
    li $v0, 11
    li $a0, 45  # '-' para vacío
    syscall
    j siguiente_columna
    
mostrar_recurso_visual:
    li $v0, 11
    li $a0, 82  # 'R' de Recurso
    syscall
    j siguiente_columna
    
mostrar_arma_visual:
    li $v0, 11
    li $a0, 65  # 'A' de Arma
    syscall
    j siguiente_columna
    
mostrar_enemigo_visual:
    li $v0, 11
    li $a0, 69  # 'E' de Enemigo
    syscall
    j siguiente_columna
    
casilla_no_explorada_visual:
    li $v0, 11
    li $a0, 63  # '?' para no explorada
    syscall
    
siguiente_columna:
    # Espacio entre columnas
    li $v0, 11
    li $a0, 32  # espacio
    syscall
    
    addi $t1, $t1, 1
    li $t2, 3
    blt $t1, $t2, mostrar_columna
    
    # Nueva línea al final de la fila
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    addi $t0, $t0, 1
    li $t2, 3
    blt $t0, $t2, mostrar_fila
    
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Pedir direccion al jugador
pedir_direccion:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, msg_ingresa_direccion
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Leer entrada del usuario
    li $v0, 5
    syscall
    move $t0, $v0  # Guardar la direccion en $t0
    
    # Validar entrada (1-4)
    li $t1, 1
    blt $t0, $t1, direccion_invalida
    li $t1, 4
    bgt $t0, $t1, direccion_invalida
    
    # Direccion valida, guardarla
    move $t9, $t0
    j fin_pedir_direccion
    
direccion_invalida:
    li $v0, 4
    la $a0, msg_invalido
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j pedir_direccion
    
fin_pedir_direccion:
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Mover al jugador segun la direccion
mover_jugador:
    # $t9 contiene la direccion (1=arriba, 2=abajo, 3=izquierda, 4=derecha)
    
    li $t0, 1
    beq $t9, $t0, mover_arriba
    
    li $t0, 2
    beq $t9, $t0, mover_abajo
    
    li $t0, 3
    beq $t9, $t0, mover_izquierda
    
    li $t0, 4
    beq $t9, $t0, mover_derecha
    
    jr $ra

mover_arriba:
    # Verificar limites (no menor que 0)
    blez $s6, limite_alcanzado
    addi $s6, $s6, -1
    jr $ra

mover_abajo:
    # Verificar limites (no mayor que 2)
    li $t0, 2
    bge $s6, $t0, limite_alcanzado
    addi $s6, $s6, 1
    jr $ra

mover_izquierda:
    # Verificar limites (no menor que 0)
    blez $s7, limite_alcanzado
    addi $s7, $s7, -1
    jr $ra

mover_derecha:
    # Verificar limites (no mayor que 2)
    li $t0, 2
    bge $s7, $t0, limite_alcanzado
    addi $s7, $s7, 1
    jr $ra

limite_alcanzado:
    li $v0, 4
    la $a0, msg_invalido
    syscall
    jr $ra

# Explorar la casilla actual
explorar_casilla:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar si la casilla ya fue explorada
    move $t0, $s6    # fila actual
    move $t1, $s7    # columna actual
    jal verificar_casilla_explorada
    
    # Si ya fue explorada, no hacer nada
    bnez $v0, casilla_ya_explorada
    
    # Marcar casilla como explorada
    move $t0, $s6
    move $t1, $s7
    jal marcar_casilla_explorada
    
    # Obtener evento de esta casilla
    move $t0, $s6
    move $t1, $s7
    jal obtener_evento_casilla
    move $t0, $v0    # guardar tipo de evento
    
    # Ejecutar evento según el tipo
    beqz $t0, evento_recurso
    li $t1, 1
    beq $t0, $t1, evento_arma
    li $t1, 2
    beq $t0, $t1, evento_enemigo
    
    # Evento vacío o inválido
    j fin_explorar_casilla

casilla_ya_explorada:
    li $v0, 4
    la $a0, msg_casilla_explorada
    syscall
    j fin_explorar_casilla

evento_recurso:
    jal imprimir_linea_separadora
    
    addi $s1, $s1, 3
    li $v0, 4
    la $a0, msg_recurso_obtenido
    syscall
    
    jal imprimir_linea_separadora
    j fin_explorar_casilla

evento_arma:
    jal imprimir_linea_separadora
    
    addi $s2, $s2, 2
    li $v0, 4
    la $a0, msg_arma_obtenida
    syscall
    
    jal imprimir_linea_separadora
    j fin_explorar_casilla

evento_enemigo:
    jal imprimir_linea_separadora
    
    li $v0, 4
    la $a0, msg_enemigo_encontrado
    syscall
    
    jal imprimir_linea_separadora
    
    # Inicializar enemigo
    li $s3, 8   # HP enemigo
    li $s5, 2   # Ataque enemigo
    
    # Comenzar combate
    jal combate_enemigo
    
    j fin_explorar_casilla

fin_explorar_casilla:
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Combate contra enemigo normal
combate_enemigo:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Mostrar estado inicial del enemigo
    jal mostrar_estado_enemigo
    
bucle_combate:
    # Verificar si el enemigo esta muerto
    blez $s3, fin_combate_jugador_gana
    
    # Verificar si el jugador esta muerto
    blez $s0, fin_combate_cpu_gana
    
    # Turno del jugador
    jal turno_jugador_combate
    
    # Verificar si el enemigo murio despues del ataque del jugador
    blez $s3, fin_combate_jugador_gana
    
    # Mostrar estado despues del turno del jugador
    jal mostrar_estado_combate
    
    # Turno del enemigo
    jal turno_cpu_combate
    
    # Mostrar estado despues del turno del enemigo
    jal mostrar_estado_combate
    
    j bucle_combate

fin_combate_jugador_gana:
    li $v0, 4
    la $a0, msg_atacar_ok
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
fin_combate_cpu_gana:
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j fin_cpu_gana

# Turno del jugador en combate
turno_jugador_combate:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal imprimir_separador
    
    li $v0, 4
    la $a0, msg_turno_jugador
    syscall
    
    jal mostrar_estado_jugador
    
    jal imprimir_linea_separadora
    
    li $v0, 4
    la $a0, msg_menu
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    li $v0, 5
    syscall
    move $t0, $v0
    
    li $t1, 1
    beq $t0, $t1, jugador_atacar
    
    li $t1, 2
    beq $t0, $t1, jugador_construir
    
    li $t1, 3
    beq $t0, $t1, jugador_pasar
    
    # Opcion invalida
    li $v0, 4
    la $a0, msg_invalido
    syscall
    j turno_jugador_combate

jugador_atacar:
    sub $s3, $s3, $s2
    li $v0, 4
    la $a0, msg_atacar_ok
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fin_turno_jugador

jugador_construir:
    # Verificar si tiene recursos suficientes
    li $t0, 2
    blt $s1, $t0, sin_recursos
    
    sub $s1, $s1, 2  # Cuesta 2 recursos
    addi $s2, $s2, 1
    li $v0, 4
    la $a0, msg_construir_ok
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fin_turno_jugador

sin_recursos:
    li $v0, 4
    la $a0, msg_invalido
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j turno_jugador_combate

jugador_pasar:
    addi $s1, $s1, 1
    li $v0, 4
    la $a0, msg_pasar_ok
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fin_turno_jugador

fin_turno_jugador:
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Turno de la CPU en combate
turno_cpu_combate:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal imprimir_linea_separadora
    
    li $v0, 4
    la $a0, msg_cpu_turno
    syscall
    
    # Accion aleatoria (1-3)
    li $v0, 42
    li $a1, 3
    syscall
    addi $t0, $a0, 1
    
    li $t1, 1
    beq $t0, $t1, cpu_atacar
    
    li $t1, 2
    beq $t0, $t1, cpu_construir
    
    li $t1, 3
    beq $t0, $t1, cpu_pasar
    
cpu_atacar:
    sub $s0, $s0, $s5
    li $v0, 4
    la $a0, msg_cpu_atacar
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fin_turno_cpu

cpu_construir:
    # Verificar si la CPU tiene recursos suficientes
    li $t0, 2
    blt $s4, $t0, cpu_sin_recursos
    
    sub $s4, $s4, 2  # Cuesta 2 recursos
    addi $s5, $s5, 1
    li $v0, 4
    la $a0, msg_cpu_construir
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fin_turno_cpu

cpu_sin_recursos:
    # Si no tiene recursos, pasar turno
    addi $s4, $s4, 1
    li $v0, 4
    la $a0, msg_cpu_pasar
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fin_turno_cpu

cpu_pasar:
    addi $s4, $s4, 1
    li $v0, 4
    la $a0, msg_cpu_pasar
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    j fin_turno_cpu

fin_turno_cpu:
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Batalla contra el jefe
batalla_jefe:
    jal imprimir_separador
    
    li $v0, 4
    la $a0, msg_jefe_turno
    syscall
    
    # Configurar estadisticas del jefe
    li $s3, 20  # HP del jefe
    li $s5, 4   # Ataque del jefe
    li $t6, 1   # Bandera de jefe activa
    
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
bucle_jefe:
    # Verificar si el jefe esta muerto
    blez $s3, fin_jefe_derrotado
    
    # Verificar si el jugador esta muerto
    blez $s0, fin_jefe_gana
    
    # Turno del jugador
    jal turno_jugador_combate
    
    # Verificar si el jefe murio
    blez $s3, fin_jefe_derrotado
    
    # Turno del jefe (mas agresivo)
    jal turno_jefe
    
    j bucle_jefe
    
fin_jefe_derrotado:
    jal imprimir_separador
    
    li $v0, 4
    la $a0, msg_jefe_derrotado
    syscall
    
    j salir
    
fin_jefe_gana:
    jal imprimir_separador
    
    li $v0, 4
    la $a0, msg_jefe_derrota
    syscall
    
    j salir

# Turno del jefe (mas agresivo)
turno_jefe:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal imprimir_linea_separadora
    
    li $v0, 4
    la $a0, msg_jefe_turno
    syscall
    
    # El jefe siempre ataca (mas agresivo)
    sub $s0, $s0, $s5
    li $v0, 4
    la $a0, msg_cpu_atacar
    syscall
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Subrutina para mostrar el estado del jugador
mostrar_estado_jugador:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, msg_estado_jugador
    syscall

    li $v0, 4
    la $a0, msg_hp_jugador
    syscall
    move $a0, $s0
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_newline
    syscall

    li $v0, 4
    la $a0, msg_recursos_jugador
    syscall
    move $a0, $s1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_newline
    syscall

    li $v0, 4
    la $a0, msg_ataque_jugador
    syscall
    move $a0, $s2
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
# Mostrar estado del combate
mostrar_estado_combate:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    li $v0, 4
    la $a0, msg_estado_combate
    syscall
    
    # Mostrar HP del jugador
    li $v0, 4
    la $a0, msg_hp_jugador
    syscall
    move $a0, $s0
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Mostrar HP del enemigo
    li $v0, 4
    la $a0, msg_hp_enemigo
    syscall
    move $a0, $s3
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Mostrar estado inicial del enemigo
mostrar_estado_enemigo:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, msg_enemigo_aparece
    syscall
    
    li $v0, 4
    la $a0, msg_hp_enemigo
    syscall
    move $a0, $s3
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Restaurar $ra
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Finales del juego
fin_jugador_gana:
    jal imprimir_separador
    
    li $v0, 4
    la $a0, msg_jugador_gana
    syscall
    
    j salir

fin_cpu_gana:
    jal imprimir_separador
    
    li $v0, 4
    la $a0, msg_cpu_gana
    syscall
    
    j salir

# Funciones utilitarias para mejorar la presentacion
imprimir_separador:
    # Imprimir linea de separacion larga
    li $v0, 4                    # syscall para imprimir string
    la $a0, separador_largo      # cargar direccion del separador largo
    syscall
    jr $ra

imprimir_linea_separadora:
    # Imprimir linea de separacion corta
    li $v0, 4                    # syscall para imprimir string
    la $a0, separador_corto      # cargar direccion del separador corto
    syscall
    jr $ra  

salir:
    li $v0, 10
    syscall
