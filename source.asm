

%include  "io.mac"


; equ definitions:
	; This (minus one) is the size limit for the user_input string:
		INPUT_LIMIT equ 2048
		
	; General string spaces:
		STRING_SIZE equ 512
	
	; Characters:
		; Space character:
		SPACE_CHAR equ ' '

		; Command indicator character:
		COMMAND_CHAR equ '#'

		; Complement indicator character:
		COMPLEMENT_CHAR equ '~'

		; Variable definition indicator character:
		VARIABLE_DEF_CHAR equ ':'

		; Result base indicator character:
		RESULT_BASE_INDICATOR_CHAR equ '='
		
		; Parenthesis characters:
		OPEN_PARENTHESIS equ '('
		CLOSE_PARENTHESIS equ ')'

		; Operations:
		ADDITION_OPERATION_CHAR equ '+'
		SUBTRACTION_OPERATION_CHAR equ '-'
		MULTIPLICATION_OPERATION_CHAR equ '*'
		DIVISION_OPERATION_CHAR equ '/'

	; Error codes:
		USER_INPUT_SWAP_NO_SPACE equ 1
	
	; Categories' values:
		CATEGORY_ARITHMETIC equ 1
		CATEGORY_COMMAND equ 2
		CATEGORY_COMPLEMENT equ 4
		CATEGORY_VARIABLE equ 8
		CATEGORY_INVALID equ 16


