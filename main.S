.global _start

.section .text
_start:
    la sp, _stack_top       # Inicializa a pilha universal

    # Exibe a mensagem inicial de boas-vindas do sistema
    la a0, msg_boas_vindas
    jal ra, print_string

reseta_prompt:
    # Exibe o indicador "boot> " na tela
    la a0, msg_prompt
    jal ra, print_string
    la s0, buffer_comando   # s0 guarda o endereço onde salvaremos a próxima letra

loop_teclado:
    jal ra, teclado_default # Espera e lê uma tecla do hardware (retorna em a0)
    mv t0, a0               # Preserva o caractere original em t0

    # 1. Verifica se a tecla digitada foi Enter (ASCII 13)
    li t1, 13
    beq t0, t1, processa_linha

    # 2. Verifica se a tecla foi Backspace (ASCII 127 ou 8)
    li t1, 127
    beq t0, t1, trata_backspace
    li t1, 8
    beq t0, t1, trata_backspace

    # 3. Verifica se o buffer encheu para evitar estouro (limite de 15 bytes)
    la t2, buffer_comando
    addi t2, t2, 15
    bge s0, t2, loop_teclado # Se estourar o limite, ignora a tecla

    # 4. Salva o caractere na memória RAM (buffer) e avança o ponteiro s0
    sb t0, 0(s0)
    addi s0, s0, 1

    # 5. Ecoa o caractere normal na tela chamando o driver de saída
    mv a0, t0
    jal ra, uart_putc
    j loop_teclado

trata_backspace:
    # Se o buffer já estiver completamente vazio, ignora o Backspace
    la t1, buffer_comando
    beq s0, t1, loop_teclado
    
    # Recua o ponteiro do buffer na memória RAM em 1 byte
    addi s0, s0, -1

    # Atualiza a janela do terminal apagando a letra visualmente (\b \b)
    li a0, 8
    jal ra, uart_putc       # Recua o cursor
    li a0, 32
    jal ra, uart_putc       # Sobrescreve com espaço em branco
    li a0, 8
    jal ra, uart_putc       # Recua o cursor novamente
    j loop_teclado

processa_linha:
    # Finaliza a string gravando o byte 0 (Null-terminator) no fim do buffer
    sb x0, 0(s0)

    # Envia uma quebra de linha visual para o console
    li a0, 10
    jal ra, uart_putc
    li a0, 13
    jal ra, uart_putc

    # --- Comparação: Comando "help" ---
    la a0, buffer_comando
    la a1, cmd_help
    jal ra, strcmp
    beqz a0, executa_help

    # --- Comparação: Comando "cpu" ---
    la a0, buffer_comando
    la a1, cmd_cpu
    jal ra, strcmp
    beqz a0, executa_cpu

    # --- Comparação: Comando "clear" ---
    la a0, buffer_comando
    la a1, cmd_clear
    jal ra, strcmp
    beqz a0, executa_clear

    # Se não bater com nenhum comando cadastrado, exibe erro
    la a0, msg_erro
    jal ra, print_string
    j reseta_prompt

executa_help:
    la a0, msg_help_text
    jal ra, print_string
    j reseta_prompt

executa_cpu:
    la a0, msg_cpu_info
    jal ra, print_string

    # Instrução CSR especial para ler o ID do núcleo físico
    csrr t0, mhartid

    # Transforma o ID numérico bruto (ex: 0) no caractere ASCII correspondente ('0' = 48)
    addi a0, t0, 48
    jal ra, uart_putc

    # Quebra de linha final pós-dados
    li a0, 10
    jal ra, uart_putc
    li a0, 13
    jal ra, uart_putc
    j reseta_prompt

executa_clear:
    jal ra, uart_clear_screen   # Executa o driver de limpeza ANSI do uart.S
    j reseta_prompt

# =========================================================================
# FUNÇÃO LOGICA: strcmp (a0 = str1, a1 = str2) -> Retorna a0=0 se idênticas
# =========================================================================
strcmp:
loop_c:
    lbu t0, 0(a0)
    lbu t1, 0(a1)
    bne t0, t1, difs
    beqz t0, iguais         
    addi a0, a0, 1
    addi a1, a1, 1
    j loop_c
difs:
    li a0, 1
    ret
iguais:
    li a0, 0
    ret

# =========================================================================
# SEÇÃO DE MEMÓRIA DINÂMICA (RAM DE LEITURA E ESCRITA)
# =========================================================================
.section .data
.balign 8
buffer_comando: .zero 16    # Espaço reservado para receber os comandos digitados

# =========================================================================
# SEÇÃO DE CONSTANTES (MEMÓRIA SOMENTE DE LEITURA)
# =========================================================================
.section .rodata
msg_boas_vindas: .string "=== Bootloader Modular Inicializado ===\n"
msg_prompt:      .string "boot> "
cmd_help:        .string "help"
cmd_cpu:         .string "cpu"
cmd_clear:       .string "clear"
msg_erro:        .string "Comando invalido! Tente 'help'.\n"
msg_cpu_info:    .string "Rodando no Nucleo RISC-V ID: "
msg_help_text:   .string "Comandos do Bootloader:\n  help  - Mostra este menu\n  cpu   - Mostra info do processador\n  clear - Limpa a tela do console\n"

