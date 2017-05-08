


; This method handles arithmetic operations.
; The expression to process is read from the user_input string.
; The result of the evaluation of the expression is shown.
; If an error happens, the evaluation stops, and an error message should be displayed.
process_arithmetic:
	nwln
	call increase_identation_level

	; 1. Expand variables.
	
		call expand_variables
		nwln
	
	; 2. Do the arithmetic preprocessing.
	
		call arithmetic_preprocessing
		
		; Check that no errors were produced.
		cmp byte [error_code], NO_ERROR
		je .no_error_2
			jmp .end
		.no_error_2:
		
		; Print the resulting expression after arithmetic_preprocessing.
		
		call print_identation
		PutStr str_arithmetic_preprocessing_result
		PutStr user_input
		PutStr str_close_string
		nwln
	
	; 3. Check that it's a valid arithmetic expression.
	
		; call check_valid_arithmetic
	
	; 4. Extract from the expression the result base.
	
		call extract_result_base
		
		; Check that no errors were produced.
		cmp byte [error_code], NO_ERROR
		je .no_error_4
			jmp .end
		.no_error_4:
		
		; Print the result base:
		call print_identation
		PutStr str_found_result_base
		call print_result_base_name
		PutStr str_close_string
		nwln
	
	; 5. Convert every number into binary.
	
		call convert_numbers_to_binary
		
		; No errors should be generated in this step.

		; Print the resulting expression, with valid numbers
		; converted into binary.

		call print_identation
		PutStr str_numbers_converted
		PutStr user_input
		PutStr str_close_string
		nwln
	
	; 6. Convert the expression into postfix.
	
		call convert_to_postfix
		
		; Check that no errors were produced.
		cmp byte [error_code], NO_ERROR
		je .no_error_6
			jmp .end
		.no_error_6: ; No error in step 6
		
		; Print the resulting postfix expression.
		
		call print_identation
		PutStr str_postfix_result
		PutStr expression_space
		PutStr str_close_string
		nwln
	
	; 7. Evaluate the postfix expression.
	
		call evaluate_postfix
		
		; Check that no errors were produced.
		cmp byte [error_code], NO_ERROR
		je .no_error_7
			jmp .end
		.no_error_7: ; No error in step 7
		
		; Print the resulting postfix expression.
		
		call print_identation
		PutStr str_evaluation_result
		PutStr string_a
		PutStr str_close_string
		nwln
	
	; 8. Convert the resulting number from binary into the result base.
	
		call convert_final_result
	
	.end:
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
			; Now ECX = position of '='
			
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
			
			cmp AL, 0 ; Check if the base was not recognized.
			jne .was_recognized
				; Indicate that there was an error.
				mov byte [error_code], ERROR_INVALID_BASE
				
				; Add as extra info the address of the received base string.
				mov dword [error_extra_info2], ESI
				
			.was_recognized:
			
			; Now AL = 0, 2, 8, or 16
			
			; Store the base that was found.
			mov byte [result_base], AL
			jmp .end
		.not_found:
			; The '=' was not found. This should not happen.
			; Raise an error, and return.
			mov byte [error_code], ERROR_NO_RESULT_BASE_INDICATOR
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


; This method computes the postfix equivalent of the original expression at user_input and stores it in the expression_space.
; This method assumes that the expression in user_input only has tokens that are valid binary numbers, operators, or parenthesis, and that the pairs of parenthesis are matched.

; TODO list:
; - [Too hard], check that there still is space to push things.

