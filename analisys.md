
# Analysis

This is a rough first analysis on how to implement Computer Architecture's first project.

## Sketch of functionality

1. Example of basic functionality.

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