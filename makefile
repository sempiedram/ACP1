
SOURCE_FILES = arithmetic.asm categories.asm commands.asm identation.asm source.asm strings.asm tokens.asm user_input.asm variables.asm

source: source.o io.o
	ld -m elf_i386 source.o io.o -o source

source.o: $(SOURCE_FILES) 
	nasm -f elf -F dwarf -g source.asm -o source.o

run: source
	./source

clean:
	rm -f source.o
	rm -f source


