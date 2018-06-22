# Versi贸n completa del tetris 
# Sincronizada con tetris.s:r2916
        
	.data	

signo_menos:
	.asciiz	"-"
puntos:
    .space 256

puntuacion:
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
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opci贸n:\n"
str001:
	.asciiz		"\n隆Adi贸s!\n"
str002:
	.asciiz		"\nOpci贸n incorrecta. Pulse cualquier tecla para seguir.\n"
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
	.asciiz     "+------+"
next1:
	.asciiz     "|      |"
next2:
	.asciiz     "|      |"
next3:
	.asciiz     "|      |"
next4:
	.asciiz     "|      |"
next5:
	.asciiz     "+------+"



	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = direcci贸n de la imagen 
					# $t1 鈫? ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 鈫? direcci贸n del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_set_pixel:	# ($a0, $a1, $a2, $a3) = (*img, x, y, color)
	#void imagen_set_pixel(Imagen *img, int x, int y, Pixel color) {
  	#Pixel *pixel = imagen_pixel_addr(*img, x, y);
  	#*pixel = color;
	#}
	addiu	$sp, $sp, -8
	sw 	$ra, 4($sp)
	sw	$s0, 0($sp)
	
	move 	$s0, $a3
	jal 	imagen_pixel_addr
	sb 	$s0, 0($v0)
	
	lw 	$s0, 0($sp)
	lw	$ra, 4($sp)
	addiu	$sp, $sp, 8
	jr 	$ra				
	
	
imagen_clean:		# ($a0, $a1) = (*img, fondo)
	# void imagen_clean(Imagen *img, Pixel fondo) {
 	#    for (int y = 0; y < img->alto; ++y) {
    	#       for (int x = 0; x < img->ancho; ++x) {
  	#           imagen_set_pixel(*img, x, y, fondo);
 	#       }
 	#    }
	# } 
	
	addiu	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s0, 20($sp)		
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	sw	$s4, 4($sp)
	sw	$s5, 0($sp)
	
	move	$s2, $a0
	move	$s3, $a1
	lw	$s4, 4($s2)
	lw	$s5, 0($s2)
	
	# for (int y = 0; y < img->alto; ++y) {
	li 	$s0, 0
ic_1:	bge  	$s0, $s4, ic_2
	
	# for (int x = 0; x < img->ancho; ++x)
	li	$s1, 0
ic_3:	bge	$s1, $s5, ic_4
	
	move	$a3, $a1
	move	$a1, $s1
	move	$a2, $s0
	jal 	imagen_set_pixel
	move 	$a0, $s2
	move	$a1, $s3
	
	addiu	$s1, $s1, 1
	j	ic_3
	
ic_4:	addiu	$s0, $s0, 1
	j	ic_1
	
ic_2:	lw	$s5, 0($sp)
	lw	$s4, 4($sp)
	lw	$s3, 8($sp)
	lw	$s2, 12($sp)
	lw 	$s1, 16($sp)
	lw	$s0, 20($sp)
	lw	$ra, 24($sp)
	addiu	$sp, $sp, 28	
     	jr $ra
     	
     	
game_over:	
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	la	$a0, pieza_actual
	li	$a1, 8
	li	$a2, 0				
	jal	probar_pieza
	bnez 	$v0, go_0
		
	la	$a0, pantalla
	la	$a1, end0	
	li	$a2, 0
	li	$a3, 7
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, end1	
	li	$a2, 0
	li	$a3, 8
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, end2	
	li	$a2, 0
	li	$a3, 9
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, end3	
	li	$a2, 0
	li	$a3, 10
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, end4	
	li	$a2, 0
	li	$a3, 11
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, end5	
	li	$a2, 0
	li	$a3, 12
	jal	imagen_dibuja_cadena
	
	jal 	clear_screen
	la	$a0, pantalla
	jal 	imagen_print
	jal 	read_character
	li 	$t0, 1
	sb 	$t0, acabar_partida
	
	
go_0:	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr $ra



comprobar_linea:  
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s0, 16($sp)		
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)
	sw	$s3, 4($sp)
	sw	$s4, 0($sp)

	la	$s0, campo
	lw	$s1, 0($s0)
	lw	$s2, 4($s0)
        
        li	$s3, 0
cl_1:   
	bge	$s3, $s2, cl_4
	
        li	$s4, 0
