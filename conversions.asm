

convert_numbers_to_binary:
		; for every token in user_input {
			; if token is number {
				; convert token to binary
				; copy result into user_input_swap
			; }else {
				; copy token into user_input_swap
			; }
		; }
	ret


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

