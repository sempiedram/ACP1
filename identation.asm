

; This method prints identation. Prints IDENTATION_CHAR n times, where n is the value stored in the identation byte.
print_identation:
	push ECX
		; ECX = 0
		xor ECX, ECX
		
		; ECX = times to print IDENTATION_CHAR:
		mov CL, byte [identation]
		
		; Print nothing if identation is 0.
		cmp CL, 0
		je .end
		
		; Repeat n times PutCh IDENTATION_CHAR
		.cycle:
			PutCh IDENTATION_CHAR
			;loop .cycle
			dec ECX
			cmp ECX, 0
			jne .cycle
		.end:
	pop ECX
	ret


; Increases identation by 1.
increase_identation:
	; If identation == 255, don't increase it (255 is the limit).
	cmp byte [identation], 0xFF
	je .no_more
		inc byte [identation]
	.no_more:
	ret


; Decreases identation by 1.
decrease_identation:
	; If identation == 0, don't decrease it (0 is the limit).
	cmp byte [identation], 0
	je .no_less
		dec byte [identation]
	.no_less:
	ret


; Increases identation by n, where n is the value stored in the identation_size.
increase_identation_level:
	push ECX
		; ECX = 0
		xor ECX, ECX
		
		; ECX = n
		mov CL, byte [identation_size]
		
		; increase identation by n:
		.cycle:
			call increase_identation
			loop .cycle
	pop ECX
	ret


; Decreases identation by n, where n is the value stored in the identation_size.
decrease_identation_level:
	push ECX
		; ECX = 0
		xor ECX, ECX
		
		; ECX = n
		mov CL, byte [identation_size]
		
		; decrease identation by n:
		.cycle:
			call decrease_identation
			loop .cycle
	pop ECX
	ret

