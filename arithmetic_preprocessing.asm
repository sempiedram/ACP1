

; Adds base indicator to numbers that don't have it.
; Adds base result indicator to expressions that don't have it.
arithmetic_preprocessing:
	call add_base_indicators
	; call add_result_base_indicator
	ret


add_base_indicators:
	push ESI
	push EDI
	
		; user_input will be scanned
		mov ESI, user_input
		
		; user_input_swap will be used to generate the new expression
		mov EDI, user_input_swap
		
		; Make sure that user_input_swap is empty initially.
		mov byte [user_input_swap], 0
		
		; for token in user_input {
		.cycle:
		call get_next_token
		cmp byte [token_space], 0
		je .cycle_done
		
			; add token to user_input_swap
			push ESI
				mov ESI, token_space
				call clone_string_into_update_edi
			pop ESI
			
			; if token is valid decimal number {
			call is_token_decimal_number
			jne .not_decimal_number
			
				; add "dec" to user_input_swap
				push ESI
					mov ESI, decimal_base_identifier
					call clone_string_into_update_edi
				pop ESI
				
			; }
			.not_decimal_number:
			
			; add space
			mov byte [EDI], SPACE_CHAR
			inc EDI
			
			jmp .cycle
		; }
		.cycle_done:
		
		; if user_input is not empty {
		cmp byte [user_input_swap], 0
		je .empty
		
			; remove last space
			dec EDI
			mov byte [EDI], 0
			
		; }
		.empty:
		
		; copy user_input_swap into user_input
		call restore_user_input
		
	pop EDI
	pop ESI
	ret


; Returns true only if the string at token_space is composed only
; of the characters "0123456789".
is_token_decimal_number:
	push ESI
	push EDI
		mov ESI, token_space
		mov EDI, decimal_digits_chars
		call is_string_composed_of
	pop EDI
	pop ESI
	ret


add_result_base_indicator:
	; look for '=' token
	; if there is one {
		; if there is two '=' {
			; raise error
		; }else {
			; if there are no tokens after '=' {
				; raise error
			; }else {
				; if more than one tokens after '=' {
					; raise error
				; }else {
					; if token is valid base {
						; end
					; }else {
						; raise error
					; }
				; }
			; }
		; }
	; }else {
		; add " = dec" to the expression
	; }
	ret


