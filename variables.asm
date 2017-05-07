


; Method for handling the #vars command: It prints all defined vars.
print_vars:
	push ESI
	push AX
		mov ESI, variables_space
		call increase_identation_level
		PutStr str_defined_variables
		nwln
		
		cmp byte [ESI], 0
		jne .not_empty
			call print_identation
			PutStr str_variables_empty
			nwln
			jmp .done_printing
		.not_empty:
		
		.cycle:
			cmp byte [ESI], 0
			jne .not_zero
				inc ESI
				cmp byte [ESI], 0
				jne .not_second
					jmp .done_printing
				.not_second:
			.not_zero:
			
			; kevin0sem0piedra0matamoros00
			;           ^
			
			call print_identation
			PutStr ESI
			PutCh ' '
			PutCh '='
			PutCh ' '
			call find_next_zero_esi
			inc ESI
			PutStr ESI
			call find_next_zero_esi
			nwln
			jmp .cycle
			
		.done_printing:
		call decrease_identation_level
	pop AX
	pop ESI
	ret


; This method is used to process user_input as a variable definition operation.
process_variable_definition:
	push ESI
	push EDI
	push EAX
		; Check that there is exactly one ':' character
		mov ESI, user_input

		; AL: has a ':' already been found:
		xor AL, AL ; AL = false

		; Cycle to check every byte:
		.find_cycle:
			; if byte == ':' {
			cmp byte [ESI], VARIABLE_DEF_CHAR
			jne .not_def_char

				; if not already found one {
				cmp AL, 1
				je .second_def_char
					
					; mark already found one
					mov AL, 1

					; next cycle
					jmp .next_cycle

				; } else {
				.second_def_char:

					; just continue
					jmp .more_than_one

				; }

			; } else {
			.not_def_char:
				
				; if byte == 0, end cycle
				cmp byte [ESI], 0
				je .done_find_cycle

			; }

			.next_cycle:
			inc ESI
			jmp .find_cycle

		.more_than_one:
			mov byte [error_reason], REASON_MULTIPLE_CHARACTERS
			mov byte [error_code], ERROR_INVALID_EXPRESSION
			mov byte [error_extra_info], VARIABLE_DEF_CHAR
			mov dword [error_extra_info2], user_input
			jmp .end
		.done_find_cycle:

		; Check that there are no invalid characters
		; Check that everything before is a single variable name
		mov ESI, user_input
		call get_next_token
		cmp byte [token_space], 0
		jne .first_not_zero
			; There were no tokens:
			mov byte [error_code], ERROR_INVALID_EXPRESSION
			mov byte [error_reason], REASON_NO_TOKENS
			jmp .end
		.first_not_zero:
			call is_valid_variable_name
			je .valid_name
				mov byte [error_code], ERROR_INVALID_VARIABLE_NAME
				mov dword [error_extra_info2], token_space
				jmp .end
			.valid_name:
				; Clone string at token_space into string_a
				push ESI ; Preserve ESI
					mov ESI, token_space
					mov EDI, string_a
					; Save variable name in string_a:
					call clone_string_into
				pop ESI

				call get_next_token
				cmp byte [token_space], VARIABLE_DEF_CHAR
				je .was_colon
					mov byte [error_code], ERROR_INVALID_EXPRESSION
					mov byte [error_reason], REASON_DEF_CHAR
					mov dword [error_extra_info2], token_space
					jmp .end
				.was_colon:
					jmp .valid_two_tokens
		
		.valid_two_tokens:
			; The first two tokens were: a variable name, and a ':'
			; character, now check if there is at least one other token.
			mov EAX, ESI ; Save ESI

			call get_next_token
			
			; Raise error if no more tokens:
			cmp byte [token_space], 0
			jne .more_tokens
				; No more tokens.
				mov byte [error_code], ERROR_INVALID_EXPRESSION
				mov byte [error_extra_info], REASON_NOT_ENOUGH_TOKENS
				jmp .end

			.more_tokens:

			; Copy the rest of user_input into string_b.
			mov ESI, EAX ; Restore ESI.
			inc ESI ; Ignore the space between tokens.
			mov EDI, string_b
			call clone_string_into
			
			; TODO: Check that the variable's name is not a valid hexadecimal number.
			
			call define_variable
			
			nwln
			call increase_identation_level
				call print_identation
				PutStr str_defined_variable1
				PutStr string_a
				PutStr str_defined_variable2
				PutStr string_b
				PutStr str_close_string
			call decrease_identation_level
			nwln
			
		.end:
	pop EAX
	pop EDI
	pop ESI
	ret


; Checks if the string at token_space is a valid variable name.
is_valid_variable_name:
	push ESI
	push EDI
		mov ESI, token_space
		mov EDI, variable_names_chars
		
		; Sets ZF to true only if the string at token_space is composed only of
		; characters found in the string pointed at by variable_names_chars.
		call is_string_composed_of
	pop EDI
	pop ESI
	ret


