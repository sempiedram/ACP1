
# Analysis

This is a rough first analysis on how to implement Computer Architecture's first project.

# Sketch of functionality

At the beginning of the program, the user will only be prompted to write a command, like this:

    ::> _

With this, the user will be able to intruduce commands, such as the following:

    ::> 45 + 22

Then, the result of the operation will be shown:

    @ Convert 45dec to binary:

        45|2
        -----
         1|22|2
           -----
            0|11|2
              ----
               1|5|2
                 ---
                 1|2|2
                   ---
                   0|1|2
                     ---
                     1|0

        45dec = 00000000000000000000000000101101bin

    @ Convert 22dec to binary:

        22|2
        ----
         0|11|2
           ----
            1|5|2
              ---
              1|2|2
                ---
                0|1|2
                  ---
                  1|0

        22dec = 00000000000000000000000000010110bin

    @ Sum of 00000000000000000000000000101101bin with 00000000000000000000000000010110bin:

          00000000000000000000000000101101
        + 00000000000000000000000000010110 =
          --------------------------------
          00000000000000000000000001111000 <- Carry
          --------------------------------
          00000000000000000000000001000011 <- Result

    @ Convert 00000000000000000000000001000011bin to decimal:

        Decimal value =
            2^0 + 2^1 + 2^6 =
            1 + 2 + 64 =
            67dec

    @ Final result:
        67dec

    ::> _
	

# Categories of operations:

Any string that the user inputs, called operations, are classified into five categories: commands, arithmetic, variable definition, two's complement, and invalid.

These are examples of those categories:

## Commands:

Examples:
    ::> #exit

        @ About:

            TEC
            Students:
                Kevin
                Kristin
            Carrera...
            ...

        @ Bye!

    ::> #ver

        @ Version: 0.0.0

    ::> #var

        @ Defined variables:

            vi = 565oct
            sem = 2030dec

## Arithmetic operations:
    ::> 5

        @ Result:
            5dec

    ::> 15oct

        @ Convert 15oct to decimal:

            Decimal value =
                5 * 8^0 + 1 * 8^1 =
                5 * 1 + 1 * 8 =
                5 + 8 =
                13dec

        @ Result:
            17dec
    ::> hello

        @ Substitute variables:
            hello = 40dec

            hello =
                40dec

        @ Result:
            40dec

    ::> 4 + 3
    ::> 46oct + 7hex
    ::> 46oct + 7hex = bin
    ::> 44 + (23 - 3)
    ::> 23 - 4 * 2
    ::> 34 - 23 * (7 + 2 / 2) - 2 = bin

## Variable definitions:

    ::> geo : 7 - 2
        @ Define variable:
            geo = 5dec

    ::> hi : 1002 + 2
        @ Define variable:
            hi = 1002dec

## Two's complement:
    ::> ~ 34
        @ Convert 34dec to binary:

            34|2
            -----
             0|17|2
               ----
                1|8|2
                  ---
                  0|4|2
                    ---
                    0|2|2
                      ---
                      0|1|2
                        ---
                        1|0

            34dec = 00000000000000000000000000100010bin

        @ Two's complement of 00000000000000000000000000100010bin:

            Bitwise negation:
                00000000000000000000000000100010
                11111111111111111111111111011101

            Add 1:
                11111111111111111111111111011101
                11111111111111111111111111011110

            Result:
                11111111111111111111111111011110bin

