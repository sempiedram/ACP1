
# ACP1 - Analysis 3

This is the third analysis text file made for the Arquitectura de Computadores's first project.

Tecnológico de Costa Rica - Sede de Cartago
Escuela de Computación - Ingeniería en Computación
Primer semestre, 2017
Profesor: Esteban Arias Mendez
Estudiantes: Kevin Sem Piedra Matamoros, Kristin Nicole Alvarado

# Description of the program

The program is in a constant cycle: the main cycle.

The main cycle consists in:

1. Get input from the user.
2. Process the input.
3. Check if the cycle should be repeated.

## Point 1: Get input from the user.

The input will be stored in a string named user_input, which has INPUT_LIMIT bytes reserved for this use. Besides this field, a user_input_swap exists to be used as a buffer for certain operations; this extra buffer can be used through the clone_user_input (which clones the user_input string into user_input_swap, so that user_input can be modified without losing the original value), and restore_user_input (which copies the string at user_input_swap into user_input, restoring it's original value (or whatever was put inside user_input_swap)).

The user_input string is the one used for processing. The process_input method processes this string, and does whatever is necessary depending upon it's contents.

Getting the string from the user is done through the GetStr method, of the io.mac (and the io.o file)  library provided by Sivarama, for his book on computer architecture and x86 assembly "Guide to Assembly Language Programming in Linux".

## Point 2: Process the input.

The process_input method handles this part of the cycle. After the expression has been written into user_input, process_input handles the expression.

The user_input string is preprocessed, in order to homogenize what is being fed into the program. The preprocessing consists of separating tokens by spaces where necessary, and removing unecessary spaces.

After preprocessing, to process the input it must be known what has to be done. This depends on what the contents of the string are. The contents of the string separate the expression into one of the following categories: arithmetic operation, variable definition, command, complement operation, floating point conversion, or invalid expression. These categories each have a handler method, so that the processing is delegated to those methods by the process_input method. Therefore, process_input's main purpose is to homogenize the input, determine the input's category, and then call the right handling method.

## Point 3: Check if the cycle should be repeated.

The program will stop when the cycle is stopped. The cycle is controlled by checking at the end of every cycle to see if the byte called running is 0 or not. If it's 0, then the cycle is broken, else, the cycle is repeated.

When the cycle is broken, a "goodbye" message is displayed, and then the program is closed.

# Category determination

The category is mainly determined by what characters are found in the user_input string. The method that does this is called check_category, which returns what category the string was through the byte called "category". The values of that byte are: CATEGORY_ARITHMETIC, CATEGORY_COMMAND, CATEGORY_COMPLEMENT, CATEGORY_VARIABLE, and CATEGORY_INVALID. These constants have specific distinct numerical values, but the numerical values should not be used, only their names as they could be changed.

The check_category algorithm should be:

1. Check if the first character is '#'. If it is, check if it's a valid command expression, and return CATEGORY_COMMAND, or CATEGORY_INVALID accordingly.
2. Check if the first character is '~'. If it is, check if it's a valid complement expression, and return CATEGORY_COMPLEMENT, or CATEGORY_INVALID accordingly.
3. Check if the string contains the ':' character. If it's in the string, check if it's a valid variable definition operation, return CATEGORY_VARIABLE, or CATEGORY_INVALID accordingly.
4. At this point, the expression should be CATEGORY_ARITHMETIC, or CATEGORY_INVALID. Check if it's a valid arithmetic operation, and return accordingly.
5. Done. The category of the expression is now stored in the category byte.

After determining the category of the expression, then it can be used to execute different methods. This category byte is used by the process_input method to call the right handler.

# Variables

Variables are defined using "variable definition" operations. These variables are names used to refer to expressions that can be inserted into other expressions. As variables are expressions, and variables can be put in expressions, recursive variables can be defined. However, this should be taken as an error, because it would be infinite recursion.

A design choice was made to use variables as just text that is replaced into expressions. The other option was to store variables as just their numerical value, but it seems too limited.

Variables are to be stored in the variables_space byte field, of size VARIABLES_SIZE.

The format they will have is: <variable_name>0<variable_value>0<...>, where variable_name is the name of the variable, and variable_value is it's value. Both are C-style strings (represented by the zeroes). For each variable defined there would be one such pair of strings in variables_space.

The algorithm to set a variable is:

1. Remove any previous definition, if it exists.
2. Add new definition.

The algorithm to remove previous variable definitions is:

1. Look for the variable definition, if it doesn't exist return.
2. Find the limits of the definition.
3. Move the part of variables_space back, covering that definition.

The algorithm to add a new definition is:

1. Find the next space in variables_space, which is identified by two bytes with value 0 next to each other (variable names, nor values, can be empty strings).
2. Write the variable name string.
3. Write the variable value string.

## Variable names

Variable names have the following restrictions:

1. Can't be the empty string.
2. Are only composed of the characters "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".
3. They cannot be valid numbers. There is an intersection between valid numbers, and valid variable names, namely, the hexadecimal numbers that have no decimal digits ("0123456789"). For example: "BABEhex", "COFFEEhex", etc. This allows expressions to be less misleading, as number behaviour will work as expected.

# Processing: Arithmetic operation

Arithmetic operations are the hardest to process.

The general algorithm is:

1. Expand variables.
2. Do the arithmetic preprocessing.
3. Check that it's a valid arithmetic expression.
4. Extract from the expression the result base.
5. Convert every number into binary.
6. Convert the expression into postfix.
7. Evaluate the postfix expression.
8. Done. The result should be the only number in the "postfix evaluation stack" (if the expression was valid).

These steps are each rather complex, and have certain details. These details are shown next.

## Arithmetic operation: Variable expansion

The pseudocode for variable expansion is:

	while there are valid variable names in the expression {
		for every token in the expression {
			if token is a valid variable name {
				if token is a valid number {
					continue to next token
				}
		
				if that variable is defined {
					replace the variable's name with its value
					do a normal preprocessing
				}else {
					raise an error, this token has no meaning
				}
			}
		}
	}

This ensures that:
1. If there is an undefined variable name, an error will be generated.
2. If a variable that contained a variable name was in the expression, the second will also be expanded.

To be handled: variable recursion.

## Arithmetic operation: Arithmetic preprocessing

Arithmetic expressions should have a certain format; this format is enforced by this preprocessing step.

The format requires the following:

1. All numbers have their explicit base.
2. The "result base" is explicitly defined.

### Point 1 - Default base

The default base, as required in the specification for the project, is decimal ("dec"). Therefore, all numbers that don't have a base should get the "dec" base by default.

This is done by checking every token to see if they are valid decimal numbers, and see also if they don't have an explicit base (i.e. only have the characters "0123456789"). If that's the case then the string "dec" is added as a postfix (e.g.: "5" -> "5dec").

### Point 2 - Result base

The "result base" is the base in which the final result of the expression should be presented. The default result base is decimal. This base is indicated using the following format: "<expression> = <result base>". Therefore, if there is not already an explicit result base, the string " = dec" should be added at the end of the expression.

## Arithmetic operation: Valid arithmetic operations

Arithmetic expressions are valid if the following statements are true for the expression beforethe base result definition:

1. All tokens are either valid numbers or valid operators.
2. All operators have exactly their required number of operands.
3. All parenthesis are properly matched.

However, only the first statement is checked in this step. The other two are properly checked in a later step (probably in the "convert the expression into postfix" step). Parenthesis matching can be checked here, but only superficially (because otherwise it would be easier just to evaluate the expression now). So in this step it's only checked that ever token is either a valid number or an operator.

Besides those, an arithmetic expression needs to have exactly one base result definition, indicated by the '=' character. The next token after the '=' must be a valid base: bin, oct, dec, or hex.

## Arithmetic operation: Extract result base

The result base extraction algorithm is:

1. Find the '=' character. If it's not in the expression, raise an error.
2. Check that there is exactly one token after it. If there's none, raise an error (although this should not be necessary, because of arithmetic preprocessing). If there's more than one, raise an error indicating so.
3. Check that it's a valid base: bin, oct, dec, or hex. If it's not, raise an error with that token.
4. Save that base somewhere.

## Arithmetic operation: Convert all numbers into binary

This is done by checking every token, if the token is a valid number, convert it and replace it in the expression.

The conversion algorithm should be:

1. If the number's base is binary, just ignore it.
2. If the number's base is octal, expand every octal digit to their binary equivalent. Trim extra sign bits (e.g. "00001011" -> "01011").
3. If the number's base is decimal, divide repeatedly.
4. If the number's base is hexadecimal, expand every hexadecimal digit to their binary equivalent. Trim extra sign bits (e.g. "1111010" -> "1010").

## Arithmetic operation: Convert the expression into postfix

At this point, the expression is composed of: binary numbers, operators ("+-\*/"), and parenthesis. The expression may or may not be valid, structurally.

The general algorithm is:

	for every token in the expression {
		if token is a number {
			add it to the new expression

		}else {
			if token is an operator {
				if the stack is empty {
					place it there
				}
			}else {
				if token is open parenthesis {
					place it in the stack
				}else {
					; Token is close parenthesis
					while next token in stack is not open parenthesis and the stack is not empty {
						pop operator and put it on the new expression
					}
				}
			}
		}
	}

	while stack is not empty {
		pop operator and put it in the new expression
	}

Which is rather big, but it's the core of the evaluation of arithmetic expressions.

## Arithmetic operation: Evaluation of the postfix expression

This part of the process is where the evaluation of the expression actually happens. The evaluation is done using the previously created "postfix expression" which should be equivalent to the original expression. The postfix expression is guaranteed to have only valid numbers in binary, and valid operations (although, there could be a mismatch between operations and number of operands).

This evaluation process requires the use of a "operand stack", which is where the operands are placed and taken from as each token in the expression is read.

The algorithm is basically:

	operands stack = empty stack
	for every token in the postfix expression {
		if token is number {
			place it in the stack
		} else {
			; The token is an operation.

			; n is the number of operands the operation needs (1, or 2)
			take n operands from the stack

			do operation
			push result into the stack
		}
	}
	return the last operand in the stack as the final result

At the end of this algorithm, the stack should have exactly one operand left, which is the value of the whole expression. If there is either no operands left (the expression was empty), or multiple operands (the expression was malformed, such as: "5 5 + 3"), then an error should be raised saying so.

Another error that can happen is that an operation requires n operands, but there are less than n operands in the stack. This should be properly detected, and displayed. 

# Processing: Command

A command is an expression that starts with a '#' (called the "command identification character"). After that character, the first token (e.g. in "#about", that is turned into "# about" after preprocessing, the next token after the '#' is "about") is called the "command name" or simply "command". The "command name" determines what should be done.

The method process_command is the method that handles commands. It processes user_input as a command, and does what is required to execute said command.

First it removes the '#' character, because it's already known that the category is Command. After that, the first token is taken to be the command name (and it is removed from user_input), and that name is compared against a set of predefined commands, and if it matches one of those, the proper command handler method is called.

When a command handler method is called, the command name has been removed from user_input (and moved into token_space, which is a special byte field for tokens), and therefore, user_input only contains the "arguments" for that command, which can be used by the handler method.

As an example, the "about" command (called by writting "#about"), displays information about this project. It's handler method is print_about_info, and it's command name is store in cmd_about.

# Processing: Variable definitions




