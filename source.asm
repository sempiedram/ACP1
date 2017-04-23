

%include  "io.mac"


; equ definitions:
	; This (minus one) is the size limit for the user_input string:
    INPUT_LIMIT equ 1024


.DATA
	; This is the string used as prompt for the next operation:
    cmd_prompt: db "::> ", 0
	
	; This string is showed at the end of the program execution:
    finish_msg: db "Bye!", 0
	
	; This is the string space for user input
    user_input: times INPUT_LIMIT db 0
	
	; This byte is either 0, or 1. 0 means that the program should stop, and 1 that it should continue. It's checked every cycle to see if the program should stop.
    running: db 0

    ; Commands (that start with #) recognized:
    CMD_EXIT: db "exit", 0
    CMD_VARS: db "vars", 0
    CMD_ABOUT: db "about", 0


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
	push EDI
	push ESI
		mov EDI, user_input
		mov ESI, CMD_EXIT
		call compare_strings
		
		jne .strings_not_equal
			PutCh 'e'
			jmp .done
		.strings_not_equal:
			PutCh 'n'
			jmp .done
		
		.done:
			PutCh '-'
	pop ESI
	pop EDI
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
