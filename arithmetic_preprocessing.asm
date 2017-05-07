

; Adds base indicator to numbers that don't have it.
; Adds base result indicator to expressions that don't have it.
arithmetic_preprocessing:
	call add_base_indicators
	call add_result_base_indicator
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
	push EAX
	push EBX
	push ECX
	push EDX
	push ESI
		; look for '=' token
		mov AL, RESULT_BASE_INDICATOR_CHAR
		mov EBX, user_input
		call find_character_position
		; Now '=''s position in user_input is in ECX, or ECX = -1 if it was not found.
		
		; if there is one {
		mov EDX, ECX ; Save first '='s position.
		cmp ECX, -1
		je .no_base_indicator
		
			; if there is two '=' {
			mov EBX, ECX ; Ignore the current '='
			inc EBX
			call find_character_position
			
			
			cmp ECX, -1
			je .not_two
			
				; raise error
				mov byte [error_code], ERROR_INVALID_EXPRESSION
				mov byte [error_reason], REASON_MULTIPLE_RESULT_BASE
				
				jmp .end
			; }else {
			.not_two:
			
				; if there are no tokens after '=' {
				mov ESI, EDX ; ESI = position of '='
				inc ESI ; Ignore the '='
				call get_next_token ; Should be the base.
				cmp byte [token_space], 0
				jne .more_tokens
				
					; raise error
					mov byte [error_code], ERROR_INVALID_EXPRESSION
					mov byte [error_reason], REASON_NOT_ENOUGH_TOKENS
					mov dword [error_extra_info2], token_space
					
					jmp .end
				; }else {
				.more_tokens:
				
					; if more than one tokens after '=' {
					call get_next_token
					cmp byte [token_space], 0
					je .no_more_tokens
					
						; raise error
						mov byte [error_code], REASON_TOO_MANY_AFTER
						mov dword [error_extra_info2], EDX
						
						jmp .end
					; }else {
					.no_more_tokens:
					
						; if token is valid base {
						mov ESI, EDX ; ESI = position of '='
						inc ESI ; Ignore the '='
						call get_next_token ; Should be base.
						
						; Get base from token_space:
						mov ESI, token_space
						call get_base_from_string
						; Now AL = 0 (invalid), 2, 8, 10, or 16
						
						cmp AL, 0 ; If not valid.
						je .not_valid_base
						
							; end
							; There is a valid base result indicator.
							jmp .end
							
						; }else {
						.not_valid_base:
						
							; raise error
							mov byte [error_code], ERROR_INVALID_BASE
							mov dword [error_extra_info2], token_space
							
							jmp .end
						; }
						
					; }
					
				; }
				
			; }
			
		; }else {
		.no_base_indicator:
		
			; add " = dec" to the expression
			
			push ESI
			push EDI
			
				; This finds the end of user_input
				mov ESI, user_input
				call find_next_zero_esi
				mov EDI, ESI
				
				; This appends default_base_result_indicator to user_input
				mov ESI, default_base_result_indicator
				call clone_string_into
			
			pop EDI
			pop ESI
			
		; }
		
		.end:
	pop ESI
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	ret


