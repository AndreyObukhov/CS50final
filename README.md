```
Arbitrary-precision calculator
Andrew Obukhov
Harvard's CS50x February of 2022
Final Project
```
# main.c program
## Introduction
This program operates with arbitrary-precision integer numbers. As for now, present version can deal with four basic arithmetic operations: adding, subtracting, multiplication and division with remainder. From three command line arguments program receives two arbitrary-long integers **A** and **B** (floating point does not acceptable) and one char **c** with special sign of operation:
```
./main.c A B c
```
Program does not try to check all of the possible mistakes in the input, but it is supposed, that number of input command line elements will be equal exactly to three. Output is one line with calculated integer number. Program deals with sign. For instance:
```
./main.c 123456789 -10 +
```
gives:
```
123456779
```
as output.
The program consists of a number of functions, which I will briefly describe below.
## Declaration
Arbitrary-precision integer number defined in this program as follows:
```
const int Power = 4;
const int Base = 10000; // == 10^Power
const int Limit = 1000;

typedef struct LongNumber {
    int digits[Limit];
    int cells;
    bool positive;
    } number;
```
So, we are dealing with *base*, which equals to 10000, it is the biggest power of two-bytes-sized integer (less or equal to 32,767). Base can be changed to longest types without big changes in the program. *Limit* is the maximum number of *cells* we suppose to work with. Numeric value one cell can contain varies from 0 to 9999. We also have boolean variable for sign of a number. For example, 20!=2432902008176640000 will be
| i    | 1 | 2 | 3 | 4 | 5 |
| :--- | ---: | ---: | ---: | ---: | ---: |
|digits[i]| 0 | 7664 | 81 | 2902 | 243 |

with *positive = true* and *cells = 5*.
# Functions of the main.c
## Read
```
number read(const char *input);
```
Function reads arbitrary-long integer from the command line argument and returns integer with type *number*. Function applies *strlen* to the input string, reads it from the end and assigns significant values to array *output.digits[i]* from *i =1*, in parallel number of significant array values *output.cells* is increases. Maximum asymptotic computational complexity is **O(n)**, where n is the length of the input string.

## Write
```
void write(number input);
```
Prints any given structure with type **number**. Asymptotic complexity is **Θ(n)**, where n is the number of significant values in the array *input.digits*.

## Sum
```
number sum(const number A, const number B, const int shift);
```
Calculates sum of two arbitrary-long integers. Input integer variable *shift* gives the possibility to "summarise with shift". For instance,

|Input|A|B|Shift|
|:---|---:|---:|---:|
||17|25|1|

gives us output *C = 250017*. **From here on out, input variable *shift* will be used exactly in the same meaning.**

Maximum asymptotic complexity is **O(max(n, m) + shift)**, where n, m are lengths of arrays A and B.

## Compare
```
int compare(const number A, const number B, const int shift);
```
Function compares two arbitrary-long integers and returns:

 0 if A > B, 1 if A < B and 2 if A = B

Maximum asymptotic complexity is **O(max(n, m) + shift)**, where n, m are lengths of arrays A and B.

## Subtract and subtract2
```
number subtract(const number A, const number B, const int shift);
number subtract2(const number A, const number B);
```
Functions are used to subtract one  arbitrary-long integer from another, function **compare** is also used in the body of *subtract2*. For simplicity one big function was split to two smaller functions, both returns one arbitrary-long integer and must be applied only together. Maximum asymptotic complexity of *subtract* is **O(max(n, m) + shift)**, own asymptotic complexity of *subtract2* is **Θ(1)** (constant), but, as was mentioned, it uses functions *subtract* and *compare*, so max asymptotic complexity is about **O(2(max(n, m) + shift))**.

## Division, division2 and BinarySearch
```
number Remainder;
number Quotient;
long int BinarySearch(const number B, const int shift);
void division2(const number A, const number B);
void division(const number A, const number B);
```
Division is, as expected, the most difficult part of the program. There are three functions to implement this operation: *division*, *division2* and *BinarySearch*, which all use global variables *Remainder* and *Quotient* storing transitional results of calculations. I don't intend to go into details of the implementation, but will only briefly describe the main points. The first function only checks for dividing by zero, once runs *compare* and once *division2*. Second function based on classical "long division" algorithm with support of *BinarySearch* function to iterate one step of long division. It can be shown, that overall algorithm has maximum asymptotic complexity **O(n * m * log(Base) + n * n) for n <= m**, where n, m are numbers of digits (not cells!) in the integers.

## Multiplication and multInt
```
number multInt(const number A, const long int B);
number multiplication(const number A, const number B);
```
The last implemented operation is multiplication. There are two functions: *multInt*, which multiplies input arbitrary-long integer by variable with type long int. It has maximum asymptotic complexity **O(n)**, where n is number of digits in the input integer. Function *multiplication* uses *multInt* and *sum* to multiply A by each cell of B and add result to the product. Maximum asymptotic complexity is **O(nm + m * max(k, l))**, where n and m are numbers **of digits** in the integers, k and l are numbers **of cells** in the integer B in the input. Value 4 for Base implements that one cell contains four digits, so we can simplify complexity to **O(nm + m * max(n, m)/4)**.

## Calculate and main
```
number calculate(const number A, const number B, const char operation);
int main(int argc, const char *argv[])
```
Two last functions serves as a guide to a program which operation should be done. Function *calculate* also determines the sign of the output integer, program can easily deal with negative remainders. Asymptotic complexity for these functions is constant.

# start.py program
This additional program written in Python serves as "input client", simplifies input to the main.c and also shows synergy of using two different program languages. It uses python library *subprocess* to print two input strings directly to the terminal and receive output arbitrary-long integer as int type in Python. So we can execute computationally intensive calculations in the C (which is faster than in Python), but use Python for putting information into computer in the easy way.

Python code in *start.py* can be easily extended for operating with more complex problems like polynomial equations or, for instance, big factorials in Taylor series. For such examples this program was written.