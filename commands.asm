


; This method is used to process user_input as a command.
process_command:
	push EAX
		; This removes the # sign:
		mov EAX, user_input
		call remove_first_character
		; This removes the first space after the # ("# cmd")
		call remove_first_character
		
		call print_identation
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


; Method for handling the #about command.
print_about_info:
	PutStr about_string
	ret


; Method for handling the #exit command. It stops the program cycle.
stop_running:
	mov byte [running], 0
	ret

