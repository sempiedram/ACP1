

; Adds base indicator to numbers that don't have it.
; Adds base result indicator to expressions that don't have it.
arithmetic_preprocessing:
	; call add_base_indicators
	; call add_result_base_indicator
	ret


add_base_indicators:
	; for token in user_input {
		; add token to user_input_swap
		
		; if token is valid decimal number {
			; add "dec" to user_input_swap
		; }
		
		; add space
	; }
	
	; copy user_input_swap into user_input
	
	; if user_input is not empty {
		; remove last space
	; }
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


