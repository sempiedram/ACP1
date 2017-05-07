

; This method evaluates the expression stored in expression_space.
; The final result ends up in string_a
; The algorithm is as follows:
evaluate_postfix:
		; if expression is empty {
			; return empty (clear string_a)
		; }

		; for token in expression {
			; if token is number {
				; push number to stack_space
			; }else {
				; ; Token should be an operator
				; if token is not operator {
					; raise error, invalid token(token_space)
				; }
				; operands to pop = get operation operands
				
				; save token ; because pop operantions write over it
				
				; if(operands to pop == 2) {
					; pop operand into string_b
					
					; ; Check that there are enough tokens for the evaluation.
					; if (no more operands) {
						; restore token ; restore saved operation token
						; raise error, invalid expression not enough operands (token_space)
					; }
				; }
				
				; pop operand into string_a
				
				; ; Check that there are enough tokens for the evaluation.
				; if (no more operands) {
					; restore token ; restore saved operation token
					; raise error, invalid expression not enough operands (token_space)
				; }
				
				; restore token ; restore saved operation token
				
				; evaluate operation ; now token_space = result of operation
				
				; push token to stack_space
			; }
		; }

		; if stack has at least one token {
			; if stack has another token {
				; raise error, too many operands
			; }
			; copy that token into string_a
		; }else {
			; ; This should not be possible, check it anyway.
			; ; Could do -> raise error, no result
			; return empty (clear string_a)
		; }
	ret

