


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
				
				jmp .next_cycle
			; }else {
			.not_number:
			
				; copy token into user_input_swap
				push ESI
					mov ESI, token_space
					call clone_string_into_update_edi
				pop ESI
				
				jmp .next_cycle
			; }
			
			.next_cycle:
				; Write a separator space
				mov byte [EDI], SPACE_CHAR
				inc EDI
				jmp .cycle
			
		; }
		.no_more_tokens:
			; If something was written, there's an extra space
			; Remove it.
			cmp EDI, user_input_swap
			je .did_nothing
				dec EDI ; Position of the space.
				mov byte [EDI], 0
			.did_nothing:
			
			call restore_user_input
	pop EDI
	pop ESI
	ret



; This method converts the final result, which should be stored in string_a,
; from a binary string into the base that the user specified, which should be stored
; in the result_base byte (as 2, 8, 10, or 16).
; The result ends up in string_b.
convert_final_result:
	push AX
		; Test the result_base byte.

		mov AL, byte [result_base]

		cmp AL, 2
		jne .not_binary
			call string_a_bin_bin
			jmp .end
		.not_binary:

		cmp AL, 8
		jne .not_octal
			call string_a_bin_oct
			jmp .end
		.not_octal:

		cmp AL, 10
		jne .not_decimal
			call string_a_bin_dec
			jmp .end
		.not_decimal:

		cmp AL, 16
			call string_a_bin_hex
			jmp .end
		.not_hexadecimal:

		; It's not a valid base, for now, just copy the token
		; as the result.

		mov ESI, string_a
		mov EDI, string_b
		call clone_string_into

		.end:
	pop AX
	ret


; Converts the string at string_a from binary to binary.
; The result ends up in string_b.
string_a_bin_bin:
	push ESI
	push EDI
		; Just copy string_a to string_b

		mov ESI, string_a
		mov EDI, string_b
		call clone_string_into
	pop EDI
	pop ESI
	ret


; Converts the string at string_a from binary to octal.
; The result ends up in string_b.
string_a_bin_oct:
	push ESI
	push EAX
	push BX
	push EDI
		; The algorithm is:

		; 1. Convert the string to a number:
		mov ESI, string_a
		call convert_bin_str_number
		; Now EAX = value of number

		; 2. Convert number to base (string)
		mov BL, 8 ; base to convert to 
		mov EDI, string_b ; Where to write the number.
		call convert_number_to_base
		
		; 3. Add "oct" base identifier
		mov ESI, octal_base_identifier
		call clone_string_into
		.not_binary:
	pop EDI
	pop BX
	pop EAX
	pop ESI
	ret


; Converts the string at string_a from binary to decimal.
; The result ends up in string_b.
string_a_bin_dec:
	push ESI
	push EAX
	push BX
	push EDI
		; The algorithm is:

		; 1. Convert the string to a number:
		mov ESI, string_a
		call convert_bin_str_number
		; Now EAX = value of number

		; 2. Convert number to base (string)
		mov BL, 10 ; base to convert to 
		mov EDI, string_b ; Where to write the number.
		call convert_number_to_base
		
		; 3. Add "dec" base identifier
		mov ESI, decimal_base_identifier
		call clone_string_into
		.not_binary:
	pop EDI
	pop BX
	pop EAX
	pop ESI
	ret


; Converts the string at string_a from binary to hexadecimal.
; The result ends up in string_b.
string_a_bin_hex:
	push ESI
	push EAX
	push BX
	push EDI
		; The algorithm is:

		; 1. Convert the string to a number:
		mov ESI, string_a
		call convert_bin_str_number
		; Now EAX = value of number

		; 2. Convert number to base (string)
		mov BL, 16 ; base to convert to 
		mov EDI, string_b ; Where to write the number.
		call convert_number_to_base
		
		; 3. Add "hex" base identifier
		mov ESI, hexadecimal_base_identifier
		call clone_string_into
		.not_binary:
	pop EDI
	pop BX
	pop EAX
	pop ESI
	ret



