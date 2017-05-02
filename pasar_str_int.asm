; Primero pasar los numeros a binario
; Los numeros con un menos afuera convertirlos en negativo

%include  "io.mac"

.DATA
	exp_1	db	"X : 9870 + 87ABhex * ( 76oct - 9AChex )" , 0
	exp_2	db	"11010bin * 87634 + - 976oct / 77" , 0
	exp_3	db	"AB56hex + ( 897 - - 7623oct * 72 ) / 876 + EF879hex" , 0
	lala	db	"::> " , 0
	
	
.CODE
	.STARTUP
	sub	EAX,EAX
	sub EBX,EBX
	sub BX,BX
	mov ECX,4

inicio:
	mov	BL,[exp_1+ECX]
	inc ECX
	cmp BL, ' '
	je done
		
armar_num:
	cmp BL ,'0'
	jg may_0

may_0:
	cmp	BL,'9'
	jl numero
	
numero:
	mov	DX,10
	sub	BL,48
	mul DX
	add EAX,EBX
	jmp inicio
	
	
done:
	PutLInt	EAX
	nwln
	.EXIT
	
