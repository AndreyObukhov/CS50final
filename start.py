import subprocess

# Read first arbitrary-long integer.
A = int(input())

# Boolean variable turns True if required arithmetical operatio is found.
OperationNotFound = True

# We asume a number of different options of the user's input.
while OperationNotFound:
    operation = input()
    if operation.lower() in ["plus", '+', "sum", "addition"]:
        operation = '+'
        OperationNotFound = False
    elif operation.lower() in ["minus", '-', "subtraction"]:
        operation = '-'
        OperationNotFound = False
    elif operation.lower() in ["multiplication", 'x', '*', '.', "mult", "by", "times"]:
        operation = "\*"
        OperationNotFound = False
    elif operation.lower() in ["quotient", "divided by", "div", 'd']:
        operation = 'd'
        OperationNotFound = False
    elif operation.lower() in ["remainder", "modulo", '%', 'm']:
        operation = 'm'
        OperationNotFound = False
    else:
        print("No such operation! Try again!")

# Read second arbitrary-long integer.
B = int(input())

# Run main.c to the obtained input.
subprocess = subprocess.Popen(f"./main {A} {B} {operation}", shell=True, stdout=subprocess.PIPE)
# Put output as an integer.
output = int(subprocess.stdout.read())
# Write output to the terminal.
print(f"Answer is {output}.")