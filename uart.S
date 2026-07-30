.global print_string
.global uart_putc
.global uart_clear_screen

.section .text

# Envia um único caractere para a tela (a0 = caractere)
uart_putc:
    li t0, 0x10000000
    sb a0, 0(t0)
    ret

# Imprime uma string terminada em zero (a0 = endereço)
print_string:
    addi sp, sp, -16
    sd s0, 0(sp)
    sd s1, 8(sp)
    mv s0, a0
    li s1, 0x10000000
loop_p:
    lbu t0, 0(s0)
    beqz t0, fim_p
    sb t0, 0(s1)
    addi s0, s0, 1
    j loop_p
fim_p:
    ld s1, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 16
    ret

# Envia códigos ANSI para limpar a tela e resetar o cursor
uart_clear_screen:
    addi sp, sp, -8
    sd ra, 0(sp)

    # Código ESC (27)
    li a0, 27
    jal ra, uart_putc
    # Caractere '['
    li a0, 91
    jal ra, uart_putc
    # Caractere '2'
    li a0, 50
    jal ra, uart_putc
    # Caractere 'J' (Limpa tela)
    li a0, 74
    jal ra, uart_putc

    # Código ESC (27)
    li a0, 27
    jal ra, uart_putc
    # Caractere '['
    li a0, 91
    jal ra, uart_putc
    # Caractere 'H' (Move cursor para o topo esquerdo)
    li a0, 72
    jal ra, uart_putc

    ld ra, 0(sp)
    addi sp, sp, 8
    ret

