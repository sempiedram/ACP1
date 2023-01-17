
# ACP1 - Arquitectura de Computadores, Proyecto 1

Este es el primer proyecto para el curso Arquitectura de Computadores, primer semestre del 2017, con el profesor Esteban Arias, de la escuela de computación.

Estudiantes: Kevin S. Piedra M. and Kristin N. Alvarado.

# Analysis

This "analysis" is a guide to help develop this project. A non-complete analysis had already been produced (called analysis.md), but that one used a token data structure that is too hard and it's not very productive. So, instead of using Token data structures, text will be interpreted as needed.

## Newer examples of operation:

This converts 0 into binary and then into decimal again:

	::> 0
		Processing: 0
		Preprocessed: 0
		Category: arithmetic operation
		Preprocessed (arithmetic): 0dec = dec
		Result base: dec
		To evaluate: 0dec
		
		Conversion of numbers:
			Conversion of 0dec to binary:
				0|2
				---
				0|0
			Result of conversion: 00bin
			
		Expression with numbers converted: 00bin
		
		Result of expression: 00bin
		
		Conversion of result to base: dec
			Conversion of 00bin to dec:
				(-0)*2^1 + 0*2^0 = 0 = 0
			Result of conversion: 0dec
		
		Final result: 0dec

This converts 56 into binary and then into decimal again:

	::> 56
		Processing: 56
		Preprocessed: 56
		Category: arithmetic operation
		Preprocessed (arithmetic): 56dec = dec
		Result base: dec
		To evaluate: 56dec
		
		Conversion of numbers:
			Conversion of 56dec to binary:
				56|2
				----
				 0|28|2
				   ----
				    0|14|2
					  ----
					   0|7|2
					     ---
						 1|3|2
						   ---
						   1|1|2
						     ---
							 1|0
			Result of conversion: 0111000bin
		
		New expression: 0111000bin
		
		No operations. End of evaluation.
		
		Result of operation: 0111000bin
		
		Conversion of result to base: dec
			Conversion of 0111000bin to dec:
				(-0)*2^6 + 1*2^5 + 1*2^4 + 1*2^3 + 0*2^2 + 0*2^1 + 0*2^0 = 0 + 32 + 16 + 8 = 56
			Result of conversion: 56dec
		
		Final result: 56dec

This only computes the sum of 2 and 3:

	::> 2+3
		Processing: 2+3
		Preprocessed: 2 + 3
		Category: arithmetic operation
		Preprocessed (arithmetic): 2dec + 3dec = dec
		Result base: dec
		To evaluate: 2dec + 3dec
		
		Conversion of numbers:
			Conversion of 2dec to binary:
				2|2
				---
				0|1|2
				  ---
				  1|0
			Result of conversion: 010bin
		
			Conversion of 3dec to binary:
				3|2
				---
				1|1|2
				  ---
				  1|0
			Result of conversion: 011bin
		
		New expression: 010bin + 011bin
		
		Evaluation:
			Next operation: +
				First operand: 010bin
				Second operand: 011bin
			
			Sum:
				   010
				+  011 =
				--------
				   100  Carry
				--------
				  0101  Result
			Result of sum: 0101bin
		
		New expression: 0101bin
		
		No operations. End of evaluation.
		
		Result of operation: 0101bin
		
		Conversion of result to base: dec
			Conversion of 0101bin to dec:
				(-0)*2^3 + 1*2^2 + 0*2^1 + 1*2^0 = 0 + 4 + 1 = 5
			Result of conversion: 5dec
		
		Final result: 5dec