; This method should convert a number (stored in the EAX register) to
; a string (stored at EDI) in the base indicated by BL.
; No base identifier is added at the end of the string (no "bin", "oct", etc).
; EDI is modified, it ends pointing to the character after the last digit.
convert_number_to_base:
	push ESI
	push EAX
	push EBX
	push ECX
	push EDX
		; Divide the number continuously until the result is zero.
		; After each division, convert the remainder to the
		;   correct digit.
		; Add each digit to the result.

		mov byte [EDI], '0' ; Add an initial 0 to the result.
		inc EDI

		; Save EDI for reversing the digits:
		mov ECX, EDI

		; For division, EBX must contain only the base:
		xor EDX, EDX ; EDX = 0
		mov DL, BL ; EDX = base
		mov EBX, EDX ; EBX = base

		.cycle:
			; To divide, EDX must be clear:
			xor EDX, EDX ; EDX = 0
			
			div EBX

			; Now EAX = Quotient
			; And EDX = Remainder (= DL)

			; Write the digit:
			call number_to_digit ; Converts number -> digit (in DL)
			; Now DL = new digit
			mov byte [EDI], DL
			inc EDI

			; Check if quotient is zero (conversion ended)
			cmp EAX, 0
			je .quotient_zero
			
			jmp .cycle

		.quotient_zero:
			; Now EAX is zero -> conversion ended.
			
			; Close the current result string.
			mov byte [EDI], 0

			; The digits will be reversed because of the algorithm.
			; Reverse them back:
			mov ESI, ECX
			call reverse_string
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop ESI
	ret


; This method converts the number stored at DL into a digit character
; and stores it in DL (so the original number is overwritten).
; If the number doesn't have a corresponding character, it doesn't
; modify DL.
number_to_digit:
	cmp DL, 9
	ja .higher_nine
		; It's from 0 to 9
		add DL, '0' ; Map from 0 -> '0', 9 -> '9'
		jmp .return
	.higher_nine:
		; It's from 10 -> 255
		sub DL, 10 ; Map from 10 -> 0, 11 -> 1, etc.
		add DL, 'A' ; Map from 0 -> 'A', 1 -> 'B', etc.

		; If the result is above 'Z' it's not a valid digit, reverse it.
		cmp DL, 'Z'
		jbe .return

		sub DL, 'A' ; Reverse DL to original value
	
	.return:
	ret


; Converts token_space's string to binary.
; Assumes that token_space is a valid number.
; Result: string_a, number converted to binary
convert_token_to_binary:
	push ESI
	push EDI
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
	pop EDI
	pop ESI
	ret



; This method converts the string at token_space into binary.
; The result is stored in string_a.
token_dec_bin:
	push EAX
		; 1. Convert token_space to a number
		call convert_dec_number
		
		; 2. Convert number to binary
		call convert_number_bin
	pop EAX
	ret



; This method converts the number in EAX to a binary number string in string_a.
convert_number_bin:
	push EDI
	push ESI
	push BX
		mov BL, 2 ; Convert to binary
		mov EDI, string_a ; Set destiny to string_a
		call convert_number_to_base

		; Write the "bin" part of the result.
		mov ESI, binary_base_identifier
		call clone_string_into
	pop BX
	pop ESI
	pop EDI
	ret



; Converts the decimal number string at token_space into a number
; and returns that in the EAX register.
convert_dec_number:
	push ESI
	push EBX
	push EDX
		; Result = EAX
		xor EAX, EAX
		mov ESI, token_space
		
		.cycle:
			; Next byte:
			xor EBX, EBX ; EBX = 0
			mov BL, byte [ESI]
			
			; Stop at first 0
			cmp BL, 0
			je .done_cycle
			
			; Get next digit's value:
			sub BL, '0'
			
			add EAX, EBX
			mov EBX, 10
			mul EBX
			
			; point to next byte
			inc ESI
			jmp .cycle
		
		.done_cycle:
			mov EBX, 10
			div EBX
	pop EDX
	pop EBX
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
		
		; Write first zero:
		mov byte [EDI], OFF_BIT_CHAR
		inc EDI
	
		; Expand every character in token_space as being a hex digit
		mov ESI, token_space
		
		.cycle:
			cmp byte [ESI], 0
			je .done
			
			call expand_hex_digit
			
			inc ESI
			jmp .cycle
			
		.done:
			; Put "bin" at the end of string_a
			mov ESI, binary_base_identifier
			call clone_string_into_update_edi
	pop EDI
	pop ESI
	ret



