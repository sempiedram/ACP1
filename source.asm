

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
	ret

