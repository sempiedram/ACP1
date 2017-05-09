

# TODO List

This is a listing of the things that are still "to be done". Some are not necessary (marked as EXTRA), and the other ones are.

## List:

- EXTRA: Implement the power operation.
- Implement check_valid_arithmetic
    - Implement checking of parenthesis matching
- Show process of conversions.
    - Show bin -> bin
    - Show oct -> bin
    - Show dec -> bin
    - Show hex -> bin
    - Show bin -> bin
    - Show bin -> oct
    - Show bin -> dec
    - Show bin -> hex
- Show evaluation of operations.
    - Show addition process
    - Show subtraction process
    - Show multiplication process
    - Show division process
    - EXTRA: Show power process
- Add other commands
- Implement trim_unnecessary_bits function
    This function should trim unnecessary bits from binary number strings such
    as "1101101bin" -> "101101bin", or "000001001bin" -> "01001bin".
- Deal with expressions that result in negative numbers (because the conversion process takes the binary result as a big positive number).


		
convert_final_result
	string_a_bin_bin
		clone_string_into
	string_a_bin_oct
		convert_bin_str_number
		convert_number_to_base
			str_converting_number_base1
	string_a_bin_dec
		convert_bin_str_number
		convert_number_to_base
			str_converting_number_base1
	string_a_bin_hex
		convert_bin_str_number
		convert_number_to_base
			str_converting_number_base1
	str_result_of_conversion