This should collapse "+++" into a single "+":

	::> 17+++4
		Processing: 17+++4
		Preprocessed: 17 + + + 4
		Category: arithmetic operation
		Preprocessed (arithmetic): 17dec + 4dec = dec
		Result base: dec
		To evaluate: 17dec + 4dec
		
		Conversion of numbers:
			Conversion of 17dec to binary:
				17|2
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
			Result of conversion: 010001bin
		
			Conversion of 4dec to binary:
				4|2
				---
				0|2|2
				  ---
				  0|1|2
				    ---
					1|0
			Result of conversion: 0100bin
		
		New expression: 010001bin + 0100bin
		
		Evaluation:
			Next operation: +
				First operand: 010001bin
				Second operand: 0100bin
			
			Expand bits:
				010001bin -> 010001bin
				0100bin -> 000100bin
			
			Sum:
				   010001
				+  000100 =
				-----------
				   000000  Carry
				-----------
				  0010101  Result
			Result of sum: 010101bin
		
		New expression: 010101bin
		
		No operations. End of evaluation.
		
		Result of operation: 010101bin
		
		Conversion of result to base: dec
			Conversion of 010101bin to dec:
				(-0)*2^5 + 1*2^4 + 0*2^3 + 1*2^2 + 0*2^1 + 1*2^0 = 0 + 16 + 4 + 1 = 21
			Result of conversion: 21dec
		
		Final result: 21dec

This should collapse the "--" into a "+":

	::> 4--1
		Processing: 4--1
		Preprocessed: 4 - - 1
		Category: arithmetic operation
		Preprocessed (arithmetic): 4dec + 1dec = dec
		Result base: dec
		To evaluate: 4dec + 1dec
		
		Conversion of numbers:
			Conversion of 4dec to binary:
				4|2
				---
				0|2|2
				  ---
				  0|1|2
				    ---
					1|0
			Result of conversion: 0100bin
		
			Conversion of 1dec to binary:
				1|2
				---
				1|0
			Result of conversion: 01bin
		
		New expression: 0100bin + 01bin
		
		Evaluation:
			Next operation: +
				First operand: 0100bin
				Second operand: 01bin
			
			Expand bits:
				0100bin -> 0100bin
				01bin -> 0001bin
			
			Sum:
				   0100
				+  0001 =
				---------
				   0000  Carry
				---------
				  00101  Result
			Result of sum: 0101bin
		
		New expression: 0101bin
		
		No operations. End of evaluation.
		
		Result of operation: 0101bin
		
		Conversion of result to base: dec
			Conversion of 0101bin to dec:
				(-0)*2^3 + 1*2^2 + 0*2^1 + 1*2^0 = 0 + 4 + 1 = 5
			Result of conversion: 5dec
		
		Final result: 5dec

This should evaluate the two's complement of 2:

	::> -2
		Processing: -2
		Preprocessed: - 2
		Category: arithmetic operation
		Preprocessed (arithmetic): - 2dec = dec
		Result base: dec
		To evaluate: - 2dec
		
		Conversion of numbers:
			Conversion of 2dec to binary:
				2|2
				---
				0|1|2
				  ---
				  1|0
			Result of conversion: 010bin
		
		New expression: - 010bin
		
		Evaluation:
			Next operation: -
				First operand: 010bin
				No second operand.
			
				Inversion of bits: 101
				Add 1: 110
			Result of two's complement: 110bin
		
		New expression: 110bin
		
		No operations. End of evaluation.
		
		Result of operation: 110bin
		
		Conversion of result to base: dec
			Conversion of 110bin to dec:
				(-1)*2^2 + 1*2^1 + 0*2^0 = -4 + 2 = -2
			Result of conversion: -2dec
		
		Final result: -2dec

This should first evaluate -2, and then do the multiplication:

	::> 3*-2
		Processing: 3*-2
		Preprocessed: 3*-2
		Category: arithmetic operation
		Preprocessed (arithmetic): 3dec * - 2dec = dec
		Result base: dec
		To evaluate: 3dec * - 2dec
		
		Conversion of numbers:
			Conversion of 3dec to binary:
				3|2
				---
				1|1|2
				  ---
				  1|0
			Result of conversion: 011bin
			
			Conversion of 2dec to binary:
				2|2
				---
				0|1|2
				  ---
				  1|0
			Result of conversion: 010bin
		
		New expression: 011bin * - 010bin
		
		Evaluation:
			Next operation: -
				First operand: 010bin
			
				Inversion of bits: 101
				Add 1: 110
			Result of two's complement: 110bin
		
		New expression: 110bin
		
		No operations. End of evaluation.
		
		Result of operation: 110bin
		
		Conversion of result to base: dec
			Conversion of 110bin to dec:
				(-1)*2^2 + 1*2^1 + 0*2^0 = -4 + 2 = -2
			Result of conversion: -2dec
		
		Final result: -2dec

