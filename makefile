
source: source.o io.o
	ld -m elf_i386 source.o io.o -o source

source.o: source.asm
	nasm -f elf source.asm -o source.o

run: source
	./source

clean:
	rm source.o
	rm source


