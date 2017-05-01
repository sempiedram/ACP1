
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


# Processing: Command

A command is an expression that starts with a '#' (called the "command identification character"). After that character, the first token (e.g. in "#about", that is turned into "# about" after preprocessing, the next token after the '#' is "about") is called the "command name" or simply "command". The "command name" determines what should be done.

The method process_command is the method that handles commands. It processes user_input as a command, and does what is required to execute said command.

First it removes the '#' character, because it's already known that the category is Command. After that, the first token is taken to be the command name (and it is removed from user_input), and that name is compared against a set of predefined commands, and if it matches one of those, the proper command handler method is called.

When a command handler method is called, the command name has been removed from user_input (and moved into token_space, which is a special byte field for tokens), and therefore, user_input only contains the "arguments" for that command, which can be used by the handler method.

As an example, the "about" command (called by writting "#about"), displays information about this project. It's handler method is print_about_info, and it's command name is store in cmd_about.

# Processing: Variable definitions