An invalid operation, the error should be displayed:

	::> 4**4
		Processing: 4**4
		Preprocessed: 4 * * 4
		Category: arithmetic operation
		Preprocessed (arithmetic): 4dec * * 4dec = dec
		Result base: dec
		To evaluate: 4dec * * 4dec

This collapses "---" into a "-":

	::> ---4
		Processing: ---4
		Preprocessed: - - - 4
		Category: arithmetic operation
		Preprocessed (arithmetic): - 4dec = dec
		Result base: dec
		To evaluate: 17dec - 4dec

This evaluates -2 first and then evaluates 4 * -2:

	::> 4*(-2)
		Processing: 4*(-2)
		Preprocessed: 4 * ( - 2 )
		Category: arithmetic operation
		Preprocessed (arithmetic): 4dec * ( - 2dec ) = dec
		Result base: dec
		To evaluate: 4dec * ( - 2dec )

This should collapse "---" into "-" and then evaluate 5 * -10:

	::> 5*(---10)
		Processing: 5*(---10)
		Preprocessed: 5 * ( - - - 10 )
		Category: arithmetic operation
		Preprocessed (arithmetic): 5dec * ( - 10dec ) = dec
		Result base: dec
		To evaluate: 5dec * ( - 10dec )

This converts 23 into binary and then converts the result into octal:
	
	::> 23=  oct
		Processing: 23=  oct
		Preprocessed: 23 = oct
		Category: arithmetic operation
		Preprocessed (arithmetic): 23dec = oct
		Result base: oct
		To evaluate: 23dec

This evaluates the sum and then converts the result into hexadecimal:
	
	::> 201  +  77=hex
		Processing: 201  +  77=hex
		Preprocessed: 201 + 77 = hex
		Category: arithmetic operation
		Preprocessed (arithmetic): 201dec + 77dec = hex
		Result base: hex
		To evaluate: 201dec + 77dec

This converts from octal to binary, and then into decimal:

	::> 234oct
		Processing: 234oct
		Preprocessed: 234oct
		Category: arithmetic operation
		Preprocessed (arithmetic): 234oct = dec
		Result base: dec
		To evaluate: 234oct
		
		Conversion of numbers:
			Conversion of 234oct to binary:
				Substitute every digit in the number for the equivalent bits:
				2 -> 010bin
				3 -> 011bin
				4 -> 100bin
			Result of conversion: 010011100bin
		
		New expression: 01001110bin
		
		No operations. End of evaluation.
		
		Result of operation: 01001110bin
		
		Conversion of result to base: dec
			Conversion of 01001110bin to dec:
				0*2^7 + 1*2^6 + 0*2^5 + 0*2^4 + 1*2^3 + 1*2^2 + 1*2^1 + 0*2^0 = 0 + 64 + 8 + 4 + 2 = 78
			Result of conversion: 78dec
		
		Final result: 78dec


