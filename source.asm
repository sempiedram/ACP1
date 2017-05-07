

%include  "io.mac"

%include  "arithmetic.asm"
%include  "arithmetic_preprocessing.asm"
%include  "categories.asm"
%include  "commands.asm"
%include  "identation.asm"
%include  "strings.asm"
%include  "tokens.asm"
%include  "user_input.asm"
%include  "variables.asm"


; equ definitions:
	; This (minus one) is the size limit for the user_input string:
	; Generally used as a "big" number.
		INPUT_LIMIT equ 2048

	; Bytes reserved for variable storage:
		VARIABLES_SIZE equ 4096
		
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
		ADDITION_OPERATION_PRECEDENCE equ 1
		
		SUBTRACTION_OPERATION_CHAR equ '-'
		SUBTRACTION_OPERATION_PRECEDENCE equ 1
		
		MULTIPLICATION_OPERATION_CHAR equ '*'
		MULTIPLICATION_OPERATION_PRECEDENCE equ 2
		
		DIVISION_OPERATION_CHAR equ '/'
		DIVISION_OPERATION_PRECEDENCE equ 2
	
		COMPLEMENT_OPERATION_PRECEDENCE equ 3

	; Bit characters:
		OFF_BIT_CHAR equ '0'
		ON_BIT_CHAR equ '1'
	
	; Maximum number of bits for binary tokens (and other checks).
		MAX_BITS equ 32

	; Error codes:
		USER_INPUT_SWAP_NO_SPACE equ 1
	
	; Categories' values:
		CATEGORY_ARITHMETIC equ 1
		CATEGORY_COMMAND equ 2
		CATEGORY_COMPLEMENT equ 4
		CATEGORY_VARIABLE equ 8
		CATEGORY_INVALID equ 16
	
	; Error codes. These are used together with the error_code byte to send errors.
		; Means no error has been thrown.
		NO_ERROR equ 0
		
		; Means that an invalid token was found.
		ERROR_INVALID_TOKEN equ 1
		
		; Means that the parenthesis pairs were not properly matched.
		ERROR_UNMATCHED_PARENTHESIS equ 2
		
		; Signals that the indicated base was not recognized.
		ERROR_INVALID_BASE equ 3
		
		; Signals that the expression doesn't have a result base indicator.
		; TODO: Make this error a reason for ERROR_INVALID_EXPRESSION.
		ERROR_NO_RESULT_BASE_INDICATOR equ 4
		
		; The expression is invalid.
		ERROR_INVALID_EXPRESSION equ 5
		
			; The expression is invalid because two numbers were together.
			REASON_NUMBERS_TOGETHER equ 0

			; Two or more copies of the char specified by error_extra_info were found in the string at error_extra_info2 whene there should be only one.
			REASON_MULTIPLE_CHARACTERS equ 1

			; The expression has no tokens.
			REASON_NO_TOKENS equ 2
			
			; The expression's second token is not ':'.
			REASON_DEF_CHAR equ 3
			
			; The expression doesn't have enough tokens.
			REASON_NOT_ENOUGH_TOKENS equ 4
			
			; The expression has two or more result base indicators.
			REASON_MULTIPLE_RESULT_BASE equ 5
			
			; Too many tokens after the token pointed at by error_extra_info2
			REASON_TOO_MANY_AFTER equ 6
		
		; The a variable's name is not valid.
		; The token is in the string pointed at by error_extra_info2.
		ERROR_INVALID_VARIABLE_NAME equ 6

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
		
		; Used when showing the result of arithmetic_preprocessing.
		str_arithmetic_preprocessing_result db "Preprocessed (arithmetic): '", 0
		
		; For printing the resulting postfix expression.
		str_postfix_result db "Postfix equivalent expression: '", 0
		
		; For printing all variables.
		str_defined_variables db "These are the defined variables:", 0
		
		; When variables_space is empty:
		str_variables_empty db "There are no variables defined.", 0
		
		str_variable_expansions db "Variables expansions: '", 0
		
		str_defined_variable1 db "Varible defined. Name: '", 0
		str_defined_variable2 db "', value: '", 0
	
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
		
		; Error strings:
			str_error_invalid_token db "The following token is not valid: '", 0
			str_error_invalid_expression db "The expression given is invalid.", 0
			str_error_invalid_base db "The base given was not recognized: '", 0
			str_error_no_base_indicator db "The expression doesn't have a base result indicator.", 0
			str_error_invalid_name db "This token is not a valid variable name: '", 0
		
		; Reasons for errors strings:
			str_reason_numbers_together db "Two numbers were next to each other in the expression.", 0
			str_reason_multiple_characters db "Two or more instances of the character '", 0
			str_reason_multiple_characters2 db "' were found in the string '", 0
			str_reason_def_char_missing db "This token was expected to be a variable definition indicator character: '", 0
			str_reason_not_enough_tokens db "The expression doesn't have enough tokens to be processed.", 0
			str_reason_multiple_result_base db "The expression has multiple base result indicators.", 0
			str_too_many_tokens_after db "There are too many tokens after: '", 0
	
	; String memory spaces:
		; This is the string space for user input
		user_input times INPUT_LIMIT db 0
		; user_input_swap is a space used for performing operations over user_input
		user_input_swap times INPUT_LIMIT db 0
		
		; This is used to store the postfix expression:
		expression_space times INPUT_LIMIT db 0
		
		; This space is used to compute the postfic expression.
		stack_space times INPUT_LIMIT db 0

		;This byte field is used to store all defined variables.
		variables_space times VARIABLES_SIZE db 0
		
		; Strings for general use:
		string_a times STRING_SIZE db 0
		string_b times STRING_SIZE db 0
		
		; Space for token processing:
			token_space times STRING_SIZE db 0
			; Space to store temporarily token_space
			token_space_swap times STRING_SIZE db 0
		
	; This byte is used to keep track of identation, in number of spaces, to be able to "pretty" print things. Used by these methods: "print_identation", "increase_identation", "decrease_identation", "increase_identation_level", and "decrease_identation_level".
		identation db 0
		
		; This byte indicates how many spaces (or IDENTATION_CHAR's) are used for each "level" of identation. It's used by increase_identation_level, and decrease_identation_level.
		identation_size db 3
	
	; This byte is either 0, or 1. 0 means that the program should stop, and 1 that it should continue. It's checked every cycle to see if the program should stop.
		running db 1
	
	; These variables are used to properly handle errors.
		; This byte is used to check if there was an error (0 means no error):
			error_code db 0

		; This is the reason code of the error.
			error_reason db 0
		
		; These bytes can be used to mean something depending on the error_code.
		; For example, the address of a string that is relevant to the error.
		; Or the index of the character that was problematic.
			error_extra_info db 0
			error_extra_info2 dd 0
		
	; This byte holds the category computed by the check_category method:
		category db 0
		
	; This byte holds what base to convert the result of arithmetic operations. 0 means invalid, 2 means binary, 8 means octal, 10 means decimal, 16 means hexadecimal, and any other value is not valid.
		result_base db 0
	
	; This byte is used by the convert_to_postfix method to keep track of whether the previous token was a number.
		previous_was_number db 0

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
		
		; Default base string.
		; This string is appended to user_input when no result base indicator has been specified.
		default_base_result_indicator db " = dec", 0
	
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
			call print_about_info
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
		; Handles any errors that the process_x commands could have raised.
		call handle_error
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

; General error handling method.
handle_error:
	; Do nothing if error_code is NO_ERROR
	cmp byte [error_code], NO_ERROR
	je .end
	
	nwln
	
	cmp byte [error_code], ERROR_NO_RESULT_BASE_INDICATOR
	jne .not_base_indicator
		; Inform that no base indicator was present in the expression.
		call print_identation
		PutStr str_error_no_base_indicator
		nwln
		jmp .end
	.not_base_indicator:
	
	cmp byte [error_code], ERROR_INVALID_TOKEN
	jne .not_invalid_token
		call print_identation
		PutStr str_error_invalid_token
		PutStr dword [error_extra_info2]
		PutStr str_close_string
		nwln
		jmp .end
	.not_invalid_token:
	
	cmp byte [error_code], ERROR_INVALID_BASE
	jne .not_invalid_base
		call print_identation
		PutStr str_error_invalid_base
		PutStr dword [error_extra_info2]
		PutStr str_close_string
		nwln
		jmp .end
	.not_invalid_base:
	
	cmp byte [error_code], ERROR_INVALID_EXPRESSION
	jne .not_invalid_expression
		call print_identation
		PutStr str_error_invalid_expression
		nwln
		
		call print_invalid_expression_reason
		jmp .end
	.not_invalid_expression:

	cmp byte [error_code], ERROR_INVALID_VARIABLE_NAME
	jne .not_variable_name
		PutStr str_error_invalid_name
		PutStr dword [error_extra_info2]
		PutStr str_close_string
		nwln
		jmp .end
	.not_variable_name:
	
	; cmp byte [error_code], ERROR_
	; jne .not_
		; PutStr str_error_
		; PutStr dword [error_extra_info2]
		; PutStr str_close_string
		; nwln
		; jmp .end
	; .not_:
	
	.end:
		; Reset error_code
		mov byte [error_code], NO_ERROR
	ret


print_invalid_expression_reason:
	call print_identation
	push AX
		mov AL, byte [error_reason]
		
		cmp AL, REASON_NUMBERS_TOGETHER
		jne .not_numbers_together
			PutStr str_reason_numbers_together
			jmp .end
		.not_numbers_together:
		
		cmp AL, REASON_MULTIPLE_CHARACTERS
		jne .not_multiple
			PutStr str_reason_multiple_characters
			PutCh byte [error_extra_info]
			PutStr str_reason_multiple_characters2
			PutStr error_extra_info2
			PutStr str_close_string
			jmp .end
		.not_multiple:
		
		cmp AL, REASON_DEF_CHAR
		jne .not_def_char
			PutStr str_reason_def_char_missing
			PutStr dword [error_extra_info2]
			PutStr str_close_string
			jmp .end
		.not_def_char:
		
		cmp AL, REASON_NOT_ENOUGH_TOKENS
		jne .not_enough_tokens
			PutStr str_reason_not_enough_tokens
			jmp .end
		.not_enough_tokens:
		
		cmp AL, REASON_MULTIPLE_RESULT_BASE
		jne .not_multiple_result_base
			PutStr str_reason_multiple_result_base
			jmp .end
		.not_multiple_result_base:
		
		cmp AL, REASON_TOO_MANY_AFTER
		jne .not_too_many_tokens
			PutStr str_too_many_tokens_after
			PutStr dword [error_extra_info2]
			PutStr str_close_string
		.not_too_many_tokens:
		
		.end:
		nwln
	pop AX
	ret