.DATA
	; This is the string used as prompt for the next operation:
		cmd_prompt db "::> ", 0
	
	; Strings for messages:
		; This string is showed at the end of the program execution:
		finish_msg db "Bye!", 0
		
		; End of a message with string closing:
		str_close_string db "'.", 0
		
		; Strings for the processing method:
		processing_op db "Processing: '", 0
		
		; Strings for the preprocessing method:
		preprocessed_msg db "Preprocessed: '", 0
		
		; Strings for the process_command method:
		str_process_command db "Process command: '", 0
	
		; String for categories:
		category_info db "Operation category: ", 0
		; Category names:
		category_name_arithmetic db "arithmetic", 0
		category_name_command db "command", 0
		category_name_complement db "complement", 0
		category_name_variable db "variable definition", 0
		category_name_invalid db "invalid", 0
		
		; String to be printed when the #about command is used.
		about_string db \
			"Tecnologico de Costa Rica", 10,\
			"  - Escuela de Computación", 10,\
			"  - Arquitectura de Computadores", 10,\
			"  - Sede de Cartago", 10,\
			"  - Primer proyecto", 10, 10,\
			"  Profesor:", 10,\
			"    Esteban Arias", 10,\
			"  Grupo:", 10,\
			"    2", 10,\
			"  Estudiantes:", 10,\
			"    Kevin Sem Piedra Matamoros", 10,\
			"  Year:", 10,\
			"    2017", 10, 0
	
	; String memory spaces:
		; This is the string space for user input
		user_input times INPUT_LIMIT db 0
		; user_input_swap is a space used for performing operations over user_input
		user_input_swap times INPUT_LIMIT db 0
		
		; Strings for general use:
		string_a times STRING_SIZE db 0
		string_b times STRING_SIZE db 0
		
		; Space for token processing:
		token_space times STRING_SIZE db 0
	
	; This byte is either 0, or 1. 0 means that the program should stop, and 1 that it should continue. It's checked every cycle to see if the program should stop.
		running db 1
	
	; This byte is used to check if there was an error (0 means no error):
		error_code db 0
	
	; This byte holds the category computed by the check_category method:
		category db 0

    ; Commands (that start with #) recognized:
		cmd_exit db "exit", 0
		cmd_vars db "vars", 0
		cmd_about db "about", 0
	
	; Base strings:
		binary_base_identifier db "bin", 0
		octal_base_identifier db "oct", 0
		decimal_base_identifier db "dec", 0
		hexadecimal_base_identifier db "hex", 0
	
	; Sets of characters:
	; These sets can be used to classify strings.
		; Characters that are expanded with spaces:
		spaces_chars db "+-*/()=:#", 0
		
		; Characters for variable names:
		variable_names_chars db "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
		
		; Valid digit characters:
		digits_chars db "0123456789ABCDEF", 0
		
		; Decimal digit characters:
		decimal_digits_chars db "0123456789", 0
		
		; Valid number characters:
		number_chars db "0123456789ABCDEFbcdehinotx", 0
		
		; Base indentifier characters:
		base_identifier_chars db "bcdehinotx", 0

		; Characters for arithmetic expressions:
		arithmetic_expression_chars db "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/ ", 0
		
		; Arithmetic category characters:
		arithmetic_category_chars db "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/= ", 0
		
		; Characters for variable definition operations:
		variable_definition_chars db "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/: ", 0

		; Complement category characters:
		complement_chars db "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-~ ", 0


; Main method:
.CODE
    .STARTUP
		; This is the main cycle of:
		; 	1. get input
		; 	2. process input
		; 	3. check if still running
		
		.read_cmd:
			; Primpt the command prompt
			nwln
			PutStr cmd_prompt
			
			; Get the input string
			GetStr user_input, INPUT_LIMIT
			
			; Process user_input
			call process_input

			; Check if there needs to be another cycle.
			cmp byte [running], 0
			je .end
			jmp .read_cmd

		.end:
			; Print the end message:
			PutStr finish_msg
			nwln
    .EXIT


; This method processes the user_input string.
process_input:
    ; Print "Processing: '<user_input>'"
    PutStr processing_op
    PutStr user_input
    PutStr str_close_string
    nwln
	
	call preprocess
    
    ; Print "Preprocessed: '<user_input preprocessed>'"
    PutStr preprocessed_msg
    PutStr user_input
    PutStr str_close_string
    nwln
	
	; Compute category:
    call check_category
	
	; Print category:
	PutStr category_info
	call print_category_name
	nwln
    
    cmp byte [category], CATEGORY_ARITHMETIC
    je .process_category_arithmetic
    
    cmp byte [category], CATEGORY_COMMAND
    je .process_category_command
    
    cmp byte [category], CATEGORY_COMPLEMENT
    je .process_category_complement
    
    cmp byte [category], CATEGORY_VARIABLE
    je .process_category_variable
    
    .process_category_arithmetic:
        ;call process_arithmetic
        jmp .end
    
    .process_category_command:
        call process_command
        jmp .end
    
    .process_category_complement:
        ;call process_complement
        jmp .end
    
    .process_category_variable:
        ;call process_variable
        jmp .end
    
    .end:
	ret


; This method is used to process user_input as a command.
process_command:
    push EAX
		; This removes the # sign:
        mov EAX, user_input
        call remove_first_character
		; This removes the first space after the # ("# cmd")
        call remove_first_character
		
		PutStr str_process_command
        PutStr user_input
		PutStr str_close_string
        nwln
        nwln
		
		call get_first_token
		
		push ESI
		push EDI
			mov ESI, token_space
			
			; Compare token_space to cmd_exit
			mov EDI, cmd_exit
			call compare_strings
			jne .wasnt_cmd_exit
				call stop_running
				jmp .end_commands
			.wasnt_cmd_exit:
			
			; Compare token_space to cmd_about
			mov EDI, cmd_about
			call compare_strings
			jne .wasnt_cmd_about
				call print_about_info
				jmp .end_commands
			.wasnt_cmd_about:
			
			; Compare token_space to cmd_vars
			mov EDI, cmd_vars
			call compare_strings
			jne .wasnt_cmd_vars
				call print_vars
				jmp .end_commands
			.wasnt_cmd_vars:
			
			.end_commands:
		pop EDI
		pop ESI
    pop EAX
    ret


print_about_info:
	PutStr about_string
	ret


stop_running:
	mov byte [running], 0
	ret


print_vars:
	PutCh 'v'
	PutCh 'a'
	PutCh 'r'
	PutCh 's'
	;nwln
	ret


; Moves the first token from user_input into token_space
get_first_token:
	pushad
		; Put the first token limit in EAX
		call find_first_token_limit
		
		; Move found limit to EBX
		mov EBX, EAX
		
		; Move the first token from user_input onto token_space
		mov EAX, user_input
		call copy_to_token
		
		; Remove token from user_input
		call cut_up_to
		
	popad
	ret


; Finds the limit of the first token in user_input.
	; Output: EAX, the limit of the token
find_first_token_limit:
	push EBX
		; Start from user_input.
		mov EAX, user_input
		
		; Put the user_input string limit in EBX
		mov EBX, user_input
		add EBX, INPUT_LIMIT
		
		; Seek cycle:
		.cycle:
			; Stop if EAX is above EBX (the end of the string)
			cmp EAX, EBX
			ja .done
			
			; Stop at the first space
			cmp byte [EAX], SPACE_CHAR
			je .done
			
			; Stop at the first 0
			cmp byte [EAX], 0
			je .done
			
			; Next cycle:
			inc EAX
			jmp .cycle
		
		.done:
	pop EBX
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



; Clones the string at ESI, into EDI
clone_string_into:
	push ESI
	push EDI
	push AX
		.cycle:
			; Move the next byte
			mov AL, byte [ESI]
			mov byte [EDI], AL
			
			; Stop at 0
			cmp AL, 0
			je .end
			
			; Next cycle
			inc ESI
			inc EDI
			jmp .cycle
			
		.end:
	pop AX
	pop EDI
	pop ESI
	ret


; This method counts the characters in the string pointed at by the EAX. Return the result in the EBX register.
get_string_length:
	push EAX
		; Start with EBX to 0
		xor EBX, EBX
		.cycle:
			; Stop at the first 0
			cmp byte [EAX], 0
			je .done
			
			; Increase the count
			inc EBX
			
			; Point to the next byte
			inc EAX
			jmp .cycle
		
		.done:
	pop EAX
	ret


; This method copies the string from the address EAX up to EBX, to token_space
copy_to_token:
    pushad
        ; EDX keeps the address of where to copy the next byte.
        mov EDX, token_space
        
        .cycle:
            ; Stop when reached the EBX address
            cmp EAX, EBX
            jae .done
            
            ; Move a byte from EAX to token_space
            mov CL, byte [EAX]
            mov byte [EDX], CL
            
            inc EAX
			inc EDX
            jmp .cycle
            
        .done:
            ; Close the string at token_space
            mov byte [EDX], 0
    popad
    ret

; Removes from the string in address EAX the characters up to EBX, and moves the rest of the string accordingly.
cut_up_to:
    push EBX
        .cycle:
            ; Stop just when above EBX
            cmp EAX, EBX
            ja .done
            
            ; Remove the first character of the string at EAX
            call remove_first_character
            
            dec EBX
            jmp .cycle
        .done:
    pop EBX
    ret

; This method removes the first character of the string at EAX, by moving all the remaining characters back one place up to the first byte 0.
remove_first_character:
    push EAX
    push BX
    .cycle:
        mov BL, byte [EAX + 1]
        mov byte [EAX], BL
        
        cmp BL, 0
        je .done
        
        inc EAX
        jmp .cycle
    
        .done:
    pop BX
    pop EAX
    ret

check_category:
    pushad
        mov AL, byte [user_input]
        
        cmp AL, COMMAND_CHAR
        je .is_command
        
        cmp AL, COMPLEMENT_CHAR
        je .is_complement
        
        jmp .second_fase
        
        .is_command:
            mov byte [category], CATEGORY_COMMAND
            jmp .end
        
        .is_complement:
            mov byte [category], CATEGORY_COMPLEMENT
            jmp .end
            
        .second_fase:
            ; Up to this point, it's either CATEGORY_ARITHMETIC or CATEGORY_VARIABLE
            
            mov BL, VARIABLE_DEF_CHAR
            mov ECX, user_input
            call find_character
            jc .is_variable_definition
            
            mov BL, RESULT_BASE_INDICATOR_CHAR
            call find_character
            jc .is_arithmetic
            
            ; By default, unrecognized categories will be treated as CATEGORY_ARITHMETIC
            
            mov byte [category], CATEGORY_ARITHMETIC
            jmp .end
            
        .is_variable_definition:
            mov byte [category], CATEGORY_VARIABLE
            jmp .end
        
        .is_arithmetic:
            mov byte [category], CATEGORY_ARITHMETIC
            jmp .end
        
        .end:
    popad
    ret

; This method prints the category's name depending on the value of the category variable.
print_category_name:
	cmp byte [category], CATEGORY_ARITHMETIC
    je .process_category_arithmetic
    
    cmp byte [category], CATEGORY_COMMAND
    je .process_category_command
    
    cmp byte [category], CATEGORY_COMPLEMENT
    je .process_category_complement
    
    cmp byte [category], CATEGORY_VARIABLE
    je .process_category_variable
	
	; No category:
	PutStr category_name_invalid
	jmp .end
    
    .process_category_arithmetic:
        PutStr category_name_arithmetic
        jmp .end
    
    .process_category_command:
        PutStr category_name_command
        jmp .end
    
    .process_category_complement:
        PutStr category_name_complement
        jmp .end
    
    .process_category_variable:
        PutStr category_name_variable
        jmp .end
    
    .end:
	ret

; This method determines whether the character in BL is in the string at ECX.
; Affects: CF, 1 if it was, 0 if it wasn't
; Inputs: BL character to look for, ECX address of the string.
find_character:
    push ECX
        .cycle:
            cmp byte [ECX], BL
            je .found
            
            cmp byte [ECX], 0
            je .end_of_string
            
            inc ECX
            jmp .cycle
            
        .end_of_string:
            clc
            jmp .end
            
        .found:
            stc
            jmp .end
        
        .end:
    pop ECX
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

