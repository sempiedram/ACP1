


; This method copies the string from the address EAX up to EBX, to token_space
copy_to_token:
	pushad
		; EDX keeps the address of where to copy the next byte.
		mov EDX, token_space
		
		.cycle:
			; Stop when reached the EBX address
			cmp EAX, EBX
			jae .done
			
			; Move a byte from EAX to token_space
			mov CL, byte [EAX]
			mov byte [EDX], CL
			
			inc EAX
			inc EDX
			jmp .cycle
			
		.done:
			; Close the string at token_space
			mov byte [EDX], 0
	popad
	ret


; Moves the first token from user_input into token_space
get_first_token:
	pushad
		; Put the first token limit in EAX
		call find_first_token_limit
		
		; Move found limit to EBX
		mov EBX, EAX
		
		; Move the first token from user_input onto token_space
		mov EAX, user_input
		call copy_to_token
		
		; Remove token from user_input
		call cut_up_to
		
	popad
	ret


; Finds the limit of the first token in user_input.
	; Output: EAX, the limit of the token
find_first_token_limit:
	push EBX
		; Start from user_input.
		mov EAX, user_input
		
		; Put the user_input string limit in EBX
		mov EBX, user_input
		add EBX, INPUT_LIMIT
		
		; Seek cycle:
		.cycle:
			; Stop if EAX is above EBX (the end of the string)
			cmp EAX, EBX
			ja .done
			
			; Stop at the first space
			cmp byte [EAX], SPACE_CHAR
			je .done
			
			; Stop at the first 0
			cmp byte [EAX], 0
			je .done
			
			; Next cycle:
			inc EAX
			jmp .cycle
		
		.done:
	pop EBX
	ret

