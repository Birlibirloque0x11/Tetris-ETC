# Versión incompleta del tetris
# Sincronizada con tetris.s:r2916

	.data

cadena_puntos:
  .space 256

puntuacion_actual:
  .word 0

pantalla:
	.word	0
	.word	0
	.space	1024

campo:
	.word	0
	.word	0
	.space	1024

pieza_actual:
	.word	0
	.word	0
	.space	1024
pieza_next:
	.word   0
	.word   0
	.space  1024

pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii		"\0#\0###\0\0"

pieza_ele:
	.word	2
	.word	3
	.ascii		"#\0#\0##\0\0"

pieza_barra:
	.word	1
	.word	4
	.ascii		"####\0\0\0\0"

pieza_zeta:
	.word	3
	.word	2
	.ascii		"##\0\0##\0\0"

pieza_ese:
	.word	3
	.word	2
	.ascii		"\0####\0\0\0"

pieza_cuadro:
	.word	2
	.word	2
	.ascii		"####\0\0\0\0"

pieza_te:
	.word	3
	.word	2
	.ascii		"\0#\0###\0\0"

piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

acabar_partida:
	.byte	0

	.align	2
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'a'
	.space	3
	.word	tecla_izquierda
	.byte	'd'
	.space	3
	.word	tecla_derecha
	.byte	's'
	.space	3
	.word	tecla_abajo
	.byte	'w'
	.space	3
	.word	tecla_rotar

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n"
str001:
	.asciiz		"\n¡Adiós!\n"
str002:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"
str003:
    	.asciiz     "Puntuacion: \n"
end0:
    	.asciiz     "+--------------+"
end1:
    	.asciiz     "|  GAME  OVER  |"
end2:
    	.asciiz     "|              |"
end3:
    	.asciiz     "|    PRESS     |"
end4:
    	.asciiz     "|    BUTTON    |"
end5:
    	.asciiz     "+--------------+"
next0:
	.asciiz     "+--------+"
next1:
	.asciiz     "|        |"
next2:
	.asciiz     "|        |"
next3:
	.asciiz     "|        |"
next4:
	.asciiz     "|        |"
next5:
	.asciiz     "+--------+"



	.text

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen
					# $t1 