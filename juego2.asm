.include "datos.asm"  # Incluir los mensajes desde datos.asm

.text
.globl main

# Registros:
# $s0 = HP jugador
# $s1 = Recursos jugador
# $s2 = Ataque jugador
# $s3 = HP CPU (enemigo genérico o jefe)
# $s4 = Recursos CPU
# $s5 = Ataque CPU
# $s6 = Fila (coordenada Y) del jugador
# $s7 = Columna (coordenada X) del jugador
# $t6 = Bandera para verificar si el jugador está en la casilla del jefe
# $t7 = Tamaño del mapa (3x3)

main:
    # Inicialización
    li $s0, 15      # HP jugador (aumentado para balance)
    li $s1, 5       # Recursos jugador
    li $s2, 3       # Ataque jugador

    li $s3, 8       # HP CPU (enemigo genérico)
    li $s4, 5       # Recursos CPU
    li $s5, 2       # Ataque CPU

    li $t6, 0       # Bandera para verificar si el jugador está en la casilla del jefe
    li $t7, 3       # Tamaño del mapa (3x3)

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

    # Comienza la exploración
    j bucle_principal

# Bucle principal del juego
bucle_principal:
    # Verificar si el jugador está muerto
    blez $s0, fin_cpu_gana
    
    # Limpiar pantalla visualmente
    jal imprimir_separador
    
    # Mostrar estado del jugador
    jal mostrar_estado_jugador
    
    jal imprimir_linea_separadora
    
    # Mostrar mapa actual
    jal mostrar_mapa
    
    jal imprimir_linea_separadora
    
    # Verificar si llegamos al jefe (posición 2,2)
    li $t0, 2
    beq $s6, $t0, verificar_jefe_y
    j continuar_exploracion

verificar_jefe_y:
    beq $s7, $t0, batalla_jefe
    j continuar_exploracion

continuar_exploracion:
    # Pedir dirección al jugador
    jal pedir_direccion
    
    # Mover al jugador
    jal mover_jugador
    
    # Explorar la nueva casilla
    jal explorar_casilla
    
    # Continuar el bucle
    j bucle_principal

# Mostrar el mapa actual
mostrar_mapa:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Mostrar encabezado del mapa
    li $v0, 4
    la $a0, msg_mapa
    syscall
    
    # Mostrar posición actual
    li $v0, 4
    la $a0, msg_hp_jugador  # Reutilizamos para mostrar "Fila: "
    syscall
    
    move $a0, $s6
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_recursos_jugador  # Reutilizamos para mostrar "Columna: "
    syscall
    
    move $a0, $s7
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    # Mostrar representación visual del mapa 3x3
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
    bne $t0, $t2, no_es_jefe_mapa
    bne $t1, $t2, no_es_jefe_mapa
    
    # Es la posición del jefe
    li $v0, 11
    li $a0, 66  # 'B' de Boss
    syscall
    j siguiente_columna
    
no_es_jefe_mapa:
    # Casilla normal
    li $v0, 11
    li $a0, 46  # '.' para casilla vacía
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

# Pedir dirección al jugador
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
    move $t0, $v0  # Guardar la dirección en $t0
    
    # Validar entrada (1-4)
    li $t1, 1
    blt $t0, $t1, direccion_invalida
    li $t1, 4
    bgt $t0, $t1, direccion_invalida
    
    # Dirección válida, guardarla
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

# Mover al jugador según la dirección
mover_jugador:
    # $t9 contiene la dirección (1=arriba, 2=abajo, 3=izquierda, 4=derecha)
    
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
    # Verificar límites (no menor que 0)
    blez $s6, limite_alcanzado
    addi $s6, $s6, -1
    jr $ra

mover_abajo:
    # Verificar límites (no mayor que 2)
    li $t0, 2
    bge $s6, $t0, limite_alcanzado
    addi $s6, $s6, 1
    jr $ra

mover_izquierda:
    # Verificar límites (no menor que 0)
    blez $s7, limite_alcanzado
    addi $s7, $s7, -1
    jr $ra

mover_derecha:
    # Verificar límites (no mayor que 2)
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
    
    # Generar evento aleatorio (0: recurso, 1: arma, 2: enemigo)
    li $v0, 42
    li $a1, 3
    syscall
    move $t0, $a0
    
    beqz $t0, evento_recurso
    li $t1, 1
    beq $t0, $t1, evento_arma
    li $t1, 2
    beq $t0, $t1, evento_enemigo
    
    # Si no se ejecuta ningún evento (no debería pasar)
    j fin_explorar_casilla

# Eventos del mapa
evento_recurso:
    jal imprimir_linea_separadora
    
    addi $s1, $s1, 3
    li $v0, 4
    la $a0, msg_recurso_obtenido
    syscall
    
    jal imprimir_linea_separadora
    
    # IMPORTANTE: Saltar al final para restaurar el stack
    j fin_explorar_casilla

evento_arma:
    jal imprimir_linea_separadora
    
    addi $s2, $s2, 2
    li $v0, 4
    la $a0, msg_arma_obtenida
    syscall
    
    jal imprimir_linea_separadora
    
    # IMPORTANTE: Saltar al final para restaurar el stack
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
    
    # IMPORTANTE: Saltar al final para restaurar el stack
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
    # Verificar si el enemigo está muerto
    blez $s3, fin_combate_jugador_gana
    
    # Verificar si el jugador está muerto
    blez $s0, fin_combate_cpu_gana
    
    # Turno del jugador
    jal turno_jugador_combate
    
    # Verificar si el enemigo murió después del ataque del jugador
    blez $s3, fin_combate_jugador_gana
    
    # Mostrar estado después del turno del jugador
    jal mostrar_estado_combate
    
    # Turno del enemigo
    jal turno_cpu_combate
    
    # Mostrar estado después del turno del enemigo
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
    
    # Opción inválida
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
    
    # Acción aleatoria (1-3)
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
    
    # Configurar estadísticas del jefe
    li $s3, 20  # HP del jefe
    li $s5, 4   # Ataque del jefe
    li $t6, 1   # Bandera de jefe activa
    
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
bucle_jefe:
    # Verificar si el jefe está muerto
    blez $s3, fin_jefe_derrotado
    
    # Verificar si el jugador está muerto
    blez $s0, fin_jefe_gana
    
    # Turno del jugador
    jal turno_jugador_combate
    
    # Verificar si el jefe murió
    blez $s3, fin_jefe_derrotado
    
    # Turno del jefe (más agresivo)
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

# Turno del jefe (más agresivo)
turno_jefe:
    # Guardar $ra
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal imprimir_linea_separadora
    
    li $v0, 4
    la $a0, msg_jefe_turno
    syscall
    
    # El jefe siempre ataca (más agresivo)
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

# Funciones utilitarias para mejorar la presentación
imprimir_separador:
    # Imprimir línea de separación larga
    li $v0, 4                    # syscall para imprimir string
    la $a0, separador_largo      # cargar dirección del separador largo
    syscall
    jr $ra

imprimir_linea_separadora:
    # Imprimir línea de separación corta
    li $v0, 4                    # syscall para imprimir string
    la $a0, separador_corto      # cargar dirección del separador corto
    syscall
    jr $ra  

salir:
    li $v0, 10
    syscall
