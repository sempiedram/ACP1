%include  "io.mac"

.DATA
	linea	db	" | ",0
	lineas	db	"------",0
	espacios	db	"   ",0
	espacios2	db	"    ",0
	
.UDATA
	numeroBin	resb	2048
	
	;numero	9870
	
	
.CODE
	.STARTUP
	mov ECX,1
	mov EBP, 0x268E		;Coopia del numero original
	mov EDX,0
	mov EAX,0x268E		;Aui va el numero (int) para ser convertido a binario
	mov	EBX,2
	
	div EBX
	PutLInt	EBP
	PutStr	linea
	PutLInt	EBX
	nwln

organizar:
	PutStr	espacios
	PutLInt	EDX
	PutStr	linea
	PutStr	lineas
	nwln
	PutStr	espacios2
	PutStr	linea
	PutLInt	EAX
	PutStr	linea
	PutLInt	EBX
	nwln
	

division:
	cmp EAX,0
	je	done
	mov EDX,0
	div EBX
	inc	ECX
	jmp	organizar
	
	
	
done:
	.EXIT
