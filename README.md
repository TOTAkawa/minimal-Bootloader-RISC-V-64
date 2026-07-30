# RISC-V 64-bit Custom Bootloader

A modular, bare-metal 64-bit bootloader written from scratch in GNU Assembly (`custom RISC-V base`) for the QEMU `virt` machine. This project implements low-level hardware control without any underlying operating system or standard libraries.

## 🚀 Features
- **MMIO UART Driver**: Custom character-by-character input and output drivers mapped to memory address `0x10000000`.
- **Custom Interactive CLI**: Built-in shell that processes text buffers directly from the Stack.
- **Hardware Telemetry**: Reads internal CPU Control and Status Registers (CSR) such as `mhartid`.
- **Terminal Control**: Full implementation of backspace pointer deletion and ANSI escape codes for screen clearing.
- **Modular Assembly Structure**: Clean separation between hardware drivers (`uart.S`, `teclado.S`) and main execution logic (`main.S`).

## 🛠️ Prerequisites & Environment
Tested on **Arch Linux** using:
- `riscv64-elf-gcc` & `riscv64-elf-ld` (Cross-compiler toolchain)
- `qemu-system-riscv64` (Hardware Emulator)

## 💻 How to Run
To compile and spin up the emulator, simply run:
```bash
make run
```
*To exit QEMU, press `Ctrl + A` then `X`.*

