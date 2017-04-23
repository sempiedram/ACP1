
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
		All characters: 
		
		"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*/~= :#"

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
			= "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ*/~= :#"
			TODO: Decide if expressions can be passed to complement mode.
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