cl_2:   
	bge	$s4, $s1, cl_5
	move 	$a0, $s0
	move	$a1, $s4
	move	$a2, $s3
	jal	imagen_get_pixel
	beqz 	$v0, cl_3
	addi	$s4, $s4, 1
	j 	cl_2
	
cl_5:	
	lw	$t0, puntuacion
	addi	$t0, $t0, 10
	sw	$t0, puntuacion
	move	$a0, $s3
	jal eliminar_linea	
cl_3:
	addi	$s3, $s3, 1
	j	cl_1        
cl_4:	
	lw	$s4, 0($sp)
	lw	$s3, 4($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 12($sp)
	lw	$s0, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24	
     	jr 	$ra     
     	
     	
eliminar_linea:
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s0, 16($sp)		
	sw	$s1, 12($sp)	
	sw	$s2, 8($sp)	
	sw	$s3, 4($sp)	
	sw	$s4, 0($sp)
	
	
	move 	$s0, $a0
	la	$s4, campo
	lw	$s3, 0($s4)
	
el_5:	bltz 	$s0, el_fin
	subi	$s1, $s0, 1
	
	bgez	$s1, el_2
	     	
     	li 	$s2, 0

el_4:   bge 	$s2, $s3, el_3
     	move 	$a0, $s4
     	move	$a1, $s2
     	move	$a2, $s0
     	li	$a3, 0
     	jal 	imagen_set_pixel
     	addi	$s2, $s2, 1		 	
   	j	el_4
el_3:
	j	el_1
el_2:	
	li 	$s2, 0
el_6:  
	bge 	$s2, $s3, el_1	
     	move 	$a0, $s4
     	move	$a1, $s2
     	move	$a2, $s1
     	jal 	imagen_get_pixel
     	
   	move 	$a0, $s4
   	move	$a1, $s2
   	move	$a2, $s0
   	move 	$a3, $v0
   	jal 	imagen_set_pixel
   	addi	$s2, $s2, 1
   	j	el_6
el_1:  	
	subi	$s0, $s0, 1
	j	el_5
el_fin:
	lw	$s4, 0($sp)
	lw	$s3, 4($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 12($sp)
	lw	$s0, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24	
     	jr 	$ra
        
imagen_init:
	# void imagen_init(Imagen *img, int ancho, int alto, Pixel fondo) {
  	# 	img->ancho = ancho;
  	# 	img->alto = alto;
  	# 	imagen_clean(*img, fondo);
	# }
	
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	
	sw	$a1, 0($a0)
	sw	$a2, 4($a0)
	
	move 	$a1, $a3
	jal 	imagen_clean		
	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr $ra

imagen_copy:
	# void imagen_copy(Imagen *dst, Imagen *src) {
 	#   dst->ancho = src->ancho;
  	#   dst->alto = src->alto;
  	#   for (int y = 0; y < src->alto; ++y) {
    	#      for (int x = 0; x < src->ancho; ++x) {
      	#         Pixel p = imagen_get_pixel(src, x, y);
      	#         imagen_set_pixel(dst, x, y, p);
    	#      }
  	#   }
	# }

	addiu	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s0, 20($sp)		
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	sw	$s4, 4($sp)
	sw	$s5, 0($sp)

	move	$s4, $a0
	move	$s5, $a1
	
	lw	$s0, 0($s5)
	sw	$s0, 0($s4)
	
	lw	$s1, 4($s5)
	sw 	$s1, 4($s4)

	# for (int y = 0; y < src->alto; ++y) {
	li 	$s2, 0
ico_1:	
	bge	$s2, $s1, ico_2
	# for (int x = 0; x < src->ancho; ++x) {
	li	$s3, 0
ico_3:
	bge	$s3, $s0, ico_4
	move 	$a0, $s5
	move	$a1, $s3
	move	$a2, $s2
	jal 	imagen_get_pixel
	move	$a3, $v0
	move	$a0, $s4
	move	$a1, $s3
	move	$a2, $s2
	jal imagen_set_pixel
	
	addiu	$s3, $s3, 1
	j	ico_3
ico_4:	
	addiu	$s2, $s2, 1
	j	ico_1	
ico_2:	
	lw	$s5, 0($sp)
	lw	$s4, 4($sp)
	lw	$s3, 8($sp)
	lw	$s2, 12($sp)
	lw 	$s1, 16($sp)
	lw	$s0, 20($sp)
	lw	$ra, 24($sp)
	addiu	$sp, $sp, 28	
     	jr $ra	



imagen_print:				# $a0 = img
	# void imagen_print(Imagen *img) {
	#   for (int y = 0; y < img->alto; ++y) {
	#     for (int x = 0; x < img->ancho; ++x) {
	#       Pixel p = imagen_get_pixel(img, x, y);
	#       print_character(p);
	#     }
	#     print_character('\n');
	#   }
	# }
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a0
	lw	$s3, 4($s0)
	lw	$s4, 0($s0)
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0
B6_2:	
	bgeu	$s1, $s3, B6_5
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0
B6_3:
	bgeu	$s2, $s4, B6_4
	move	$a0, $s0
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0
	jal	print_character
	addiu	$s2, $s2, 1
	j	B6_3
B6_4:
	li	$a0, 10
	jal	print_character
	addiu	$s1, $s1, 1
	j	B6_2
B6_5:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra

imagen_dibuja_imagen:
	# void imagen_dibuja_imagen(Imagen *dst, Imagen *src, int dst_x, int dst_y) {
  	#    for (int y = 0; y < src->alto; ++y) {
    	#       for (int x = 0; x < src->ancho; ++x) {
      	#          Pixel p = imagen_get_pixel(src, x, y);
      	#          if (p != PIXEL_VACIO) {
        #             imagen_set_pixel(dst, dst_x + x, dst_y + y, p);
      	#          }
    	#       }
  	#    }
	# }

	addiu	$sp, $sp, -36
	sw	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	move	$s0, $a0
	move	$s1, $a1
	move 	$s2, $a2
	move 	$s3, $a3
	lw	$s4, 4($s1)
	lw	$s5, 0($s1)
	
	# for (int y = 0; y < src->alto; ++y) {
	li 	$s6, 0
idi_1:	bge	$s6, $s4, idi_2
	# for (int x = 0; x < src->ancho; ++x) {
	li	$s7, 0

idi_3:	bge	$s7, $s5, idi_4

	move 	$a0, $s1
	move	$a1, $s7
	move	$a2, $s6
	jal 	imagen_get_pixel

	beqz   	$v0, idi_31

	move 	$a0, $s0
	add	$a1, $s2, $s7
	add	$a2, $s3, $s6
	move	$a3, $v0
	jal 	imagen_set_pixel

idi_31:
	addiu	$s7, $s7, 1
	j	idi_3
	
idi_4:
	addiu	$s6, $s6, 1
	j	idi_1

idi_2:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	lw	$ra, 32($sp)
	addiu	$sp, $sp, 36
	jr	$ra

imagen_dibuja_imagen_rotada:
	
	# void imagen_dibuja_imagen_rotada(Imagen *dst, Imagen *src, int dst_x, int dst_y) {
  	#    for (int y = 0; y < src->alto; ++y) {
    	#       for (int x = 0; x < src->ancho; ++x) {
      	#          Pixel p = imagen_get_pixel(src, x, y);
      	#          if (p != PIXEL_VACIO) {
        #             imagen_set_pixel(dst, dst_x + src->alto - 1 - y, dst_y + x, p);
      	#          }
      	#       }
      	#    }
      	# }

	addiu	$sp, $sp, -36
	sw	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	move	$s0, $a0
	move	$s1, $a1
	move 	$s2, $a2
	move 	$s3, $a3
	lw	$s4, 4($s1)
	lw	$s5, 0($s1)
	
	# for (int y = 0; y < src->alto; ++y)
	li 	$s6, 0
idir_1:	
	bge	$s6, $s4, idir_2
	# for (int x = 0; x < src->ancho; ++x) {
	li	$s7, 0

idir_3:	bge	$s7, $s5, idir_4

	move 	$a0, $s1
	move	$a1, $s7
	move	$a2, $s6
	jal 	imagen_get_pixel
	
	beqz   	$v0, idir_31
	
	move 	$a0, $s0
	add	$a1, $s2, $s4
	subi 	$a1, $a1, 1
	sub 	$a1, $a1, $s6
	add	$a2, $s3, $s7
	move	$a3, $v0
	jal imagen_set_pixel	
idir_31:
	addiu	$s7, $s7, 1
	j	idir_3	
idir_4:
	addiu	$s6, $s6, 1
	j	idir_1

idir_2:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	lw	$ra, 32($sp)
	addiu	$sp, $sp, 36
	jr	$ra	


pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 鈫? random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 鈫? piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

actualizar_pantalla:
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)
	la	$s2, campo
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0
ap_2:	lw	$t1, 4($s2)
	bge	$s1, $t1, ap_3
	la	$a0, pantalla
	li	$a1, 0
	addi	$a2, $s1, 2
	li	$a3, '|'
	jal	imagen_set_pixel
	la	$a0, pantalla
	lw	$t1, 0($s2)
	addiu	$a1, $t1, 1
	addiu	$a2, $s1, 2
	li	$a3, '|'
	jal	imagen_set_pixel
        addiu	$s1, $s1, 1
        j       ap_2
	# for (int x = 0; x < campo->ancho + 2; ++x)
ap_3:
	li	$s1, 0
ap_5:
	lw	$t1, 0($s2)
        addiu   $t1, $t1, 2
        bge	$s1, $t1, ap_6
	la	$a0, pantalla
	move	$a1, $s1
        lw	$t1, 4($s2)
	addiu	$a2, $t1, 2
	li	$a3, '-'
	jal	imagen_set_pixel
	addiu	$s1, $s1, 1
	j       ap_5
ap_6:
	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1
	li	$a3, 2
	jal	imagen_dibuja_imagen
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2
	jal	imagen_dibuja_imagen
	jal	clear_screen
	
	la	$a0, pantalla
	la	$a1, str003	
	li	$a2, 0
	li	$a3, 0
	jal	imagen_dibuja_cadena
	
	lw	$a0, puntuacion
	li	$a1, 10			
	la	$a2, puntos
	jal	integer_to_string_v4
	
	la	$a0, pantalla
	la	$a1, puntos
	li	$a2, 12
	li	$a3, 0
	jal 	imagen_dibuja_cadena
	
	jal 	game_over
	
	la	$a0, pantalla
	la	$a1, next0	
	li	$a2, 16
	li	$a3, 0
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, next1	
	li	$a2, 16
	li	$a3, 1
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, next2	
	li	$a2, 16
	li	$a3, 2
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, next3
	li	$a2, 16
	li	$a3, 3
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, next4
	li	$a2, 16
	li	$a3, 4
	jal	imagen_dibuja_cadena
	
	la	$a0, pantalla
	la	$a1, next5
	li	$a2, 16
	li	$a3, 5
	jal	imagen_dibuja_cadena	

	la	$a0, pantalla
	la	$a1, pieza_next
	li	$a2, 19
	li	$a3, 1
	jal	imagen_dibuja_imagen	
	
	la	$a0, pantalla
	jal	imagen_print
	
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

nueva_pieza_actual:
	# void nueva_pieza_actual(void) {
  	#    Imagen *elegida = pieza_aleatoria();
  	#    imagen_copy(pieza_actual, elegida);
  	#    pieza_actual_x = 8;
  	#    pieza_actual_y = 0;
	# }
	
	addiu	$sp, $sp, -4	
	sw	$ra, 0($sp)
	
	
	la	$a0, pieza_actual
	la	$a1, pieza_next
	jal	imagen_copy	
	
	jal	pieza_aleatoria
	la	$a0, pieza_next
	move	$a1, $v0
	jal	imagen_copy

	li	$t0, 8
	sw 	$t0, pieza_actual_x
	li	$t1, 0
	sw 	$t1, pieza_actual_y
	
	jal 	clear_screen
	la	$a0, pantalla
	jal 	imagen_print

	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra
	

probar_pieza:
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	move	$s0, $a2
	move	$s1, $a1
	move	$s2, $a0
	li	$v0, 0
	bltz	$s1, pp_13
	lw	$t1, 0($s2)
	addu	$t1, $s1, $t1
	la	$s4, campo
	lw	$v1, 0($s4)
	bltu	$v1, $t1, pp_13
	bltz	$s0, pp_13
	lw	$t1, 4($s2)
	addu	$t1, $s0, $t1
	lw	$v1, 4($s4)
	bltu	$v1, $t1, pp_13
	lw	$t1, 0($s2)
	beqz	$t1, pp_12
	li	$s3, 0
	lw	$s7, 4($s2)
pp_6:
	beqz	$s7, pp_11
	li	$s6, 0
pp_8:
	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel
	beqz	$v0, pp_10
	move	$a0, $s4
	addu	$a1, $s1, $s3
	addu	$a2, $s0, $s6
	jal	imagen_get_pixel
	move	$t1, $v0
	li	$v0, 0
	bnez	$t1, pp_13
pp_10:
	addiu	$s6, $s6, 1
	bltu	$s6, $s7, pp_8
pp_11:
	lw	$t1, 0($s2)
	addiu	$s3, $s3, 1
	bltu	$s3, $t1, pp_6
pp_12:
	li	$v0, 1
pp_13:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento:
	# bool intentar_movimiento(int x, int y) {
  	# if (probar_pieza(pieza_actual, x, y)) {
    	#    pieza_actual_x = x;
    	#    pieza_actual_y = y;
    	#    return true;
 	# }
  	# return false;
	# }
	
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1, 0($sp)
	
	move	$s0, $a0
	move	$s1, $a1
	
	la	$a0, pieza_actual
	move	$a1, $s0
	move	$a2, $s1
	jal 	probar_pieza
	
	# if (probar_pieza(pieza_actual, x, y))
	beqz 	$v0, im_1
	sw	$s0, pieza_actual_x
	sw	$s1, pieza_actual_y
	li	$v0, 1
	j 	im_2
im_1: 
 	li	$v0, 0
	
im_2:
	lw	$s1, 0($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

bajar_pieza_actual:
	# void bajar_pieza_actual(void) {
  	#    if (!intentar_movimiento(pieza_actual_x, pieza_actual_y + 1)) {
    	#       imagen_dibuja_imagen(campo, pieza_actual, pieza_actual_x, pieza_actual_y);
    	#       nueva_pieza_actual();
  	#    }
	# }
	
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)	
	
	lw	$a0, pieza_actual_x
	lw	$a1, pieza_actual_y
	addi 	$a1, $a1, 1
	
	jal intentar_movimiento
	# if (!intentar_movimiento(pieza_actual_x, pieza_actual_y + 1))
	bnez  	$v0, bpa_1
	
	la	$a0, campo
	la	$a1, pieza_actual
	lw	$a2, pieza_actual_x
	lw	$a3, pieza_actual_y
	jal 	imagen_dibuja_imagen
	
	jal	comprobar_linea
	
	jal	nueva_pieza_actual
	
	lw	$t9, puntuacion
	addi	$t9, $t9, 1
	sw	$t9, puntuacion
	
bpa_1:
	lw	$ra, 0($sp)
	addiu 	$sp, $sp, 4
	jr	$ra

intentar_rotar_pieza_actual:
	# void intentar_rotar_pieza_actual(void) {
  	#    Imagen *pieza_rotada = imagen_auxiliar;
  	#    imagen_init(pieza_rotada, pieza_actual->alto, pieza_actual->ancho, PIXEL_VACIO);
  	#    imagen_dibuja_imagen_rotada(pieza_rotada, pieza_actual, 0, 0);
  	#    if (probar_pieza(pieza_rotada, pieza_actual_x, pieza_actual_y)) {
   	#       imagen_copy(pieza_actual, pieza_rotada);
  	#    }
	# }

	addiu 	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$s0, 0($sp)


	la	$s0, imagen_auxiliar
	
	move	$a0, $s0
	la 	$t0, pieza_actual
	lw	$a1, 4($t0)		
	lw	$a2, 0($t0)
	move	$a3, $zero
	jal 	imagen_init
	
	move	$a0, $s0
	la	$a1, pieza_actual
	move	$a2, $zero
	move	$a3, $zero
	jal 	imagen_dibuja_imagen_rotada
	
	move	$a0, $s0
	lw	$a1, pieza_actual_x
	lw	$a2, pieza_actual_y
	jal	probar_pieza
	# if (probar_pieza(pieza_rotada, pieza_actual_x, pieza_actual_y)) {
	beqz	$v0, irpa_1
	
	la	$a0, pieza_actual
	move	$a1, $s0
	jal	imagen_copy
irpa_1:
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	addiu	$sp, $sp, 8
	jr	$ra

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 40			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B21_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B21_3		# if (opciones[i].tecla != c) siguiente iteraci贸n
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B21_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B21_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$a0, pantalla
	li	$a1, 28
	li	$a2, 22
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	li	$a1, 14
	li	$a2, 18
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	
	jal	pieza_aleatoria
	move	$s1, $v0
	la	$a0, pieza_next
	move	$a1, $s1
	jal	imagen_copy
	
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B22_2
        # while (!acabar_partida) { 
B22_2:	lbu	$t1, acabar_partida
	bnez	$t1, B22_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	ble	$t1, 1000, B22_2	# if (transcurrido < pausa) siguiente iteraci贸n
B22_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
        j	B22_2			# siguiente iteraci贸n
       	# } 
B22_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main
main:					# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
B23_2:	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opci贸n:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B23_1		# if (opc == '2') salir
	bne	$v0, '1', B23_5		# if (opc != '1') mostrar error
	lw	$t0, puntuacion
	li	$t0, 0
	sw	$t0, puntuacion
	jal	jugar_partida		# jugar_partida()
	j	B23_2
B23_1:	la	$a0, str001
	jal	print_string		# print_string("\n隆Adi贸s!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B23_2
B23_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpci贸n incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B23_2
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

#
# Funciones de la librer铆a del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra

integer_to_string_v4:			# ($a0, $a1, $a2) = (n, base, buf)
	
	
           	# ($a0, $a1, $a2) = (n, base, buf)
	move	$t5, $a0		# guardo el valor original de $a0
	move    $t0, $a2		# char *p = buff
if_01: 	bnez	$a0, else_01		#comprobamos que el n煤m introducido sea o no un 0
	addiu	$a0, $a0, '0'		# guardamos valor ascii del 0 en $a0
	sb	$a0,0($t0)		#lo guardamos en buffer
	addi	$t0,$t0,1
	sb	$zero, 0($t0)		# *p = '\0' , guarda el fin de cadena en el buffer
	
	jr	$ra
else_01:
 # for (int i = n; i > 0; i = i / base) {
        abs	$a0, $a0		#valor absoluto de n
        move	$t1, $a0		# int i = |n|

B4_3:   blez	$t1, B4_7		# si i <= 0 salta el bucle
	div	$t1, $a1		# i / base
	mflo	$t1			# i = i / base   
	mfhi	$t2			# d = i % base   /recupera el resto
if_base:
	li	$t7,10			
	bge	$t2,$t7,else_if_base	#comprobamos que el resto sea mayor o igual que 10, y en ese caso saltamos a la etiqueta else_if_base
	addiu	$t2, $t2, '0'		# d + '0' ; suma el c贸digo ASCII del 0, le est谩 sumando un caracter, convirtiendo $t2 en un caracter
fin_else_base:	
	sb	$t2, 0($t0)		# *p = $t2   guarda $t2 en la posicion 0 del buffer
	addiu	$t0, $t0, 1		# ++p    , avanza en la posici贸n del array
	j	B4_3			# sigue el bucle
        # }

else_if_base:
	sub	$t2,$t2,$t7			
	addiu	$t2,$t2,'A'  
	j	fin_else_base  
B4_7:	

if_4:	bgez	$t5,else_4	#comrpobamos que el valor introducido es mayor o igual que 0
		
	lb	$t3,signo_menos
	sb	$t3, 0($t0)	#cargamos en el buffer '-'
	addi	$t0, $t0, 1
	sb	$zero, 0($t0)	# *p = '\0' , guarda el fin de cadena
	addi 	$t0,$t0,-1
	j 	for4

else_4:
	sb	$zero, 0($t0)	# *p = '\0' , guarda el fin de cadena
	addi 	$t0,$t0,-1
	j	for4
for4:
	bge	$a2,$t0, fin_for4
	lb	$t3, 0($a2)
	lb	$t4, 0($t0)
	sb	$t4, 0($a2)
	sb	$t3, 0($t0)	
	#actualizamos $a2 y $t0
	addi	$a2,$a2,1
	addi	$t0,$t0,-1
	j for4
fin_for4:
	j B4_10
	
B4_10:	jr	$ra


imagen_dibuja_cadena:
	addiu	$sp, $sp, -24
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	sw	$s4, 4($sp)
	sw	$ra, 0($sp)
	
	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3
	
idc_1:
	lb	$s4, 0($s1)
	beqz	$s4, idc_2

	move	$a0, $s0	
	move 	$a1, $s2
	move	$a2, $s3
	move	$a3, $s4
	jal 	imagen_set_pixel

	addi 	$s1, $s1, 1
	addi 	$s2, $s2, 1
	j	idc_1
idc_2:
	lw	$s0, 20($sp) 
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	lw	$s4, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 24
	jr	$ra