; This method converts the string at token_space which should be
; a valid octal number, into a binary string number.
; The result is stored in string_a.
token_oct_bin:
	push ESI
	push EDI
		
		; Write the bits to string_a
		mov EDI, string_a
		
		; Write first zero:
		mov byte [EDI], OFF_BIT_CHAR
		inc EDI
	
		; Expand every character in token_space as being a hex digit
		mov ESI, token_space
		
		.cycle:
			cmp byte [ESI], 0
			je .done
			
			call expand_oct_digit
			
			inc ESI
			jmp .cycle
			
		.done:
			; Put "bin" at the end of string_a
			mov ESI, binary_base_identifier
			call clone_string_into_update_edi
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
			jmp .below_a
			
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
		.below_a:
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
		ror AL, CL
		.bit_cycle:
			rol AL, 1 ; Move next bit into carry flag
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
		mov EAX, token_space
		call get_string_length
		; EBX = token length
		
		cmp EBX, 3
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
		.cycle:
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
	push EAX
	push EBX
	push ECX
	push EDX
		; Address of where to look for the character:
		mov ECX, digits_chars
		
		; Limit of digits:
		mov EBX, digits_chars
		
		push ECX
			xor ECX, ECX ; ECX = 0
			mov CL, AL
			
			add EBX, ECX
		pop ECX
		
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
	pop EAX
	ret



; Converts the string at ESI (assuming that it's a binary number, e.g: 1101bin, 0110bin) into a number.
; The result is returned in EAX.
convert_bin_str_number:
	push ESI
	push EBX
	push ECX
		push ESI
			; Remove "bin" from number.
			call find_next_zero_esi
			dec ESI
			dec ESI
			dec ESI
			mov byte [ESI], 0
		pop ESI
		
		; Keep count of number of bits in CX.
		; CX = 0
		xor CX, CX
		
		; Result = EAX = 0
		xor EAX, EAX
		
		cmp byte [ESI], OFF_BIT_CHAR
		je .first_was_zero
			; First bit was one
			not EAX ; Invert all bits initially
		.first_was_zero:
		
		; Scan the token:
		.cycle:
			; Get next character
			mov BL, byte [ESI]
			
			; Check end of token:
			cmp BL, 0
			je .bits_done
			
			; Check if it's a bit:
			cmp BL, OFF_BIT_CHAR
			jne .not_zero
				; Is zero
				inc CX ; Increase count
				
				rol EAX, 1 ; Write a 0
				and EAX, 0xFFFFFFFE ; Mask last bit off
				jmp .next_character
			.not_zero:
			
			cmp BL, ON_BIT_CHAR
			jne .not_one
				; Is one
				inc CX ; Increase count
				
				; Write a 1 :
				rol EAX, 1
				or EAX, 1 ; Mask last bit on
				jmp .next_character
			.not_one:
			
			; It's not recognized.
			
			.next_character:
			inc ESI
			
			cmp CX, 32
			ja .too_many_bits
			
			jmp .cycle
			
		.too_many_bits:
			; TODO: Handle when there are too many bits.
		.bits_done:
			; call find_next_zero_esi ; Restore the b of bin
			; mov byte [ESI], 'b'
	pop ECX
	pop EBX
	pop ESI
	ret



; Converts the number in EAX into a binary string.
; The result is written in the string at EDI.
; 00000000000000000000000000001011 -> 00000000000000000000000000001011bin
; 11111111111111110101011011101110 -> 11111111111111110101011011101110bin
convert_number_bin_str:
	push ESI
	push ECX
	
		; The algorithm is to rotate the 32 bits, writing each bit
		; into the string. At the end, "bin" is added to the string.
		
		mov ECX, 32 ; To loop/roll 32 bits.
		
		.cycle:
			rol EAX, 1
			jnc .was_zero
				; Write one:
				mov byte [EDI], ON_BIT_CHAR
				inc EDI
				jmp .next_bit
			.was_zero:
			; Write zero:
			mov byte [EDI], OFF_BIT_CHAR
			inc EDI
			
			.next_bit:
			loop .cycle
			
		; EAX should be unmodified now.
		
		; Write the "bin" part:
		mov ESI, binary_base_identifier
		call clone_string_into
		
	pop ECX
	pop ESI
	ret


