
# Analysis

This is the second analysis for the first Computer Architecture project. This new analysis is because making a token data structure is too hard and it's not very productive. So, instead of using Token data structures, text will be interpreted as needed.

# New examples of operation:

	5+6
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

	10010bin-555oct=hex
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

	5+4*9=hex
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

	7-1bin
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

	7-(5+4)
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

	


