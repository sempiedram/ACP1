

%include  "io.mac"


; equ definitions:
	; This (minus one) is the size limit for the user_input string:
    INPUT_LIMIT equ 1024
	
	; Characters:
		; Space character:
		SPACE_CHAR equ ' '
	
	; Error codes:
		USER_INPUT_SWAP_NO_SPACE equ 1


.DATA
	; This is the string used as prompt for the next operation:
    cmd_prompt: db "::> ", 0
	
	; Strings for messages:
		; This string is showed at the end of the program execution:
		finish_msg: db "Bye!", 0
		
		; Strings for the processing method:
		processing_op: db "Processing: '", 0
		processing_op2: db "'.", 0
		
		; Strings for the preprocessing method:
		preprocessed_msg: db "Preprocessed: '", 0
		preprocessed_msg2: db "'.", 0
	
	; This is the string space for user input
    user_input: times INPUT_LIMIT db 0
    user_input_swap: times INPUT_LIMIT db 0
	
	; This byte is either 0, or 1. 0 means that the program should stop, and 1 that it should continue. It's checked every cycle to see if the program should stop.
    running: db 0
	
	; This byte is used to check if there was an error (0 means no error):
    error_code: db 0

    ; Commands (that start with #) recognized:
    CMD_EXIT: db "exit", 0
    CMD_VARS: db "vars", 0
    CMD_ABOUT: db "about", 0
	
	; Sets of characters:
		; Characters that are expanded with spaces:
		spaces_chars: db "+-*/()=:", 0


; Main method:
.CODE
    .STARTUP
		; This is the main cycle of:
		; 	1. get input
		; 	2. process input
		; 	3. check if still running
		
		.read_cmd:
			; Primpt the command prompt
			PutStr cmd_prompt
			
			; Get the input string
			GetStr user_input, INPUT_LIMIT
			
			; Process user_input
			call process_input

			; Check if there needs to be another cycle.
			cmp byte [running], 0
			je .read_cmd

		; Print the end message:
        nwln
        PutStr finish_msg
        nwln
    .EXIT


; This method processes the user_input string.
process_input:
    ; Print "Processing: '<user_input>'"
    PutStr processing_op
    PutStr user_input
    PutStr processing_op2
    nwln
	
	call preprocess
    
    ; Print "Preprocessed: '<user_input preprocessed>'"
    PutStr preprocessed_msg
    PutStr user_input
    PutStr preprocessed_msg2
    nwln
	
	ret


; This method preprocesses user_input string.
preprocess:
	; Insert extra spaces:
	call preprocess_insert_spaces
	
	; Remove repeated strings:
	call preprocess_remove_repeated_spaces
	
	; Strip end and beginning spaces:
	call strip_user_input
    ret


; This method introduces spaces around characters which return true when tested with space_test_character; this is intended to be used for operations, for example '+++' expands to ' +  +  + '.
preprocess_insert_spaces:
    call clone_user_input
    
    pushad
        mov EAX, user_input
        mov ECX, user_input_swap
        
        .cycle:
            mov BL, byte [EAX]
            
            ; Stop at the first 0.
            cmp BL, 0
            je .done
            
            ; Test char in BL:
            call space_test_character
            jnc .not_expand_spaces
            
            ; Save character surrounded by spaces.
                mov byte [ECX], SPACE_CHAR
                inc ECX
                mov byte [ECX], BL
                inc ECX
                mov byte [ECX], SPACE_CHAR
                inc ECX
                jmp .update_eax
            
            .not_expand_spaces:
                ; Only save the character.
                mov byte [ECX], BL
                inc ECX
                
            .update_eax:
                inc EAX
            
            ; Check that EAX is not pointing outside of user_input
            mov EDX, user_input
            add EDX, INPUT_LIMIT
            cmp EAX, EDX
            ja .done
            
            ; Check that ECX is not pointing outside of user_input_swap
            mov EDX, user_input_swap
            add EDX, INPUT_LIMIT
            cmp ECX, EDX
            ja .no_more_space ; There's no more space in user_input_swap.
            
            jmp .cycle
        
        .no_more_space:
            mov byte [error_code], USER_INPUT_SWAP_NO_SPACE
            jmp .end
            
        .done:
            ; Mark the string's end.
            mov byte [ECX], 0
            
        .end:
    popad
    
    call restore_user_input
    
    ret


; Removes repeated spaces in user_input.
preprocess_remove_repeated_spaces:
    pushf
    pushad
		; This section copies user_input onto user_input_swap removing spaces:
        mov AL, 0
        mov EBX, user_input
        mov ECX, user_input_swap

        .cycle:
            mov AH, byte [EBX]
            
            cmp AH, 0
            jne .inside_string
                mov byte [ECX], 0
                jmp .end
            .inside_string:
            
            cmp AH, SPACE_CHAR
            je .was_space
                mov byte [ECX], AH
                inc ECX
                mov AL, 0
                jmp .after
            .was_space:
                cmp AL, 1
                mov AL, 1
                je .previous_was_space
                    mov byte [ECX], AH
                    inc ECX
                    jmp .after
                .previous_was_space:
            .after:
            
            inc EBX
            jmp .cycle
        
        .end:
        
    ; This section copies the result from user_input_swap onto user_input:
        call restore_user_input
    popad
    popf
    ret


strip_user_input:
    call strip_beginning_user_input
    call strip_end_user_input
    ret


strip_beginning_user_input:
    pushad
        ; Find the first non-space:
        
        ; Start at user_input.
        mov EAX, user_input
        
        ; Put in EBX the user_input string end.
        mov EBX, user_input
        add EBX, INPUT_LIMIT
        
        .space:
            ; Stop at first non-space:
            cmp byte [EAX], SPACE_CHAR
            jne .not_space
            
            ; Stop at the string end:
            cmp EAX, EBX
            jae .end_of_string
            
            inc EAX
            jmp .space
        
        .end_of_string:
            mov EAX, user_input
        
        .not_space:
        mov EBX, EAX
        mov EAX, user_input
        
        ; EBX is now pointing to the first non-space character in user_input
        ;   or to the beginning of the string.
        
        ; Put in EBX the user_input string end.
        mov ECX, user_input
        add ECX, INPUT_LIMIT
        
        .shift_chars:
            ; Stop at the end of the string.
            cmp EAX, ECX
            jae .out_of_string
            
            ; It's inside the string.
            
            ; Check current character in EAX.
            cmp byte [EAX], 0
            je .done_shifting
            
            ; Move a byte from EBX to EAX
            mov DL, byte [EBX]
            mov byte [EAX], DL
            
            inc EAX
            inc EBX
            jmp .shift_chars
        
        .out_of_string:
        .done_shifting:
            ; Done.
    popad
    ret

; 
strip_end_user_input:
    pushad
        mov EAX, user_input
        .scan_string_end:
            cmp byte [EAX], 0
            je .at_end
            inc EAX
            jmp .scan_string_end
        
        .at_end:
            dec EAX
            
        .substitute_spaces:
            ; Stop at beginning of string.
            cmp EAX, user_input
            jb .before_start_of_string
            
            ; Stop at first non space.
            cmp byte [EAX], SPACE_CHAR
            jne .not_space
            
            ; Substitute space with a zero.
            mov byte [EAX], 0
            dec EAX
            jmp .substitute_spaces
        
        .before_start_of_string:
        .not_space:
            ; Trailing spaces have been replaced.
    popad
    ret

; This method tests the character at BL to see if spaces should be inserted around it.
; Affects: CF, 0 if not, 1 if yes
; Input: BL, character to test.
space_test_character:
    push BX
    push EAX
        cmp BL, 0
        je .ebx_is_zero
        
        mov EAX, spaces_chars
        
        .cycle:
            ; Stop if reached the end of spaces_chars:
            cmp byte [EAX], 0
            je .not_found
            
            cmp BL, byte [EAX]
            je .found_char
            
            inc EAX
            jmp .cycle
        
        .ebx_is_zero:
            ; It's an invalid char, return false.
            clc
            jmp .end
        
         ; Return true.
        .found_char:
            stc
            jmp .end
        
         ; Return false.
        .not_found:
            clc
            jmp .end
        
        .end:
    pop EAX
    pop BX
    ret


; Copies user_input_swap string onto user_input.
restore_user_input:
    push EAX
    push EBX
    push CX
        ; Start at user_input, and user_input_swap.
        mov EAX, user_input_swap
        mov EBX, user_input
        
        ; Copy bytes:
        .cycle:
            mov EDX, user_input_swap
            add EDX, INPUT_LIMIT
            cmp EAX, EDX
            ja .done ; Check if we reached the end of the string.
            
            ; Copy next byte:
            mov CL, byte [EAX]
            mov byte [EBX], CL
            
            ; Stop at the first 0.
            cmp CL, 0
            je .done
            
            ; Update addresses.
            inc EAX
            inc EBX
            jmp .cycle
        .done:
            ; user_input_swap string was copied to user_input
    pop CX
    pop EBX
    pop EAX
    ret


; This method clones the string at user_input onto user_input_swap.
clone_user_input:
    pushad
        ; Start at user_input, and user_input_swap.
        mov EAX, user_input
        mov EBX, user_input_swap
        
        ; Copy bytes:
        .cycle:
            mov EDX, user_input
            add EDX, INPUT_LIMIT
            cmp EAX, EDX
            ja .done ; Check if we reached the end of the string.
            
            ; Copy next byte:
            mov CL, byte [EAX]
            mov byte [EBX], CL
            
            ; Stop at the first 0.
            cmp CL, 0
            je .done
            
            ; Update addresses.
            inc EAX
            inc EBX
            jmp .cycle
        .done:
            ; user_input string was copied to user_input_swap
    popad
    ret


; Check if the string at EDI is equal to the string at ESI. The main string is ESI.
compare_strings:
	push ESI
	push EDI
	push EAX
		; This is the byte comparison.
		.cycle:
			mov AL, byte [ESI]
			cmp AL, byte [EDI]
			jne .not_equal
				; Characters were equal:
				cmp AL, 0
				
				; If the bytes were 0, return true, else continue with the next cycle.
				jne .next_cycle
					; The end of the strings have been reached.
					; Return true:
					; Zero flag is already 1
					jmp .done
			.not_equal:
				; Return false:
				; Zero flag is already 0
				jmp .done
			
			.next_cycle:
				inc ESI
				inc EDI
				jmp .cycle
			; End of .cycle
		
		.done:
	pop EAX
	pop EDI
	pop ESI
	ret