## New examples of operation:

	::> 5+6
		Processing: 5+6
		Preprocessed: 5 + 6
		Category: arithmetic operation
		Preprocessed, arithmetic: 5dec + 6dec = dec
		Result base: dec
		To evaluate: 5dec + 6dec
		
		Evaluate: 5dec + 6dec
			Next operation: +
				First operand: 5dec
				Second operand: 6dec
				
			Evaluate: 5dec
				No operation, only convert:
				Conversion from 5dec to bin:
					5|2
					---
					1|2|2
					  ---
					  0|1|2
						---
						1|0
				Result of conversion: 0101bin
			Result of evaluation of 5dec: 0101bin
			
			Evaluate: 6dec
				No operation, only convert:
				Conversion from 6dec to bin:
					6|2
					---
					0|3|2
					  ---
					  1|1|2
						---
						1|0
				Result of conversion: 0110bin
			Result of evaluation of 6dec: 0110bin
			
			Operation +
				Expansion of operands:
					0101bin -> 0101bin
					0110bin -> 0110bin
				
				Sum of operands:
					   0101
					+  0110
				Result of sum:
					  01011bin

	::> 10010bin-555oct=hex
		10010bin - 555oct = hex
		find base:
			= hex
			hex
			-> 16
		first operation = -
			10010bin - 555oct
			10010bin to binary = 10010bin
			555oct to binary = 101101101bin
			
			10010bin - 101101101bin:
			 00000000000000000000000000010010bin
			-00000000000000000000000101101101bin=
			
			complemento de 00000000000000000000000101101101bin:
				00000000000000000000000101101101
				11111111111111111111111010010010
			= 11111111111111111111111010010011bin
			
			 00000000000000000000000000010010bin
			+11111111111111111111111010010011bin=
			 11111111111111111111111110100101bin
			
		11111111111111111111111110100101bin = hex

	::> 5+4*9=hex
		5 + 4 * 9 = hex
		find base:
			= hex
			-> 16
		5 + 4 * 9
		first operation = *
			4 * 9
			4 to binary = 0100bin
			9 to binary = 01001bin
			
			   0100
			* 01001 =
			------------------
			   0100
			 +   0
			 +   0
			 + 0100000=
			------------------
			  0100100bin
		5 + 0100100bin
		second operation = +
			5 to binary = 0101bin
			0100100bin to binary = 0100100bin
			
				 0101
			+ 0100100
			-------------------
			  0101001bin
		0101001bin
		end.

	::> 7-1bin
		Processing: "7-1bin"
		Preprocessed: "7 - 1bin"
		Category: Arithmetic
		Preprocessed, arithmetic: "7dec - 1bin = dec"
		Result base: dec
		To evaluate: "7dec - 1bin"
		
		Next operation in "7dec - 1bin" = '-'
			First operand: 7dec
			Second operand: 1bin
			
			Evaluation of 7dec:
				Base: dec
				Conversion 7dec to bin:
					7|2
					---
					1|3|2
					  ---
					  1|1
				Result of conversion: 111bin
			Evaluation of 1bin:
				Base: bin
				Conversion of 1bin to bin:
				Result of conversion: 1bin
			
			Expansion of bits in operands:
				1bin -> 1111bin
			
			Operation '-':
				Complement of second operand: 1111bin
					Inverse: 0000bin
					Plus one: 0001bin
					Result: 0001bin
			
				Sum of operands:
					  0111
					+ 1111
				Result of sum:
					10110bin -> 0110bin
		Result of operation: 0110bin
		
		New expression: "0110bin"
		
		No more operations.
		
		Result: 0110bin
		
		Result base conversion:
			Conversion of 0110bin to dec
				Powers of 2:
					2^1 = 2
					2^2 = 4
				Sum: 6dec
			Result of conversion: 6dec
		
		Result: 6dec

	::> 7-(5+4)
		Processing: "7-(5+4)"
		Preprocessed: "7 - ( 5 + 4 )"
		Category: arithmetic
		Preprocessed, arithmetic: "7dec - ( 5dec + 4dec ) = dec"
		Result base: dec
		To evaluate: "7dec - ( 5dec + 4dec )"
		
		Evaluation of "7dec - ( 5dec + 4dec )":
			Next operation in "7dec - ( 5dec + 4dec )" = '-'
			
			First operand: 7dec
			Second operand: ( 5dec + 4dec )
			
			Evaluation of: 7dec
				Conversion of 7dec to bin
					7|2
					---
					1|3|2
					  ---
					  1|1
				Result of conversion: 111bin
			
			Evaluation of: ( 5 + 4 )
		
		first operation  = +
			evaluate 5
			5 to bin = 0101bin
			evaluate 4
			4 to bin = 0100bin
			  0101
			+ 0100
			 01001bin
			
			end of evaluate ( 5 + 4 )
		
			second operator = 01001bin
			
			0111bin - 01001bin
			
			expand bits:
				0111bin -> 00111bin
			
			complement of second operator:
				01001bin
				10110bin
				10111bin
			
			   00111bin
			+  10111bin
			 0011110bin
			
			Result: 0011110bin
		Result: 0011110bin

	


