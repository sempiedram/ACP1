


; This method handles arithmetic operations.
; The expression to process is read from the user_input string.
; The result of the evaluation of the expression is shown.
; If an error happens, the evaluation stops, and an error message should be displayed.
process_arithmetic:
	nwln
	call increase_identation_level

	; 1. Expand variables.
	
	; call expand_variables
	
	; 2. Do the arithmetic preprocessing.
	
	; call arithmetic_preprocessing
	
	; 3. Check that it's a valid arithmetic expression.
	
	; call check_valid_arithmetic
	
	; 4. Extract from the expression the result base.
	
	call extract_result_base
	
	; Print the result base:
	call print_identation
	PutStr str_found_result_base
	call print_result_base_name
	PutStr str_close_string
	nwln
	
	; 5. Convert every number into binary.
	
	; call convert_numbers_to_binary
	
	; 6. Convert the expression into postfix.
	
	call convert_to_postfix
	
	; 7. Evaluate the postfix expression.
	
	; call evaluate_postfix
	
	; 8. Convert the resulting number from binary into the result base.
	
	; call convert_final_result
	
	
	call decrease_identation_level
	ret


; This method extracts from user_input the result base. It removes the " = <base>" part of the expression, and stores the result in the result_base byte.
extract_result_base:
	; At this point, the expression must have the following format:
	
		; <arithmetic expression> = <base>
		
	; Where arithmetic expression is composed only of valid tokens (but might not be a valid expression. And base is one of: "bin", "oct", "dec", or "hex".
	
	; Extracting that base is rather easy: cut that part of the expression (remove " = <base>" and copy it somewhere else), remove the " = " part, and compare the remaining three characters to the bases.
	
	push EAX
	push EBX
	push ECX
	push EDX
		; ECX = position of '=' or -1 if not found
		mov AL, RESULT_BASE_INDICATOR_CHAR
		mov EBX, user_input
		call find_character_position
		
		cmp ECX, -1
		je .not_found
			; ECX = position of '='
			
			; Take into account the space behind the '=':
			dec ECX
			
			; Clone that part of the expression into string_a:
			mov ESI, ECX
			mov EDI, string_a
			call clone_string_into
			
			; Remove that part of the expression:
			mov byte [ECX], 0
			
			; At this point string_a is " = <base>"
			mov EAX, string_a
			call remove_first_character ; Remove first space
			call remove_first_character ; Remove '='
			call remove_first_character ; Remove second space
			
			; Now string_a is just "<base>"
			mov ESI, string_a
			call get_base_from_string
			; Now AL = 2, 8, or 16
			
			; Store the base that was found.
			mov byte [result_base], AL
			jmp .end
		.not_found:
			; The '=' was not found. This should not happen.
			; Raise an error, and return.
			jmp .end
		
		.end:
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	ret


; Prints the name of the result base.
print_result_base_name:
	push AX
		mov AL, byte [result_base]
		call print_base_name
	pop AX
	ret


; Prints the name of the base at AL, 0 -> invalid, 2 -> binary, 8 -> octal, 10 -> decimal, and 16 -> hexadecimal
print_base_name:
	cmp AL, 2
	je .was_binary
	
	cmp AL, 8
	je .was_octal
	
	cmp AL, 10
	je .was_decimal
	
	cmp AL, 16
	je .was_hexadecimal
	
	; It was not a recognized base, print "invalid".
	PutStr invalid_base_identifier
	jmp .end
	
	.was_binary:
		PutStr binary_base_identifier
		jmp .end
	
	.was_octal:
		PutStr octal_base_identifier
		jmp .end
	
	.was_decimal:
		PutStr decimal_base_identifier
		jmp .end
	
	.was_hexadecimal:
		PutStr hexadecimal_base_identifier
	
	.end:
	ret


; Compares the string at ESI to binary_base_identifier, octal_base_identifier, decimal_base_identifier, and hexadecimal_base_identifier to find the corresponding base. Returns 0, 2, 8, 10, or 16 in the AL register.
get_base_from_string:
	push EDI
		mov EDI, binary_base_identifier
		call compare_strings
		je .return_2
		
		mov EDI, octal_base_identifier
		call compare_strings
		je .return_8
		
		mov EDI, decimal_base_identifier
		call compare_strings
		je .return_10
		
		mov EDI, hexadecimal_base_identifier
		call compare_strings
		je .return_16
		
		je .return_0
		
		.return_0:
			mov AL, 0
			jmp .end
		
		.return_2:
			mov AL, 2
			jmp .end
		
		.return_8:
			mov AL, 8
			jmp .end
		
		.return_10:
			mov AL, 10
			jmp .end
		
		.return_16:
			mov AL, 16
			jmp .end
		
		.end:
	pop EDI
	ret


convert_to_postfix:
	ret

