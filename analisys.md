
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

