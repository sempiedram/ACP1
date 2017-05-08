

; This method evaluates the expression stored in expression_space.
; The final result ends up in string_a
; The algorithm is as follows:
evaluate_postfix:
	push ESI
	push EAX
		; if expression is empty {
		cmp byte [expression_space], 0
		jne .not_empty
		
			; return empty (clear string_a)
			mov byte [string_a], 0
			jmp .return
			
		; }
		.not_empty:
		
		; Make sure that the stack has no residual stuff:
		mov byte [stack_space], 0

		; Start from expression_space
		mov ESI, expression_space
		
		; for token in expression {
		.evaluation_cycle:
		call get_next_token
		cmp byte [token_space], 0
		je .no_more_tokens
		
			; if token is number {
			call is_token_binary_number
			jne .not_binary_number
			
				; push number to stack_space
				call push_token_to_stack
				
				jmp .evaluation_cycle
			; }else {
			.not_binary_number:
			
				; ; Token should be an operator
				
				; if token is not operator {
				call is_token_operator
				je .valid_operator
				
					; raise error, invalid token(token_space)
					mov byte [error_code], ERROR_INVALID_TOKEN
					mov dword [error_extra_info2], token_space
					jmp .return
					
				; }
				.valid_operator:
				
				; operands to pop = get operation operands
				call get_operation_operands ; Now AL = 2 or 1
				
				; save token ; because pop operantions write over it
				call clone_token
				
				; if(operands to pop == 2) {
				cmp AL, 2
				jne .not_two
				
					; pop operand into string_b
					call pop_token_from_stack
					
					; Moves token into string_b
					push ESI
					push EDI
						mov ESI, token_space
						mov EDI, string_b
						call clone_string_into
					pop EDI
					pop ESI
					
					; ; Check that there are enough tokens for the evaluation.
					
					; if (no more operands) {
					cmp byte [token_space], 0
					jne .operand_b
					
						; restore token ; restore saved operation token
						call restore_token
						
						; raise error, invalid expression not enough operands (token_space)
						mov byte [error_code], ERROR_INVALID_EXPRESSION
						mov byte [error_reason], REASON_NOT_ENOUGH_OPERANDS
						mov dword [error_extra_info2], token_space
						jmp .return
						
					; }
					.operand_b:
					
				; }
				.not_two:
				
				; pop operand into string_a
				call pop_token_from_stack
				
				; Moves token into string_a
				push ESI
				push EDI
					mov ESI, token_space
					mov EDI, string_a
					call clone_string_into
				pop EDI
				pop ESI
				
				; ; Check that there are enough tokens for the evaluation.
				; if (no more operands) {
				cmp byte [token_space], 0
				jne .operand_a
					
					; restore token ; restore saved operation token
					call restore_token
					
					; raise error, invalid expression not enough operands (token_space)
					mov byte [error_code], ERROR_INVALID_EXPRESSION
					mov byte [error_reason], REASON_NOT_ENOUGH_OPERANDS
					mov dword [error_extra_info2], token_space
					jmp .return
					
				; }
				.operand_a:
				
				; restore token ; restore saved operation token
				call restore_token
				
				; evaluate operation ; now token_space = result of operation
				call evaluate_operation
				
				cmp byte [error_code], NO_ERROR
				je .no_error_evaluating
					jmp .error_evaluating
				.no_error_evaluating:
				
				; push token to stack_space
				call push_token_to_stack
				
			; }
			jmp .evaluation_cycle
			
		; }
		.no_more_tokens:

		; if stack has at least one token {
		call pop_token_from_stack
		cmp byte [token_space], 0
		je .no_result
		
			call clone_token
		
			; if stack has another token {
			call pop_token_from_stack
			cmp byte [token_space], 0
			je .not_two_tokens
			
				; raise error, too many operands
				mov byte [error_code], ERROR_INVALID_EXPRESSION
				mov byte [error_reason], REASON_TOO_MANY_OPERANDS
				jmp .return
				
			; }
			.not_two_tokens:
			
			call restore_token
			
			; copy that token into string_a
			push ESI
			push EDI
				mov ESI, token_space
				mov EDI, string_a
				call clone_string_into
			pop EDI
			pop ESI
			
			jmp .return
		; }else {
		.no_result:
		
			; ; This should not be possible, check it anyway.
			; ; Could do -> raise error, no result
			
			; return empty (clear string_a)
			mov byte [string_a], 0
			
			jmp .return
		; }
		
		.error_evaluating:
		.return:
	pop EAX
	pop ESI
	ret


; Evaluates the current operation.
; The operator should be in token_space
; The operands should be in string_a, and string_b (if two operands are required).
; The result ends up in token_space
evaluate_operation:
	push BX
		; AL = operation character
		mov AL, byte [token_space]
		
		; Compare operation to '+'
		mov BL, ADDITION_OPERATION_CHAR
		cmp BL, AL
		jne .not_addition
			call evaluate_addition
			jmp .end
		.not_addition:
		
		; Compare operation to '-'
		mov BL, SUBTRACTION_OPERATION_CHAR
		cmp BL, AL
		jne .not_subtraction
			call evaluate_subtraction
			jmp .end
		.not_subtraction:
		
		; Compare operation to '*'
		mov BL, MULTIPLICATION_OPERATION_CHAR
		cmp BL, AL
		jne .not_multiplication
			call evaluate_multiplication
			jmp .end
		.not_multiplication:
				
		; Compare operation to '/'
		mov BL, DIVISION_OPERATION_CHAR
		cmp BL, AL
		jne .not_division
			call evaluate_division
			jmp .end
		.not_division:
		
		; Compare operation to '~'
		mov BL, COMPLEMENT_CHAR
		cmp BL, AL
		jne .not_complement
			call evaluate_complement
			jmp .end
		.not_complement:
		
		.end:
	pop BX
	ret


