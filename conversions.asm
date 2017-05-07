

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
		; Just copy the token
		mov ESI, token_space
		mov EDI, string_a
		call clone_string_into_update_edi
		
		; Add "bin" to the result
		mov ESI, binary_base_identifier
		call clone_string_into_update_edi
	pop EDI
	pop ESI
	ret


; This method converts the string at token_space which should be
; a valid hexadecimal number, into a binary string number.
; The result is stored in string_a.
token_hex_bin:
	push ESI
	push EDI
		; Write the bits to string_a
		mov EDI, string_a
	
		; Expand every character in token_space as being a hex digit
		mov ESI, token_space
		
		.cycle:
			cmp byte [ESI], 0
			je .done
			
			call expand_hex_digit
			
			inc ESI
			jmp .cycle
			
		.done:
			; Put "hex" at the end of string_a
			mov ESI, hexadecimal_base_identifier
			call clone_string_into_update_edi
	pop ESI
	pop EDI
	ret


; This method converts the string at token_space which should be
; a valid octal number, into a binary string number.
; The result is stored in string_a.
token_oct_bin:
	push ESI
	push EDI
		; Write the bits to string_a
		mov EDI, string_a
	
		; Expand every character in token_space as being a hex digit
		mov ESI, token_space
		
		.cycle:
			cmp byte [ESI], 0
			je .done
			
			call expand_oct_digit
			
			inc ESI
			jmp .cycle
			
		.done:
	pop EDI
	pop ESI
	ret


; This method expands the character pointed at by ESI which should be
; a valid octal digit into it's binary equivalent.
; It modifies EDI to point to the byte after the last bit that was written.
expand_oct_digit:
	push AX
		mov AL, byte [ESI]
		
		cmp AL, '0'
		jae .above_zero
		jmp .below_zero
		
		.above_zero:
			cmp AL, '7'
			jbe .under_seven
			jmp .above_seven
		
		.under_seven:
			; It's one of "01234567"
			sub AL, '0'
			call write_last_three_bits
			jmp .end
	
		.below_zero:
		.above_seven:
			; It's not a valid oct digit
			; Ignore it.
		
		.end:
	pop AX
	ret


; This method expands the character pointed at by ESI which should be
; a valid hexadecimal number into it's binary equivalent.
; It modifies EDI to point to the byte after the last bit that was written.
expand_hex_digit:
	push AX
		mov AL, byte [ESI]
		
		cmp AL, '0'
		jae .above_zero
		jmp .below_zero
		
		.above_zero:
			cmp AL, '9'
			jbe .under_nine
			
			; It's over 9
			
			cmp AL, 'A'
			jae .above_a
			
		.above_a:
			cmp AL, 'F'
			jbe .under_f
			jmp .above_f
		
		.under_f:
			; It's one of "ABCDEF"
			sub AL, 'A'
			add AL, 10 ; Make up for the subtraction of 'A'
			call write_last_four_bits
			jmp .end
		
		.under_nine:
			; It's one of "0123456789"
			sub AL, '0'
			call write_last_four_bits
			jmp .end
	
		.below_zero:
		.above_f:
			; It's not a valid hex digit
			; Ignore it.
			jmp .end
		
		.end:
	pop AX
	ret


; Writes the last four bits of the number at AL into the bytes
; pointed at by EDI. Updates EDI to point to the next byte after
; the four bits are written.
write_last_four_bits:
	push ECX
		mov ECX, 4 ; Print 4 bits
		call write_n_bits
	pop ECX
	ret


; Writes the last three bits of the number at AL into the bytes
; pointed at by EDI. Updates EDI to point to the next byte after
; the three bits are written.
write_last_three_bits:
	push ECX
		mov ECX, 3 ; Print 3 bits
		call write_n_bits
	pop ECX
	ret


; Rotates AL n (stored in ECX) times, writing each bit rotated into the bytes pointed at by
; EDI. Updates EDI.
write_n_bits:
	push ECX
	push AX
		.bit_cycle:
			ror AL, 1 ; Move next bit into carry flag
			call write_carry_bit
			loop .bit_cycle
	pop AX
	pop ECX
	ret


; Writes the carry bit into the EDI byte.
write_carry_bit:
	jc .write_one
		mov byte [EDI], OFF_BIT_CHAR
		inc EDI
		jmp .end
			
	.write_one:
		mov byte [EDI], ON_BIT_CHAR
		inc EDI
	
	.end:
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

