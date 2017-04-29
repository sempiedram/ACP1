


; Copies user_input_swap string onto user_input.
restore_user_input:
	push EAX
	push EBX
	push CX
		; Start at user_input, and user_input_swap.
		mov EAX, user_input_swap
		mov EBX, user_input
		
		; Copy bytes:
		.cycle:
			mov EDX, user_input_swap
			add EDX, INPUT_LIMIT
			cmp EAX, EDX
			ja .done ; Check if we reached the end of the string.
			
			; Copy next byte:
			mov CL, byte [EAX]
			mov byte [EBX], CL
			
			; Stop at the first 0.
			cmp CL, 0
			je .done
			
			; Update addresses.
			inc EAX
			inc EBX
			jmp .cycle
		.done:
			; user_input_swap string was copied to user_input
	pop CX
	pop EBX
	pop EAX
	ret


; This method clones the string at user_input onto user_input_swap.
clone_user_input:
	push EAX
	push EBX
	push CX
	push EDX
		; Start at user_input, and user_input_swap.
		mov EAX, user_input
		mov EBX, user_input_swap
		
		; Copy bytes:
		.cycle:
			mov EDX, user_input
			add EDX, INPUT_LIMIT
			cmp EAX, EDX
			ja .done ; Check if we reached the end of the string.
			
			; Copy next byte:
			mov CL, byte [EAX]
			mov byte [EBX], CL
			
			; Stop at the first 0.
			cmp CL, 0
			je .done
			
			; Update addresses.
			inc EAX
			inc EBX
			jmp .cycle
		.done:
			; user_input string was copied to user_input_swap
	pop EDX
	pop CX
	pop EBX
	pop EAX
	ret


; Removes remove spaces at the beginning and end of user_input
strip_user_input:
	call strip_beginning_user_input
	call strip_end_user_input
	ret


; Remove the spaces at the beginning of user_input.
strip_beginning_user_input:
	pushad
		; Find the first non-space:
		
		; Start at user_input.
		mov EAX, user_input
		
		; Put in EBX the user_input string end.
		mov EBX, user_input
		add EBX, INPUT_LIMIT
		
		.space:
			; Stop at first non-space:
			cmp byte [EAX], SPACE_CHAR
			jne .not_space
			
			; Stop at the string end:
			cmp EAX, EBX
			jae .end_of_string
			
			inc EAX
			jmp .space
		
		.end_of_string:
			mov EAX, user_input
		
		.not_space:
		mov EBX, EAX
		mov EAX, user_input
		
		; EBX is now pointing to the first non-space character in user_input
		;   or to the beginning of the string.
		
		; Put in EBX the user_input string end.
		mov ECX, user_input
		add ECX, INPUT_LIMIT
		
		.shift_chars:
			; Stop at the end of the string.
			cmp EAX, ECX
			jae .out_of_string
			
			; It's inside the string.
			
			; Check current character in EAX.
			cmp byte [EAX], 0
			je .done_shifting
			
			; Move a byte from EBX to EAX
			mov DL, byte [EBX]
			mov byte [EAX], DL
			
			inc EAX
			inc EBX
			jmp .shift_chars
		
		.out_of_string:
		.done_shifting:
			; Done.
	popad
	ret


; Remove the spaces at the end of user_input.
strip_end_user_input:
	pushad
		mov EAX, user_input
		.scan_string_end:
			cmp byte [EAX], 0
			je .at_end
			inc EAX
			jmp .scan_string_end
		
		.at_end:
			dec EAX
			
		.substitute_spaces:
			; Stop at beginning of string.
			cmp EAX, user_input
			jb .before_start_of_string
			
			; Stop at first non space.
			cmp byte [EAX], SPACE_CHAR
			jne .not_space
			
			; Substitute space with a zero.
			mov byte [EAX], 0
			dec EAX
			jmp .substitute_spaces
		
		.before_start_of_string:
		.not_space:
			; Trailing spaces have been replaced.
	popad
	ret


; This method introduces spaces around characters which return true when tested with space_test_character; this is intended to be used for operations, for example '+++' expands to ' +  +  + '.
preprocess_insert_spaces:
	call clone_user_input
	
	pushad
		mov EAX, user_input
		mov ECX, user_input_swap
		
		.cycle:
			mov BL, byte [EAX]
			
			; Stop at the first 0.
			cmp BL, 0
			je .done
			
			; Test char in BL:
			call space_test_character
			jnc .not_expand_spaces
			
			; Save character surrounded by spaces.
				mov byte [ECX], SPACE_CHAR
				inc ECX
				mov byte [ECX], BL
				inc ECX
				mov byte [ECX], SPACE_CHAR
				inc ECX
				jmp .update_eax
			
			.not_expand_spaces:
				; Only save the character.
				mov byte [ECX], BL
				inc ECX
				
			.update_eax:
				inc EAX
			
			; Check that EAX is not pointing outside of user_input
			mov EDX, user_input
			add EDX, INPUT_LIMIT
			cmp EAX, EDX
			ja .done
			
			; Check that ECX is not pointing outside of user_input_swap
			mov EDX, user_input_swap
			add EDX, INPUT_LIMIT
			cmp ECX, EDX
			ja .no_more_space ; There's no more space in user_input_swap.
			
			jmp .cycle
		
		.no_more_space:
			mov byte [error_code], USER_INPUT_SWAP_NO_SPACE
			jmp .end
			
		.done:
			; Mark the string's end.
			mov byte [ECX], 0
			
		.end:
	popad
	
	call restore_user_input
	
	ret


; Removes repeated spaces in user_input.
preprocess_remove_repeated_spaces:
	pushf
	pushad
		; This section copies user_input onto user_input_swap removing spaces:
		mov AL, 0
		mov EBX, user_input
		mov ECX, user_input_swap

		.cycle:
			mov AH, byte [EBX]
			
			cmp AH, 0
			jne .inside_string
				mov byte [ECX], 0
				jmp .end
			.inside_string:
			
			cmp AH, SPACE_CHAR
			je .was_space
				mov byte [ECX], AH
				inc ECX
				mov AL, 0
				jmp .after
			.was_space:
				cmp AL, 1
				mov AL, 1
				je .previous_was_space
					mov byte [ECX], AH
					inc ECX
					jmp .after
				.previous_was_space:
			.after:
			
			inc EBX
			jmp .cycle
		
		.end:
		
	; This section copies the result from user_input_swap onto user_input:
		call restore_user_input
	popad
	popf
	ret


; This method tests the character at BL to see if spaces should be inserted around it.
; Affects: CF, 0 if not, 1 if yes
; Input: BL, character to test.
space_test_character:
	push BX
	push EAX
		cmp BL, 0
		je .ebx_is_zero
		
		mov EAX, spaces_chars
		
		.cycle:
			; Stop if reached the end of spaces_chars:
			cmp byte [EAX], 0
			je .not_found
			
			cmp BL, byte [EAX]
			je .found_char
			
			inc EAX
			jmp .cycle
		
		.ebx_is_zero:
			; It's an invalid char, return false.
			clc
			jmp .end
		
		 ; Return true.
		.found_char:
			stc
			jmp .end
		
		 ; Return false.
		.not_found:
			clc
			jmp .end
		
		.end:
	pop EAX
	pop BX
	ret


