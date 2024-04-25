def verify_file_format(file_name):
    try:
        with open(file_name, 'r') as f:
            first_line = f.readline().strip()  # Read the first line and remove leading spaces
            numbers = first_line.split()  # Split the numbers by spaces

            # Check if there are exactly two numbers in the first line
            if len(numbers) != 2:
                raise ValueError("Incorrect format in the first line.")

            # Check if the two numbers are equal (because the board is a square)
            if numbers[0] != numbers[1]:
                raise ValueError("The two numbers in the first line are not equal.")

            expected_lines = int(numbers[0]) * int(numbers[1])
            expected_digits = 4

            # Check the following lines
            for i, line in enumerate(f, start=2):
                digits = line.split()
                if len(digits) != expected_digits:
                    raise ValueError(f"Error at line {i}: Incorrect number of digits.")
                for digit in digits:
                    if not (1 <= int(digit) <= 9):
                        raise ValueError(f"Error at line {i}: Digit {digit} is not between 1 and 9.")

            # Check if the total number of lines matches expected_lines + 1
            if i != expected_lines + 1:
                raise ValueError("Incorrect number of lines.")
            
            # The format is correct if the two numbers are equal, following lines are correct, and the number of lines matches expectations
            return True 
    except FileNotFoundError:
        raise FileNotFoundError("File not found.")

# Test the program with the file
test_file_name = "/home/ambre/INF432/game_file.txt"
try:
    if verify_file_format(test_file_name):
        print("The file format is correct.")
    else:
        print("The file format is incorrect.")
except Exception as e:
    print(f"Error: {e}")
    exit(1)  # Exit with an error code
