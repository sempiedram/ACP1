

; This method converts any valid numbers in user_input to binary.
convert_numbers_to_binary:
	push ESI
	push EDI
		mov ESI, user_input
		mov EDI, user_input_swap
		
		; for every token in user_input {
		.cycle:
		call get_next_token
		cmp byte [token_space], 0
		je .no_more_tokens
		
			; if token is number {
			call is_token_valid_number
			jne .not_number
			
				; convert token to binary
				; call convert_token_to_binary
				; Now: string_a = number converted
				
				; copy result into user_input_swap
				push ESI ; Save ESI
					mov ESI, string_a
					call clone_string_into_update_edi
				pop ESI
				
				jmp .cycle
			; }else {
			.not_number:
			
				; copy token into user_input_swap
				push ESI
					mov ESI, token_space
					call clone_string_into_update_edi
				pop ESI
				
				jmp .cycle
			; }
			
		; }
		.no_more_tokens:
	pop EDI
	pop ESI
	ret


; Checks if token_space is a valid number.
is_token_valid_number:
		; check that token has more than 3 characters
		; check that last three characters are a valid base
		; for every character behind the base {
			; if character is a valid digit in base {
				; continue with next character
			; }else {
				; return false
			; }
		; }
		; ; Every character has been checked.
		; return true
	ret

