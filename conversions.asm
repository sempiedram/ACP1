

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
				call convert_token_to_binary
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


; Converts token_space's string to binary.
; Assumes that token_space is a valid number.
; Result: string_a, number converted to binary
convert_token_to_binary:
	push ESI
	push EAX
		mov ESI, token_space
		call find_next_zero_esi
		dec ESI
		dec ESI
		dec ESI ; ESI = start of token's base.
		
		call get_base_from_string
		; AL is now 2, 8, 10, or 16
		
		mov byte [ESI], 0 ; Cut token's base
		
		cmp AL, 2
		jne .not_binary
			call token_bin_bin
			jmp .end
		.not_binary:
		
		cmp AL, 8
		jne .not_octal
			call token_oct_bin
			jmp .end
		.not_octal:
		
		cmp AL, 10
		jne .not_decimal
			call token_dec_bin
			jmp .end
		.not_decimal:
		
		cmp AL, 16
		jne .not_hexadecimal
			call token_hex_bin
			jmp .end
		.not_hexadecimal:
		
		; It's not a valid base.
		; TODO: decide if an error should be raised here.
		
		.end:
	pop EAX
	pop ESI
	ret


; This method converts the string at token_space into binary.
; The result is stored in string_a.
token_bin_bin:
	push ESI
	push EDI
		mov ESI, token_space
		mov EDI, string_a
		call clone_string_into
	pop EDI
	pop ESI
	ret


; Checks if token_space is a valid number.
is_token_valid_number:
	push EAX
	push EBX
	push ECX
	push ESI
	push EDI
		; check that token has more than 3 characters
		mov EBX, token_space
		call get_string_length
		; ECX = token length
		
		cmp ECX, 3
		ja .more_than_three
			; Three or less characters.
			jmp .return_false
			
		.more_than_three:
		
		; check that last three characters are a valid base
		mov ESI, token_space
		call find_next_zero_esi ; ESI = token limit
		dec ESI
		dec ESI
		dec ESI ; ESI = start of token's supposed base
		
		mov EBX, ESI ; Save digits limit
		
		call get_base_from_string
		; Now AL = 0, 2, 8, 10, or 16
		cmp AL, 0
		jne .valid_base
			; The last three characters were not a valid base
			jmp .return_false
		.valid_base:
		
		mov ESI, token_space
		; for every character behind the base {
		cmp ESI, EBX
		jae .no_more_characters
		mov AH, byte [ESI] ; Get next character
		
			; if character is a valid digit in base {
			call is_valid_digit
			jne .return_false
			
				; continue with next character
				jmp .next_cycle
				
			; }else {
				; return false
			; }
			
		.next_cycle:
			inc ESI
			jmp .cycle
		; }
		
		.no_more_characters:
		
		; ; Every character has been checked.
		
		; return true
		xor AL, AL ; ZF = true
		jmp .end
		
		.return_false:
			xor AL, AL
			inc AL ; ZF = false
			jmp .end
		
		.end:
	pop EDI
	pop ESI
	pop ECX
	pop EBX
	pop EAX
	ret


; Expects the digit to be checked to be in AH, and the base (2, 8, 10, or 16) in AL.
; Returns true or false in ZF.
is_valid_digit:
	push EBX
	push ECX
	push EDX
		; Address of where to look for the character:
		mov ECX, digits_chars
		
		; Limit of digits:
		mov EBX, digits_chars
		add EBX, AH
		
		mov DL, byte [EBX] ; Save original byte
			mov byte [EBX], 0 ; Cut string
			
			push EBX
				mov BL, AH ; Moves digit being checked into BL
				call find_character ; Look for character
			pop EBX
		mov byte [EBX], DL ; Restore original byte
		
		jc .return_true
		jmp .return_false
	
		.return_true:
			xor AL, AL ; ZF = true
			jmp .end
	
		.return_false:
			xor AL, AL ; ZF = false
			inc AL
			jmp .end
		
		.end:
	pop EDX
	pop ECX
	pop EBX
	ret

