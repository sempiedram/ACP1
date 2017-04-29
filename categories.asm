


; This method checks the category of the expression at user_input.
check_category:
	push AX
	push BX
	push ECX
		; Checks the first byte:
		mov AL, byte [user_input]
		
		; Check if it's a command: '#'
		cmp AL, COMMAND_CHAR
		je .is_command
		
		; Check if it's a complement operation: '~'
		cmp AL, COMPLEMENT_CHAR
		je .is_complement
		
		jmp .second_fase
		
		; Handle commands
		.is_command:
			mov byte [category], CATEGORY_COMMAND
			jmp .end
		
		; Handle complement
		.is_complement:
			mov byte [category], CATEGORY_COMPLEMENT
			jmp .end
			
		.second_fase:
			; Up to this point, it's either CATEGORY_ARITHMETIC or CATEGORY_VARIABLE
			
			; Look for the VARIABLE_DEF_CHAR character: ':'
			mov BL, VARIABLE_DEF_CHAR
			mov ECX, user_input
			call find_character
			jc .is_variable_definition
			
			; Look for the RESULT_BASE_INDICATOR_CHAR character: '='
			mov BL, RESULT_BASE_INDICATOR_CHAR
			call find_character
			jc .is_arithmetic
			
			; By default, unrecognized categories will be treated as CATEGORY_ARITHMETIC
			
			mov byte [category], CATEGORY_ARITHMETIC
			jmp .end
		
		.is_variable_definition:
			mov byte [category], CATEGORY_VARIABLE
			jmp .end
		
		.is_arithmetic:
			mov byte [category], CATEGORY_ARITHMETIC
			jmp .end
		
		.end:
	pop ECX
	pop BX
	pop AX
	ret


; This method prints the category's name depending on the value of the category variable.
print_category_name:
	push AX
		; Print category name comparing category byte to the different categories:
		mov AL, byte [category]
		
		cmp AL, CATEGORY_ARITHMETIC
		je .process_category_arithmetic
		
		cmp AL, CATEGORY_COMMAND
		je .process_category_command
		
		cmp AL, CATEGORY_COMPLEMENT
		je .process_category_complement
		
		cmp AL, CATEGORY_VARIABLE
		je .process_category_variable
		
		; No category:
		PutStr category_name_invalid
		jmp .end
		
		.process_category_arithmetic:
			PutStr category_name_arithmetic
			jmp .end
		
		.process_category_command:
			PutStr category_name_command
			jmp .end
		
		.process_category_complement:
			PutStr category_name_complement
			jmp .end
		
		.process_category_variable:
			PutStr category_name_variable
			jmp .end
		
		.end:
	pop AX
	ret


