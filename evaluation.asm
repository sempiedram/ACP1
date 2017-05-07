

; This method evaluates the expression stored in expression_space.
; The final result ends up in string_a
; The algorithm is as follows:
evaluate_postfix:
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
						mov EDI, string_a
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
			jne .two_tokens
			
				; raise error, too many operands
				mov byte [error_code], ERROR_INVALID_EXPRESSION
				mov byte [error_reason], REASON_TOO_MANY_OPERANDS
				jmp .return
				
			; }
			.two_tokens:
			
			; copy that token into string_a
			push ESI
			push EDI
				mov ESI, token_space
				mov EDI, string_a
				call clone_string_into
			pop EDI
			pop ESI
			
		; }else {
		.no_result:
		
			; ; This should not be possible, check it anyway.
			; ; Could do -> raise error, no result
			
			; return empty (clear string_a)
			mov byte [string_a], 0
			
			jmp .return
		; }
		
		.return:
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