; Performs an addition.
; The two operands should be in string_a, and string_b.
; The result ends up in token_space.
evaluate_addition:
	push EAX
	push EBX
	push ECX
	push ESI
	push EDI
		; 1. Convert both operands to numbers.
		mov ESI, string_b
		call convert_bin_str_number
		mov EBX, EAX
		
		mov ESI, string_a
		call convert_bin_str_number
		
		; Now EAX = first operand
		; Now EBX = second operand
		
		; 2. Add numbers.
		mov ECX, EAX
		add ECX, EBX
		
		; 3. Convert result to binary number string (store it in token_space).
		push EAX
			mov EAX, ECX
			mov EDI, token_space
			call convert_number_bin_str
		pop EAX
	pop EDI
	pop ESI
	pop ECX
	pop EBX
	pop EAX
	ret


; Performs an subtraction.
; The two operands should be in string_a, and string_b.
; The result ends up in token_space.
evaluate_subtraction:
	push EAX
	push EBX
	push ECX
	push ESI
	push EDI
		; 1. Convert both operands to numbers.
		mov ESI, string_b
		call convert_bin_str_number
		mov EBX, EAX
		
		mov ESI, string_a
		call convert_bin_str_number
		
		; Now EAX = first operand
		; Now EBX = second operand
		
		; 2. Subtract numbers.
		mov ECX, EAX
		sub ECX, EBX
		; TODO: Check overflow.
		
		; 3. Convert result to binary number string (store it in token_space).
		push EAX
			mov EAX, ECX
			mov EDI, token_space
			call convert_number_bin_str
		pop EAX
	pop EDI
	pop ESI
	pop ECX
	pop EBX
	pop EAX
	ret


; Performs an multiplication.
; The two operands should be in string_a, and string_b.
; The result ends up in token_space.
evaluate_multiplication:
	push EAX
	push EBX
	push EDX
	push ESI
	push EDI
		; 1. Convert both operands to numbers.
		mov ESI, string_b
		call convert_bin_str_number
		mov EBX, EAX
		
		mov ESI, string_a
		call convert_bin_str_number
		
		; Now EAX = first operand
		; Now EBX = second operand
		
		; 2. Multiply numbers.
		xor EDX, EDX
		mul EBX
		
		; Now EDX:EAX = result of multiplication.
		
		; TODO: Handle negative numbers.
		
		; 3. Convert result to binary number string (store it in token_space).
		mov EDI, token_space
		call convert_number_bin_str
	pop EDI
	pop ESI
	pop EDX
	pop EBX
	pop EAX
	ret


; Performs an division.
; The two operands should be in string_a, and string_b.
; The result ends up in token_space.
evaluate_division:
	push EAX
	push EBX
	push EDX
	push ESI
	push EDI
		; 1. Convert both operands to numbers.
		mov ESI, string_b
		call convert_bin_str_number
		mov EBX, EAX
		
		mov ESI, string_a
		call convert_bin_str_number
		
		; Now EAX = first operand
		; Now EBX = second operand
		
		; Check that second operand is not zero.
		cmp EBX, 0
		jne .not_zero
			mov byte [error_code], ERROR_DIVISION_BY_ZERO
			jmp .end
		.not_zero:
		
		; 2. Divide numbers.
		xor EDX, EDX
		div EBX
		
		; Now EAX = Quotient
		; Now EDX = Remainder
		
		; TODO: Handle negative numbers.
		
		; 3. Convert result to binary number string (store it in token_space).
		mov EDI, token_space
		call convert_number_bin_str
		
		.end:
	pop EDI
	pop ESI
	pop EDX
	pop EBX
	pop EAX
	ret


; Performs an complement operation.
; The operand should be in string_a.
; The result ends up in token_space.
evaluate_complement:
	push ESI
	push EDI
	push EAX
		; 1. Convert operand to number.
		mov ESI, string_a
		call convert_bin_str_number
		
		; Now EAX = first operand
		
		; 2. Invert number.
		not EAX
		
		; 3. Add 1 to the number.
		inc EAX
		
		; 4. Convert result to binary number string (store it in token_space).
		mov EDI, token_space
		call convert_number_bin_str
	pop EAX
	pop EDI
	pop ESI
	ret


; Returns in AL how many operands does the operation takes (1 if operation is ~, 2 otherwise).
get_operation_operands:
	cmp byte [token_space], COMPLEMENT_CHAR
	jne .not_complement
	
		; Is complement, return 1.
		mov AL, 1
		jmp .return
		
	.not_complement:
	
	; Return 2 if it's not complement.
	mov AL, 2
	
	.return:
	ret

