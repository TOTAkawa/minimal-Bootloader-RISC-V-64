CC = riscv64-elf-gcc
LD = riscv64-elf-ld
QEMU = qemu-system-riscv64

# Garanta que a lista de objetos possui os novos nomes:
OBJETOS = main.o uart.o teclado.o

all: boot.elf

# O caractere inicial aqui DEVE ser um TAB físico:
%.o: %.S
	$(CC) -c $< -o $@

boot.elf: $(OBJETOS) linker.ld
	$(LD) -T linker.ld $(OBJETOS) -o boot.elf

run: boot.elf
	$(QEMU) -machine virt -bios none -kernel boot.elf -nographic

clean:
	rm -f *.o boot.elf