; This method defines (or redefines) a variable (i.e. stores the variable in variables_space).
; It receives the variable's name from string_a and it'ds value from string_b.
define_variable:
	push ESI
		; Remove any previous definitions:
		call remove_variable
		
		; Push string_a into variables_space:
		mov ESI, string_a
		call push_into_variables
		
		; Push the value, string_b:
		mov ESI, string_b
		call push_into_variables
	pop ESI
	ret


; This method "pushes" the string pointed at by ESI into vatiables_space as a new token (i.e. separated by 0's).
push_into_variables:
	push ESI
	push EDI
	push AX
		; Find place to insert new token:
		mov EDI, variables_space
		cmp byte [EDI], 0
		jne .not_empty
			; variables_space is (should be) empty, just push it in the first byte.
			jmp .limit_found
		.not_empty:
		
		.limit_cycle:
			cmp byte [EDI], 0
			jne .next_limit_cycle
				inc EDI
				cmp byte [EDI], 0
				jne .next_limit_cycle
					jmp .limit_found

			.next_limit_cycle:
				inc EDI
				jmp .limit_cycle

		.limit_found:
			; Now the string at ESI must be cloned into EDI
			.clone_cycle:
				; Copy next byte:
				mov AL, byte [ESI]
				mov byte [EDI], AL
				
				; Check for end of string:
				cmp AL, 0
				je .done_copying
				
				; Next cycle:
				inc ESI
				inc EDI
				jmp .clone_cycle
			
			.done_copying:
				; Put another zero to delimit variables' end.
				inc EDI
				mov byte [EDI], 0
	pop AX
	pop EDI
	pop ESI
	ret


; string_a = value of the variable of name <string at token_space>
get_variable_value:
	push ESI
	push EDI
		; Make sure that the result is "" by default:
		mov byte [string_a], 0
		; Check if variables_space is empty:
		cmp byte [variables_space], 0
		je .no_variables
			; Find variable's name:
			
			mov ESI, variables_space
			
			.find_name_cycle:
			
			; Check if we reached the end of variables_space
			cmp byte [ESI], 0
			jne .not_empty
				cmp byte [ESI + 1], 0
				jne .not_empty
					; Return "" in string_a
					mov byte [string_a], 0
					jmp .done
			.not_empty:
			
			; Compare token_space to the current token in variables_space
			mov EDI, token_space
			call compare_strings
			
			jne .token_not_equal
				; Found variable's name.
				mov EDI, string_a
				call find_next_zero_esi
				inc ESI
				call clone_string_into
				jmp .done
			.token_not_equal:
				; The name being checked is not equal to string_a,
				;   continue with the next pair:
				call find_next_zero_esi
				inc ESI ; Ignore the middle zero
				call find_next_zero_esi
				inc ESI ; Ignore the pair limit zero
				; Now ESI points to the next pair's name token.
				jmp .find_name_cycle
			
			.done:
				
		.no_variables:
	pop EDI
	pop ESI
	ret


remove_variable:
	push ESI
	push EDI
		; Check if variables_space is empty:
		cmp byte [variables_space], 0
		je .no_variables
			; Find variable's name:
			
			mov ESI, variables_space
			mov EDI, string_a
			
			.find_name_cycle:
			
			; If no more tokens, return.
			cmp byte [ESI], 0
			je .not_found
			
			call compare_strings
			jne .token_not_equal
				; Found variable's name.
				; Remove this token (the name), and
				;   the next token (the value).
				call remove_variable_token
				call remove_variable_token
				jmp .done
			.token_not_equal:
				; The name being checked is not equal to string_a,
				;   continue with the next pair:
				call find_next_zero_esi
				inc ESI ; Ignore the middle zero
				call find_next_zero_esi
				inc ESI ; Ignore the pair limit zero
				; Now ESI points to the next pair's name token.
				jmp .find_name_cycle
			
			.done:
		
		.not_found:
		.no_variables:
	pop EDI
	pop ESI
	ret


; Removes the token pointed at by ESI, treatiing ESI as being inside variables_space.
remove_variable_token:
	push ESI
	push EDI
	push AX

		mov EDI, ESI
		call find_next_zero_esi
		inc ESI
		cmp byte [ESI], 0
		jne .more_than_one_token
			; There are zero or one tokens.
			mov byte [ESI], 0
			dec ESI
			mov byte [ESI], 0
			jmp .done
		.more_than_one_token:
		mov AH, 0 ; Previous was zero = false
		.copy_cycle:
			mov AL, byte [ESI]
			mov byte [EDI], AL

			cmp AL, 0
			jne .was_not_zero
				cmp AH, 0
				je .not_second
					; Copied a second zero, i.e. reached the end of variables_space.
					jmp .done
				.not_second:
					mov AH, 1 ; Previous was zero
					jmp .next_cycle
			.was_not_zero:
				mov AH, 0
			.next_cycle:
				inc ESI
				inc EDI
				jmp .copy_cycle
		.done:

	pop AX
	pop EDI
	pop ESI
	ret



; This method moves ESI to the next byte that is a zero in memory. If the byte pointed at ESI initially is zero, nothing is done.
find_next_zero_esi:
	.cycle:
		cmp byte [ESI], 0
		je .found
		
		inc ESI
		jmp .cycle
		
	.found:
	ret