convert_to_postfix:
	push EAX
	push EBX
		; Save a copy of user_input
		call clone_user_input
		
		; Clear stack and expression.
		mov byte [stack_space], 0
		mov byte [expression_space], 0
		
		; previous was number = false
		mov byte [previous_was_number], 0
		
		; while there are tokens in the expression {
			; token = take first token of the expression
		.cycle:
		call get_first_token
		cmp byte [token_space], 0 ; If there are no more tokens, end cycle.
		je .tokens_done
			
			; if token is '-' {
			cmp byte [token_space], SUBTRACTION_OPERATION_CHAR
			jne .not_minus
			
			; Check that the token is only "-".
			cmp byte [token_space + 1], 0
			jne .not_minus
				
				; if previous was not number {
				mov AL, byte [previous_was_number]
				test AL, AL
				jnz .previous_not_number_subtraction
				
					; ; It's a negation.
					; token = '~'
					mov byte [token_space], COMPLEMENT_CHAR
					
				; }
				.previous_not_number_subtraction:
				
			; }
			.not_minus:
			
			; if token is a number {
			call is_token_binary_number
			jne .not_number
			
				; We could check here if the previous token was also a number, which
				; would mean that there is an error in the expression (e.g.: "4 5 + 1", or "2 + (3 * 2) 7").
				
				mov AL, byte [previous_was_number]
				test AL, AL
				jz .not_numbers_together
					mov byte [error_code], ERROR_INVALID_EXPRESSION
					mov byte [error_extra_info], REASON_NUMBERS_TOGETHER
					jmp .end
				.not_numbers_together:
			
				; add it to the new expression
				call push_token_to_expression
				
				; previous was number = true
				mov byte [previous_was_number], 1
					
				; continue with next token
				jmp .next_cycle
				
			; }else {
			.not_number:
			
				; previous was number = false
				mov byte [previous_was_number], 0
				
				; if token is an operator {
				call is_token_operator
				jne .not_operator
				
					; if the stack is empty {
					call is_stack_empty
					jne .stack_not_empty
					
						; push token into stack
						call push_token_to_stack
					
						; continue with next token
						jmp .next_cycle
						
					; }else {
					.stack_not_empty:
					
						; ; compare token precedence to top of the stack operation precedence
						
						; top token = peek top token
						call clone_token
						call peek_token_from_stack
						
						; top precedence = top token precedence
						call token_precedence
						mov BL, AL ; BL = top token precedence
						
						; precedence = token precedence
						call restore_token
						call token_precedence ; AL = token precedence
						
						; if precedence > top token precedence {
						cmp AL, BL
						jng .less_or_equal_precedence
						
							; push token into stack
							call push_token_to_stack
					
							; continue with next token
							jmp .next_cycle
							
						; }else {
						.less_or_equal_precedence:
						
							; ; precedence <= top token precedence
							; ; pop top token and add it to the new expression
							
							; top token = pop token from stack
							call clone_token
							call pop_token_from_stack
							
							; add token to new expression
							call push_token_to_expression
							
							; push token into stack
							call restore_token
							call push_token_to_stack
					
							; continue with next token
							jmp .next_cycle
							
						; }
						
					; }
					
				; }else {
				.not_operator:
				
					; if token is open parenthesis {
					cmp byte [token_space], OPEN_PARENTHESIS
					jne .not_open_parenthesis
					
					cmp byte [token_space + 1], 0
					jne .not_open_parenthesis
					
						; place it in the stack
						call push_token_to_stack
					
						; continue with next token
						jmp .next_cycle
						
					; }else {
					.not_open_parenthesis:
					
						; ; Token should be close parenthesis
						
						; if token is not close parenthesis {
						
						cmp byte [token_space], CLOSE_PARENTHESIS
						je .was_close_parenthesis
						
							; raise error saying so
							mov byte [error_code], ERROR_INVALID_TOKEN
							mov dword [error_extra_info2], token_space
							jmp .end
							
						; }
						.was_close_parenthesis:
						
						cmp byte [token_space + 1], 0
						je .was_close_parenthesis2
						
							; It's a token that starts with '(', but
							; has multiple characters, therefore, it's
							; not a valid open parenthesis.
						
							; raise error saying so
							mov byte [error_code], ERROR_INVALID_TOKEN
							mov dword [error_extra_info2], token_space
							jmp .end
							
						.was_close_parenthesis2:
						
						; while next token in stack is not open parenthesis and the stack is not empty {
						
						.parenthesis_pop_cycle:
						; Stop popping cycle if stack is empty.
						call is_stack_empty
						je .end_parenthesis_pop_cycle
						call peek_token_from_stack
						; Stop cycle if token is '(':
						cmp byte [token_space], OPEN_PARENTHESIS
						je .pop_open_parenthesis
						
							; ; pop operator and put it on the new expression
							
							; pop next token
							call pop_token_from_stack
							
							; push next token to expression
							call push_token_to_expression
							
						; }
							jmp .parenthesis_pop_cycle
						.pop_open_parenthesis:
							; pop open parenthesis
							call pop_token_from_stack
						.end_parenthesis_pop_cycle:
						
						; previous was number = true
						mov byte [previous_was_number], 1
					
						; continue with next token
						jmp .next_cycle
						
					; }
					
				; }
				
			; }
			
		; }
		.next_cycle:
			jmp .cycle
		
		.tokens_done:

		; while stack is not empty {
		.pop_cycle:
		call is_stack_empty
		je .end_pop_cycle
		
			; ; pop operator and put it in the new expression
			
			; pop token from stack
			call pop_token_from_stack
			
			; push that token into the stack
			call push_token_to_expression
			
		; }
			jmp .pop_cycle
		.end_pop_cycle:
		.end:
		
		call restore_user_input
	pop EBX
	pop EAX
	ret


; Returns the precedence of the token in token_space. It assumes the token is a valid operator (i.e. of +, -, *, or /).
; Returns the token's precedence in the AL register, or 0 if not recognized.
token_precedence:
	push BX
		; AL = operation character
		mov AL, byte [token_space]
		
		; Compare operation to '+'
		mov BL, ADDITION_OPERATION_CHAR
		cmp BL, AL
		jne .not_addition
			mov AL, ADDITION_OPERATION_PRECEDENCE
			jmp .end
		.not_addition:
		
		; Compare operation to '-'
		mov BL, SUBTRACTION_OPERATION_CHAR
		cmp BL, AL
		jne .not_subtraction
			mov AL, SUBTRACTION_OPERATION_PRECEDENCE
			jmp .end
		.not_subtraction:
		
		; Compare operation to '*'
		mov BL, MULTIPLICATION_OPERATION_CHAR
		cmp BL, AL
		jne .not_multiplication
			mov AL, MULTIPLICATION_OPERATION_PRECEDENCE
			jmp .end
		.not_multiplication:
				
		; Compare operation to '/'
		mov BL, DIVISION_OPERATION_CHAR
		cmp BL, AL
		jne .not_division
			mov AL, DIVISION_OPERATION_PRECEDENCE
			jmp .end
		.not_division:
		
		; Compare operation to '~'
		mov BL, COMPLEMENT_CHAR
		cmp BL, AL
		jne .not_complement
			mov AL, COMPLEMENT_OPERATION_PRECEDENCE
			jmp .end
		.not_complement:
	
		; If it's not a recognized operation, return 0.
		mov AL, 0
		
		.end:
	pop BX
	ret


; Checks whether token_space is a valid binary number.
; Returns true or false through the zero flag.
is_token_binary_number:
	push EAX
	push CX
	push ESI
	
		mov EAX, token_space ; To scan token_space
		
		; Return false if there's only three characters.
		call get_string_length
		cmp EBX, 3
		ja .more_than_three
			jmp .return_false
		.more_than_three:
		
		; Keep count of number of bits in CX.
		; CX = 0
		xor CX, CX
		
		; Scan the token:
		.cycle:
			mov BL, byte [EAX]
			; Check end of token:
			cmp BL, 0
			je .return_false
			
			; Check if it's a bit:
			cmp BL, OFF_BIT_CHAR
			je .was_bit
			cmp BL, ON_BIT_CHAR
			je .was_bit
				; Found something in the token that was not a bit.
				; It should be the "bin" sufix. Check that.
				jmp .check_base
			.was_bit:
			
			inc CX ; Increase bit count
			cmp CX, MAX_BITS
			jg .return_false
			
			inc EAX ; Next byte
			jmp .cycle
		
		.check_base:
			; Check that the remaining part of the token is "bin".
			mov ESI, EAX
			call get_base_from_string ; AL = value of base
			cmp AL, 2 ; Compare base value to 2 (binary)
			
			; Return accordingly:
			je .return_true
			jmp .return_false
		
		.return_false:
			
			; More than MAX_BITS bits.
			; Return false.
			mov AL, 1 ; Set ZF to false.
			cmp AL, 0
			jmp .end
		
		.return_true:
			
			; More than MAX_BITS bits.
			; Return true.
			mov AL, 0 ; Set ZF to true.
			cmp AL, 0
			jmp .end
		
		.end:
		
	pop ESI
	pop CX
	pop EAX
	ret


; Checks that token_space is an operator.
; Returns false or true through the ZF.
is_token_operator:
	push AX
		; All operators are single characters.
		; Therefore, the second character in token_space should be a 0. Check that:
		
		cmp byte [token_space + 1], 0
		jne .return_false
		
		; Test the operation's precedence.
		; If it's not recognized, AL will be 0, return accordingly.
		call token_precedence
		cmp AL, 0
		je .return_false
		jmp .return_true
		
		.return_false:
		
			mov AL, 1 ; Set ZF to false.
			cmp AL, 0
			jmp .end
		
		.return_true:
			
			mov AL, 0 ; Set ZF to true.
			cmp AL, 0
			jmp .end
			
		.end:
	pop AX
	ret


; Check whether the stack is empty.
; Returns true or false, through the ZF.
is_stack_empty:
	; Check if the first byte in stack_space is 0 (i.e. the stack is empty).
	cmp byte [stack_space], 0
	ret


; Pushes the current token into the stack.
push_token_to_stack:
	push EAX
	push EDI
	push ESI
		mov EAX, stack_space
		
		; Cycle to find the first 0's position:
		.cycle:
			; Stop at first 0.
			cmp byte [EAX], 0
			je .found
			
			; Check next byte:
			inc EAX
			jmp .cycle
		
		.found:
			; Check if it was empty:
			cmp EAX, stack_space
			je .was_empty
				; Write a separator space:
				mov byte [EAX], SPACE_CHAR
				inc EAX
			.was_empty:
			
			; Copy the token into the stack_space
			mov ESI, token_space
			mov EDI, EAX
			call clone_string_into
	pop ESI
	pop EDI
	pop EAX
	ret


; Copies (and removes) the last token from the stack into token_space.
; TODO: indicate an error if there are no more tokens.
pop_token_from_stack:
	push EAX
	push ESI
	push EDI
		; Find previous stack limit.
		mov EAX, stack_space
		
		; If it's empty, there's nothing to pop (duh.).
		cmp byte [EAX], 0
		je .stack_was_empty
		
		; Cycle to find the first 0's position:
		inc EAX ; Stack was not empty -> first byte is not zero -> don't recheck that byte.
		
		.cycle:
			; Stop at first 0.
			cmp byte [EAX], 0
			je .found_0
			
			; Check next byte:
			inc EAX
			jmp .cycle
		
		.found_0:
			; Found a zero that was not at the beginning of the stack_space.
			dec EAX ; Ignore that 0.

			; Look for space or beginning of stack.
			.find_limit:
				cmp EAX, stack_space
				je .found_limit

				cmp byte [EAX], SPACE_CHAR
				je .found_limit_space

				dec EAX
				jmp .find_limit

			.found_limit_space:
				mov byte [EAX], 0 ; Remove the space
				inc EAX ; Ignore the space
			.found_limit:

			; Copy from that limit up to the end of the stack into token_space (without the space).
			
			mov ESI, EAX
			mov EDI, token_space
			call clone_string_into

			mov byte [EAX], 0 ; Delete the popped token from stack
			jmp .end
		
		.stack_was_empty:
			; The stack was empty -> return an empty token.
			mov byte [token_space], 0
		.end:
	pop EDI
	pop ESI
	pop EAX
	ret


; This copies the last token in the stack into token_space, without removing it.
peek_token_from_stack:
	push EAX
	push ESI
	push EDI
		; Find previous stack limit.
		mov EAX, stack_space
		
		; If it's empty, there's nothing to pop (duh.).
		cmp byte [EAX], 0
		je .stack_was_empty
		
		; Cycle to find the first 0's position:
		inc EAX ; Stack was not empty -> first byte is not zero -> don't recheck that byte.
		
		.cycle:
			; Stop at first 0.
			cmp byte [EAX], 0
			je .found_0
			
			; Check next byte:
			inc EAX
			jmp .cycle
		
		.found_0:
			; Found a zero that was not at the beginning of the stack_space.
			dec EAX ; Ignore that 0.

			; Look for space or beginning of stack.
			.find_limit:
				cmp EAX, stack_space
				je .found_limit

				cmp byte [EAX], SPACE_CHAR
				je .found_limit_space

				dec EAX
				jmp .find_limit

			.found_limit_space:
				inc EAX ; Ignore the space
			.found_limit:

			; Copy from that limit up to the end of the stack into token_space (without the space).
			
			mov ESI, EAX
			mov EDI, token_space
			call clone_string_into

			jmp .end
		
		.stack_was_empty:
			; The stack was empty -> return an empty token.
			mov byte [token_space], 0
		.end:
	pop EDI
	pop ESI
	pop EAX
	ret


; Copies token_space into the end of expression_space.
push_token_to_expression:
	push EAX
	push EDI
	push ESI
		mov EAX, expression_space
		
		; Cycle to find the first 0's position:
		.cycle:
			; Stop at first 0.
			cmp byte [EAX], 0
			je .found
			
			; Check next byte:
			inc EAX
			jmp .cycle
		
		.found:
			; Check if it was empty:
			cmp EAX, expression_space
			je .was_empty
				; Write a separator space:
				mov byte [EAX], SPACE_CHAR
				inc EAX
			.was_empty:
			
			; Copy the token into the expression_space
			mov ESI, token_space
			MOV EDI, EAX
			call clone_string_into
	pop ESI
	pop EDI
	pop EAX
	ret


; This method clones token_space into token_space_swap
clone_token:
	push ESI
	push EDI
		mov ESI, token_space
		mov EDI, token_space_swap
		call clone_string_into
	pop EDI
	pop ESI
	ret


; This method "restores" the previously saved token by copying token_space_swap into token_space.
restore_token:
	push ESI
	push EDI
		mov ESI, token_space_swap
		mov EDI, token_space
		call clone_string_into
	pop EDI
	pop ESI
	ret


; Expands the variable names in user_input (i.e. replaces the names with their respective values).
; If a name is not a variable, it's simply not expanded.
expand_variables:
	push ESI
	push EDI
	push EAX
		; AH will be used to keep track of whether a variable was expanded.
		xor AH, AH ; AH = false
		mov EDI, user_input_swap
		; while there are tokens in user_input {
		.token_cycle:
		call get_first_token
		cmp byte [token_space], 0
		je .no_more_tokens
			; if token is a variable {
			call get_variable_value ; string_a = variable value
			cmp byte [string_a], 0
			je .not_defined
				mov ESI, string_a
				mov AH, 1
				jmp .copy_string
			; }else {
			.not_defined:
				mov ESI, token_space
				jmp .copy_string
			; }
			.copy_string:
				mov AL, byte [ESI]
				mov byte [EDI], AL
				cmp AL, 0
				je .done_copying
				inc EDI
				inc ESI
				jmp .copy_string

			.done_copying:
				mov byte [EDI], SPACE_CHAR
				inc EDI
				jmp .token_cycle
		; }
		.no_more_tokens:
			; Remove the last space written:
			dec EDI
			mov byte [EDI], 0

			; Copy the created string into user_input:
			call restore_user_input
			call preprocess ; Make sure that it's properly formatted.

			; if there were expansions {
			cmp AH, 1
			jne .no_expansions
				call print_identation
				call increase_identation
					PutStr str_variable_expansions
					PutStr user_input
					PutStr str_close_string
					nwln
					; try to expand variables again
					call expand_variables
				call decrease_identation
			; }
			.no_expansions:
	pop EAX
	pop EDI
	pop ESI
	ret

