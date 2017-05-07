


; This method copies the string from the address EAX up to EBX, to token_space
copy_to_token:
	pushad
		; EDX keeps the address of where to copy the next byte.
		mov EDX, token_space
		
		; Make sure that token_space is empty:
		mov byte [EDX], 0
		
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


; Finds the limit of the current token.
; ESI should be pointing to the first character of the current token.
; At the end of this method, ESI will be pointing at the end limit of that token.
; If there are no tokens in the string (i.e. the first byte is 0), then
; it doesn't move ESI.
find_next_token_limit:
		cmp byte [ESI], 0
		jne .first_not_zero
			; The byte was zero, it's the end of the string
			; It could mean user_input is empty.
			jmp .end

		.first_not_zero:

		.cycle:
			cmp byte [ESI], 0
			jne .not_zero
				; Found a zero.
				; Return that as the limit of the token.
				jmp .end
			.not_zero:
			
			cmp byte [ESI], SPACE_CHAR
			jne .not_space
				; Found a space.
				jmp .end
			.not_space:

			; It's a "normal" character, go to next byte.
			inc ESI
			jmp .cycle

		.end:
	ret


; This method gets the next token from the string pointed at by ESI.
; If there are no more tokens, returns empty token and doesn't move ESI.
; Example of use:
;   mov ESI, user_input
;   call get_next_token
;   cmp byte [token_space], 0
;   je .no_more_tokens
get_next_token:
	push EDI
	push AX
		cmp byte [ESI], 0
		jne .not_empty
			; Return "".
			mov byte [token_space], 0
			jmp .end
		.not_empty:

		cmp byte [ESI], SPACE_CHAR
		jne .not_space
			inc ESI ; Ignore that space.
		.not_space:

		push ESI
			call find_next_token_limit
			mov AL, byte [ESI] ; Save original delimiter (space or 0).
			mov byte [ESI], 0 ; Replace delimiter with a 0
		pop ESI
			
		push ESI
			; Clone next token into token_space
			mov EDI, token_space
			call clone_string_into
			
			call find_next_token_limit
			mov byte [ESI], AL ; Restore original delimiter
		pop ESI

		call find_next_token_limit
		.end:
	pop AX
	pop EDI
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

