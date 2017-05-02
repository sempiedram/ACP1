

%include  "io.mac"

%include  "arithmetic.asm"
%include  "categories.asm"
%include  "commands.asm"
%include  "identation.asm"
%include  "strings.asm"
%include  "tokens.asm"
%include  "user_input.asm"
%include  "variables.asm"


; equ definitions:
	; This (minus one) is the size limit for the user_input string:
		INPUT_LIMIT equ 2048
		
	; General string spaces:
		STRING_SIZE equ 512
	
	; Characters:
		; Space character:
		SPACE_CHAR equ ' '
		
		; The character to be used for identation:
		IDENTATION_CHAR equ SPACE_CHAR

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
		
		; For showing the found result base:
		str_found_result_base db "Result base: '", 0
	
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
			"	Esteban Arias Mendez", 10,\
			"  Grupo:", 10,\
			"	2", 10,\
			"  Estudiantes:", 10,\
			"	Kevin Sem Piedra Matamoros", 10,\
			"	Kristin Nicole Alvarado ", 10,\
			"  Year:", 10,\
			"	2017", 10, 0
	
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
		
	; This byte is used to keep track of identation, in number of spaces, to be able to "pretty" print things. Used by these methods: "print_identation", "increase_identation", "decrease_identation", "increase_identation_level", and "decrease_identation_level".
		identation db 0
		
		; This byte indicates how many spaces (or IDENTATION_CHAR's) are used for each "level" of identation. It's used by increase_identation_level, and decrease_identation_level.
		identation_size db 3
	
	; This byte is either 0, or 1. 0 means that the program should stop, and 1 that it should continue. It's checked every cycle to see if the program should stop.
		running db 1
	
	; This byte is used to check if there was an error (0 means no error):
		error_code db 0
	
	; This byte holds the category computed by the check_category method:
		category db 0
		
	; This byte holds what base to convert the result of arithmetic operations. 0 means invalid, 2 means binary, 8 means octal, 10 means decimal, 16 means hexadecimal, and any other value is not valid.
		result_base db 0

	; Commands (that start with #) recognized:
		cmd_exit db "exit", 0
		cmd_vars db "vars", 0
		cmd_about db "about", 0
	
	; Base strings:
		invalid_base_identifier db "invalid", 0 ; This one is used to display that a base is invalid.
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
	call increase_identation_level
	; Print "Processing: '<user_input>'"
	call print_identation
	PutStr processing_op
	PutStr user_input
	PutStr str_close_string
	nwln
	
	call preprocess
	
	; Print "Preprocessed: '<user_input preprocessed>'"
	call print_identation
	PutStr preprocessed_msg
	PutStr user_input
	PutStr str_close_string
	nwln
	
	; Compute category:
	call check_category
	
	; Print category:
	call print_identation
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
		call process_arithmetic
		jmp .end
	
	.process_category_command:
		call process_command
		jmp .end
	
	.process_category_complement:
		; call process_complement
		jmp .end
	
	.process_category_variable:
		call process_variable_definition
		jmp .end
	
	.end:
	call decrease_identation_level
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

