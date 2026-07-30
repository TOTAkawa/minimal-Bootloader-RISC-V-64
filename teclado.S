.global teclado_default

.section .text

teclado_default:
  li t0, 0x10000000
wait_t:
  lbu t1, 5(t0)
  andi t1, t1, 1
  beqz t1, wait_t
  lbu a0, 0(t0)
  ret