## Invalid operations:

    ::> *
        @ Error:
            Not enough operands.

    ::> **
        @ Error:
            Expected operands.

    ::> 5 + (5
        @ Error:
            Invalid pairs of parenthesis.

    ::> 6 + ()
        @ Error:
            Empty parenthesis.

    ::> 55!
        @ Error:
            Unrecognized character: '!'

    ::> #no_op
        @ Error:
            Unrecognized command: 'no_op'

    ::> #
        @ Error:
            Empty string command.

    ::> <more than 1023 characters>
        @ Error:
            String too long.

    ::> 1000000000000000000000000000bin = oct
        @ Error:
            Number too big.

    ::> 5tre + 4
        @ Error:
            Unrecognized base: 'tre'

    ::> 4 + 3 = tre
        @ Error:
            Unrecognized base: 'tre'

    ::> ~
        @ Error:
            No value to process.

# Checking category:

Before evaluating the operation, it must be known what is being asked to be done. This is done *after preprocessing*.

The steps to follow are:

1. Check for invalid characters:

	Only the following characters are valid:
		All characters: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/~= :#()"

	These characters are divided in the following categories:
		a. Digits: "0123456789ABCDEF"
			Only decimal digits and uppercase letters up to 'F' are valid digits.
		b. Base identifiers: "bcdehinotx"
			The union of the sets "bin", "oct", "dec", and "hex".
		c. Variable names: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
			Only letters can be used for variable names.
		d. Arithmetic operations: "+-*/"
		e. Arithmetic category result base indicator: "="
		f. Space: " "
		g. Complement category indicator: "~"
		h. Command category indicator: "#"
		i. Varible definition category indicator: ":"
		j. Arithmetic expression characters:
			  Arithmetic operations
			+ Digits
			+ Base identifiers
			+ Variable names
			+ Space
			= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/ "
		k. Arithmetic category characters:
			  Arithmetic expression characters
			+ Arithmetic category result base indicator
			= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/= "
		l. Command category characters:
			All characters
			= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/~= :#"
			Note: Arguments to commands can contain any character (TODO: probably should include all valid ascii characters).
		m. Varible definition characters:
			  Arithmetic expression
			+ Varible definition category indicator
			+ Variable names
			= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/ :"
			TODO: Decide if expressions can be passed to variable definition mode.
		n. Complement category characters:
			  Complement category indicator
			+ Variable names
			+ Digits
			+ Base identifiers
			+ Space
			= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ*/~ "
			TODO: Decide if expressions can be passed to complement mode.
		o. Open parenthesis: "("
		p. Close parenthesis: ")"
2. Check first character.
	2.1. Is it '#':
		Category is command.
	2.2. Is it '~':
		Category is two's complement.
	2.3. It's not one of those:
		Category must be arithmetic or variable definition.

		2.3.1. Look for ':' (variable definition category indicator)
			If found, category is variable definition.
			Else, category is arithmetic operation.

# Input preprocessing:

Before the actual processing of arithmetic input, preprocessing should be done to homogenize input.

1. **Insert necessary spaces.** This can be done by inserting two spaces to either side of any operation symbol, or parenthesis, even if they already have spaces around them. Exceptions are: '#' (command indicator).

    Examples:

    	'4+5' to '4 + 5'
    	'4+2-2' to '4 + 2 - 2'
    	'4--2' to '4 -  - 2'
    	'5 + (5 - 2)' to '5  +   ( 5  -  2 ) '
    	'5dec+(8-1)=bin' to '5dec +  ( 8 - 1 )  = bin'

2. **Strip repeated spaces.** This can be done reading all characters of the string one by one, adding a space when one is found and ignoring all other spaces. Anything that is not a space is added.

    Examples:

        '4 + 5' to '4 + 5'
        '5  +   ( 5  -  2 ) ' to '5 + ( 5 - 2 ) '
        '5dec +  ( 8 - 1 )  = bin' to '5dec + ( 8 - 1 ) = bin'

3. **Strip beginning and end spaces.** The string is scanned until a character that is not a space is found, then all characters are added until the end of the string is reached. After stripping the beginning spaces, the end spaces are stripped by walking through the characters backward, starting from the end of the string, until a non-space character is found.

    Examples:

        '5 + ( 5 - 2 ) ' to '5 + ( 5 - 2 )'
        '   3dec * 7oct   ' to '3dec * 7oct'

4. **Add implicit base.** This is done checking every number to see if they have a base sufix. If they don't, dec is added.

    This should not be done if the operation category is command.

    Examples:

        '4' to '4dec'
        '5oct + 4' to '5oct + 4dec'

5. **End.** The string is now properly preprocessed, and it can be passed on to the evaluating method.

# Input preprocessing for arithmetic operations:

After preprocessing, if the category is found to be arithmetic operation, then this preprocessing is done:

1. Add implicit result base conversion. If no result base was indicated (with ' = base' at the end) then the default is added.

    Examples:
        '5dec' to '5dec = dec'
        '5dec - 1oct' to '5dec - 1oct = dec'

2. The string is now properly preprocessed, and it can be passed on to the evaluating method.

# Evaluating operation - Commands:

When a command is passed (such as '#exit'), do the following:

1. Remove first character (that should be a '#').
2. Find command. This is done reading the string until a space is found or the end of the string is found. The command is the substring from the beginning to that point (without the space).
3. Remove command name.
4. Try to recognize command name. If it is recognized, execute the respective method, passing the string as arguments. If it is not recognized, print a message saying so.
5. Done.

# Evaluating operation - Arithmetic:

This is done after all preprocessing.

Steps:

1. Check that the string for errors.
    1.1. Check validity of characters:
        All characters must be one of Arithmetic category characters.
    1.2. There must be exactly one Arithmetic category result base indicator ('=').
    1.3. There must be at least a non-space valid character before the Arithmetic category result base indicator.
    1.4. All characters after the Arithmetic category result base indicator must be one of Variable names + Space
    1.5. There must be an equal quantity of opening '(' and closing ')' parenthesis. Can be checked by counting from zero adding one every time a '(' is found and subtracting one every time a ')' is found.
    
2. Find result base indicator.
    This is done walking through the string until an Arithmetic category result base indicator is found, then the rest of the string is stripped of spaces, and treated as the result base.

2.1. Check that the result base found is valid.

3. Remove the result base indicator portion.
    Example: '4 + 5 = dec' to '4 + 5'

# Arithmetic operation examples
Operation: "    3020dex + 23-1101bin*((varA) + 33oct)-1=   oct      "
    a. Preprocessing:
        a.a. Insert spaces:
            "    3020dex  +  23 - 1101bin *  (  ( varA )   +  33oct )  - 1 =    oct      "
        a.b. Remove repeated spaces:
            " 3020dex + 23 - 1101bin * ( ( varA ) + 33oct ) - 1 = oct "
        a.c. Remove beginning and end spaces:
            "3020dex + 23 - 1101bin * ( ( varA ) + 33oct ) - 1 = oct"
        a.d. Add implicit base:
            "3020dex + 23dec - 1101bin * ( ( varA ) + 33oct ) - 1dec = oct"
    b. Check that the string for errors:
        "3020dex + 23dec - 1101bin * ( ( varA ) + 33oct ) - 1dec = oct"
        b.a. Check validity of characters
            All characters are one of Arithmetic category characters
                ("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/= ")
        b.b. There must be exactly one Arithmetic category result base indicator
            There is only one '='
        b.c. There must be at least a non-space valid character before the Arithmetic category result base indicator.
            There is at least one: '3' (the first character)
        b.d. All characters after the Arithmetic category result base indicator must be one of Variable names + Space
            They are: all characters in " oct" are in Variable names + Space ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ").
        b.e. There must be an equal quantity of opening '(' and closing ')' parenthesis.
            There are:

            count = 0

            "3020dex + 23dec - 1101bin * ( ( varA ) + 33oct ) - 1dec = oct"
                                         ^ count++
            count = 1

            "3020dex + 23dec - 1101bin * ( ( varA ) + 33oct ) - 1dec = oct"
                                           ^ count++
            count = 2

            "3020dex + 23dec - 1101bin * ( ( varA ) + 33oct ) - 1dec = oct"
                                                  ^ count--
            count = 1

            "3020dex + 23dec - 1101bin * ( ( varA ) + 33oct ) - 1dec = oct"
                                                            ^ count--
            count = 0

            "3020dex + 23dec - 1101bin * ( ( varA ) + 33oct ) - 1dec = oct"
                                                                          ^ End.

            The final count was 0, therefore, there is a balanced number of parenthesis.

    c. Find result base indicator.
        "3020dex + 23dec - 1101bin * ( ( varA ) + 33oct ) - 1dec = oct"
                                                                 ^- Result base indicator
        " oct" <- Rest of string
        "oct" <- Rest of string stripped of spaces.
        Result base: "oct", is valid.

    d. Tokenization
        a. First approach:
            a. Find limit.
				Scan character by character until the first space or the end of the string. Save that position.
			b. Copy string.
				Copy from the beginning of the string to the position of the space (or end of string).
			c. Classify string.
				
            
        b. Second approach:
            a. Separate by spaces:
                ["3020dex", "+", "23dec", "-", "1101bin", "*", "(", "(", "varA", ")", "+", "33oct", ")", "-", "1dec"]

            b. Classify tokens as WORDs, OPERATIONs, OPEN_PARENTHESIS, CLOSE_PARENTHESIS:
                [WORD:"3020dex", OPERATION:"+", WORD:"23dec", OPERATION:"-", WORD:"1101bin", OPERATION:"*", OPEN_PARENTHESIS:"(", OPEN_PARENTHESIS:"(", WORD:"varA", CLOSE_PARENTHESIS:")", OPERATION:"+", WORD:"33oct", CLOSE_PARENTHESIS:")", OPERATION:"-", WORD:"1dec"]

            c. Process all WORD tokens and detect if they are NUMBER or VARIABLE:
                [WORD:"3020dex", WORD:"23dec", WORD:"1101bin", WORD:"varA", WORD:"33oct", WORD:"1dec"]
                => [NUMBER:"3020dex", NUMBER:"23dec", NUMBER:"1101bin", VARIABLE:"varA", NUMBER:"33oct", NUMBER:"1dec"]
                
    e. Checking of tokens.
        [NUMBER:"3020dex", OPERATION:"+", NUMBER:"23dec", OPERATION:"-", NUMBER:"1101bin", OPERATION:"*", OPEN_PARENTHESIS:"(", OPEN_PARENTHESIS:"(", VARIABLE:"varA", CLOSE_PARENTHESIS:")", OPERATION:"+", NUMBER:"33oct", CLOSE_PARENTHESIS:")", OPERATION:"-", NUMBER:"1dec"]

        We check token order in the first level taking things grouped by parenthesis, and variables as numbers.
        The order should be: NUMBER, (OPERATION, NUMBER)*
        (Where asterisk means zero or more of that pattern)

        Examples of valid expressions:
            "3 + (...) / 2" = NUMBER OPERATION NUMBER OPERATION NUMBER
            "99209" = NUMBER
            "57 - 2" = NUMBER OPERATION NUMBER

        TODO: Properly handle number signs:
            "6 * -2" and "5 * +1" should both be NUMBER OPERATION NUMBER,
                not NUMBER OPERATION OPERATION NUMBER

            This can be done by checking if there are operations next to each other, and then checking if the operation to the left of the number is '+' or '-', applying that sign to the number, and then deleting the token.

        If the expression is not valid, end the process.

        Then check recursively expressions inside parenthesis in the same way.

    f. Evaluation of tokens
        If there are parenthesis expressions, evaluate them first recursively.

        If there are no parenthesis, find the higher precedence operation from left to right, evaluate that operation, substitute the operation and the operands by the result, and recursively evaluate the expression until there is just only a number.

        When only a number is left, return, and substitute upper level parenthesis expressions.

        Repeat until there is only a single number left, that's the result.

    g. Done.


# Data structures

## Expressions

An expression is a list of tokens. Expressions live inside the expression space, in memory.

The expression space is a piece of memory that is reserved in the data segment; it's size is, for now, 4096 bytes (a big enough number of bytes).

There is only one real expression, and multiple or zero sub-expressions (that are delimited by parenthesis tokens).

Expression space limits are handled by two pointers, exp_space_begin and exp_space_end. If they are equal, the expression space is empty. If not, there must be at least a single token inside it. But this is only to know if there is tokens inside it. Tokens should not be accessed through pointers, but with identifiers (ID's).

There should be some methods to manipulate the expression space, tokens, and sub-expressions, for example:
    a. Clear expression space.
        Turns every bit between exp_space_begin and exp_space_end to 0. Makes exp_space_end take the value of exp_space_begin (indicating that the expression space is empty).
    b. Push a token.
        Takes the token in token space, and puts it in the address pointed to by exp_space_end.
        Moves exp_space_end to the end of the new token.
    c. Delete a token.
        Given the ID of a token, the token is searched. If it is found, it is zeroed.
    d. Reformat expression space.
        Move tokens as close to each other as possible, and manipulate exp_space_end accordingly.

## Tokens

A token is a piece of an expression. Tokens are constructed in tokens_space.
Tokens have the following information:

1. ID, a number identifying every token. Stored as two bytes. Starts from 0.
2. Type, information about what is this token. Stored as a byte.
    Possible types:
        a. UNKNOWN, value 0
			This is the default type of a token.
        b. WORD, value 1
			All NUMBER tokens and VARIABLE tokens are also WORD tokens.
			These tokens are made of the characters:
				Digits + Variable names
				= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        c. NUMBER, value 2
			All NUMBER tokens are also WORD tokens.
			These tokens are made of the characters:
				Digits + Base identifiers
				= "0123456789ABCDEFbcdehinotx"
        d. VARIABLE, value 3
			All VARIABLE tokens are also WORD tokens.
			These tokens are made of the characters:
				Variable names
				= "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
		e. BASE_IDENTIFIER, value 4
			All BASE_IDENTIFIER are also valid WORD tokens, and VARIABLE tokens.
			These tokens are made of the characters:
				 Base identifiers
				= "bcdehinotx"
        f. OPEN_PARENTHESIS, value 5
			This token is simply the string "(".
        g. CLOSE_PARENTHESIS, value 6
			This token is simply the string ")".
        h. OPERATION, value 7
			These tokens are made of the characters:
				Arithmetic operations
				= "+-*/"
		i. BASE_INDICATOR, value 8
			This token is simply the character Arithmetic category result base indicator.
		j. COMPLEMENT_INDICATOR, value 9
			This token is simply the character Complement category indicator.
		k. COMMAND_INDICATOR, value 10
			This token is simply the character Command category indicator.
		l. VARIABLE_INDICATOR, value 11
			This token is simply the character Varible definition category indicator.
3. Extra byte, a single byte that can be used to store extra information. The information stored here depends upon the type of the token:
    a. For UNKNOWN, it's meaningless.
    b. For WORD, it's meaningless.
    c. For NUMBER, it's the original base: 2, 8, 10, or 16, and any other value is meaningless.
    d. For VARIABLE, it's meaningless.
    e. For BASE_IDENTIFIER, it's the base value: 2, 8, 10, or 16, any other value is meaningless.
    f. For OPEN_PARENTHESIS, it's meaningless.
    g. For CLOSE_PARENTHESIS, it's meaningless.
    h. For OPERATION, it's the operation id: 0 for +, 1 for -, 2 for *, 3 for /.
	i. For BASE_INDICATOR, it's meaningless.
	j. For COMPLEMENT_INDICATOR, it's meaningless.
	k. For COMMAND_INDICATOR, it's meaningless.
	l. For VARIABLE_INDICATOR, it's meaningless.
4. Numerical value, four bytes to store the numerical value of the token. These four bytes only have meaning if type is NUMBER.
5. String, "original" string source. Ends with a 0.

Full format: IITEVVVVS... (I:ID, T:Type, VVVV:Value, S:Token string).

# Token classification

This is an algorithm on how to classify tokens:
0. Is the string lenght 0?
	Return UNKNOWN
1. Is the string of length 1?
	Check for one of the following:
		Open parenthesis -> OPEN_PARENTHESIS
		Close parenthesis -> CLOSE_PARENTHESIS
		Arithmetic category result base indicator -> BASE_INDICATOR
		Complement category indicator -> COMPLEMENT_INDICATOR
		Command category indicator -> COMMAND_INDICATOR
		Varible definition category indicator -> VARIABLE_INDICATOR
2. Check string composition:
	At this point, the token type is either UNKNOWN, WORD, NUMBER, or VARIABLE.
	Starting with UNKNOWN, the type is reduced by checking every character.
	1. Check if it only has base identifier characters ("bcdehinotx").
		If it's a valid base identifier (bin, oct, dec, hex), return.
		If it's a defined variable, return.
		Else, return UNKNOWN.
	2. Check if it has decimal digits, if it does, it should be a number.
	3. It should be a variable. If it isn't, this must be stored somewhere.
	

## Examples of the token types:
	a. UNKNOWN
		Any string fits into this category.
	b. WORD
		3020dex
		varA
		GIWJJI
		200
		0
		a
	c. NUMBER
		12920dec
		AB192Bhex
		0
		BABE
	d. VARIABLE
		force
		x
		pointX
		generateAllVariables
	e. BASE_IDENTIFIER
		dec
		bin
		hex
		oct
	f. OPEN_PARENTHESIS
		(
	g. CLOSE_PARENTHESIS
		)
	h. OPERATION
		+
		-
		*
		/
	i. BASE_INDICATOR
		=
	j. COMPLEMENT_INDICATOR
		~
	k. COMMAND_INDICATOR
		#
	l. VARIABLE_INDICATOR
		:



