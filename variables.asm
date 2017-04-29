


; Method for handling the #vars command: It prints all defined vars.
print_vars:
	PutCh 'v'
	PutCh 'a'
	PutCh 'r'
	PutCh 's'
	;nwln
	ret


; This method is used to process user_input as a variable definition operation.
process_variable_definition:
	; Check that there is exactly one ':' character
	; Check that there are no invalid characters
	; Check that everything before is a single variable name
	ret


