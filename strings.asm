


; Check if the string at EDI is equal to the string at ESI. The main string is ESI.
compare_strings:
	push ESI
	push EDI
	push EAX
		; This is the byte comparison.
		.cycle:
			mov AL, byte [ESI]
			cmp AL, byte [EDI]
			jne .not_equal
				; Characters were equal:
				cmp AL, 0
				
				; If the bytes were 0, return true, else continue with the next cycle.
				jne .next_cycle
					; The end of the strings have been reached.
					; Return true:
					; Zero flag is already 1
					jmp .done
			.not_equal:
				; Return false:
				; Zero flag is already 0
				jmp .done
			
			.next_cycle:
				inc ESI
				inc EDI
				jmp .cycle
			; End of .cycle
		
		.done:
	pop EAX
	pop EDI
	pop ESI
	ret


; This method determines whether the character in BL is in the string at ECX.
; Affects: CF, 1 if it was, 0 if it wasn't
; Inputs: BL character to look for, ECX address of the string.
find_character:
	push ECX
		.cycle:
			cmp byte [ECX], BL
			je .found
			
			cmp byte [ECX], 0
			je .end_of_string
			
			inc ECX
			jmp .cycle
			
		.end_of_string:
			clc
			jmp .end
			
		.found:
			stc
			jmp .end
		
		.end:
	pop ECX
	ret


; Removes from the string in address EAX the characters up to EBX, and moves the rest of the string accordingly.
cut_up_to:
	push EBX
		.cycle:
			; Stop just when above EBX
			cmp EAX, EBX
			ja .done
			
			; Remove the first character of the string at EAX
			call remove_first_character
			
			dec EBX
			jmp .cycle
		.done:
	pop EBX
	ret


; This method counts the characters in the string pointed at by the EAX. Return the result in the EBX register.
get_string_length:
	push EAX
		; Start with EBX to 0
		xor EBX, EBX
		.cycle:
			; Stop at the first 0
			cmp byte [EAX], 0
			je .done
			
			; Increase the count
			inc EBX
			
			; Point to the next byte
			inc EAX
			jmp .cycle
		
		.done:
	pop EAX
	ret


; Count the repetitions of the character AL, in the string EBX.
; Returns the count in ECX
count_repetitions_in_string:
	push AX
	push EBX
		; ECX = 0
		xor ECX, ECX
		
		; Count cycle:
		.cycle:
			; Check if the next byte is equal to AL
			cmp byte [EBX], AL
			jne .not_equal
				; Increase the count
				inc ECX
			.not_equal:
			
			; Stop if the next byte is 0
			cmp byte [EBX], 0
			je .done
			
			; Next cycle:
			inc EBX
			jmp .cycle
		
		.done:
	pop EBX
	pop AX
	ret


; Clones the string at ESI, into EDI
clone_string_into:
	push ESI
	push EDI
	push AX
		.cycle:
			; Move the next byte
			mov AL, byte [ESI]
			mov byte [EDI], AL
			
			; Stop at 0
			cmp AL, 0
			je .end
			
			; Next cycle
			inc ESI
			inc EDI
			jmp .cycle
			
		.end:
	pop AX
	pop EDI
	pop ESI
	ret


; This method removes the first character of the string at EAX, by moving all the remaining characters back one place up to the first byte 0.
remove_first_character:
	push EAX
	push BX
	.cycle:
		mov BL, byte [EAX + 1]
		mov byte [EAX], BL
		
		cmp BL, 0
		je .done
		
		inc EAX
		jmp .cycle
	
		.done:
	pop BX
	pop EAX
	ret


