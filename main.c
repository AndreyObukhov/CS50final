// Arbitrary-precision calculator
// Andrew Obukhov
// Harvard's CS50x 2022
// Final Project


#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>
#include <stdlib.h>

/* We will store two input numbers as arrays of integers, one integer must be in (0, Base),
where Base is predetermined constant and some power of 10 */
const int Power = 4;
const int Base = 10000; // == 10^Power
const int Limit = 1000;

typedef struct LongNumber
{
    int digits[Limit];
    int cells;
    bool positive;
} number;

number Remainder;
number Quotient;

number read(const char *input);
void write(number input);
number sum(const number A, const number B, const int shift);
int compare(const number A, const number B, const int shift);
number multInt(const number A, const long int B);
number multiplication(const number A, const number B);
number subtract(const number A, const number B, const int shift);
number subtract2(const number A, const number B);
long int BinarySearch(const number B, const int shift);
void division2(const number A, const number B);
void division(const number A, const number B);
number calculate(const number A, const number B, const char operation);

int main(int argc, const char *argv[])
{
    if (argc != 4)
    {
        printf("Must be exact two integers and one sign of operation in the input.\n");
        return (1);
    }

    number A = read(argv[1]);
    number B = read(argv[2]);
    write(calculate(A, B, argv[3][0]));
    return (0);
}

number read(const char *input)
{
    number output;
    if (input[0] == '-')
    {
        output.positive = false;
    }
    else
    {
        output.positive = true;
    }

    if ((input[0] == '0') || (input[1] == '0' && input[0] == '-'))
    {
        output.digits[1] = 0;
        output.positive = true;
        output.cells = 1;
        return output;
    }

    /* "Facultative" declaration of the entire array by zeros,
    which does not affect the othe parts of the program. */
    for (int i = 1; i <= Limit; i++)
    {
        output.digits[i] = 0;
    }

    int j = 1;
    output.digits[1] = 0;
    int len = strlen(input);
    output.cells = 1;
    for (int i = len; i > 0; i--)
    {
        if (input[i - 1] == '-')
            break;
        output.digits[j] += (input[i - 1] - '0') * pow(10, (len - i) % Power);
        if ((len != i) && ((len - i + 1) % Power == 0) && (i != 1))
        {
            j++;
            output.cells++;
            output.digits[j] = 0;
        }
    }
    return output;
}

void write(number input)
{
    if (!input.positive)
    {
        printf("-");
    }

    // Prints the first cell in the array
    printf("%i", input.digits[input.cells]);
    // Prints every other
    for(int i = input.cells - 1; i > 0; i--)
    {
        /* Output works only for Power == 4! For another power:
        correct number '4' in next line to an appropriate number. */
        printf("%04i", input.digits[i]);
    }
    printf("\n");
}

number sum(const number A, const number B, const int shift)
{
    number C;
    C.positive = true;
    int tmp;

    for (int i = 1; i <= Limit; i++)
    {
        C.digits[i] = 0;
    }
    if (A.cells > B.cells + shift)
    {
        tmp = A.cells;
    }
    else
    {
        tmp = B.cells + shift;
    }

    for (int i = 1; i < tmp + 1; i++)
    {
        if (i > shift)
        {
            C.digits[i + 1] = div((C.digits[i] + A.digits[i] + B.digits[i - shift]), Base).quot;
            C.digits[i] = div((C.digits[i] + A.digits[i] + B.digits[i - shift]), Base).rem;
        }
        else
        {
            C.digits[i] = A.digits[i];
        }
    }

    if (C.digits[tmp + 1] == 0)
    {
        C.cells = tmp;
    }
    else
    {
        C.cells = tmp + 1;
    }
    return C;
}

/* Function compares two numbers an returns:
0 if A > B,
1 if A < B
2 if A = B */
int compare(const number A, const number B, const int shift)
{
    if (A.cells > B.cells + shift)
        return 0;

    if (A.cells < B.cells + shift)
        return 1;

    int i = A.cells;
    while ((i > shift) && (A.digits[i] == B.digits[i - shift]))
    {
        i--;
    }

    if (i == shift)
     {
         for (int j = 1; j <= shift; j++)
         {
             if (A.digits[j] > 0)
             {
                 return 0;
             }
         }
         return 2;
     }
     else return A.digits[i] < B.digits[i - shift];
}

number multInt(const number A, const long int B)
{
    number C;
    C.positive = true;
    for (int i = 1; i <= Limit; i++)
    {
        C.digits[i] = 0;
    }

    if (B == 0)
    {
        C.cells = 1;
        return C;
    }

    for (int i = 1; i <= A.cells; i++)
    {
        C.digits[i + 1] = div(A.digits[i] * B + C.digits[i], Base).quot;
        C.digits[i] = div(A.digits[i] * B + C.digits[i], Base).rem;
    }

    if (C.digits[A.cells + 1] > 0)
    {
        C.cells = A.cells + 1;
    }
    else
    {
        C.cells = A.cells;
    }
    return C;
}

number multiplication(const number A, const number B)
{
    number C, Q, M;
    C.positive = true;
    for (int i = 1; i <= Limit; i++)
    {
        C.digits[i] = 0;
    }

    // Multiplying by zero
    if ((A.cells + A.digits[1] == 1) || (B.cells + B.digits[1] == 1))
    {
        C.cells++;
        return C;
    }

    for (int i = 1; i <= Limit; i++)
    {
        M.digits[i] = 0;
    }

    for (int i = 1; i <= B.cells; i++)
    {
        Q = multInt(A, B.digits[i]);
        M = sum(C, Q, i-1);
        C = M;
    }
    return C;
}

number subtract(const number A, const number B, const int shift)
{
    number C = A;
    int k, j;

    for (int i = 1; i <= B.cells; i++)
    {
        C.digits[i + shift] -= B.digits[i];
        j = i;
        while ((C.digits[j + shift] < 0) && (j <= C.cells))
        {
            C.digits[j + shift] += Base;
            C.digits[j + shift + 1]--;
            j++;
        }
    }
    k = C.cells;
    while ((k > 1) && (C.digits[k] == 0))
    {
        k--;
    }

    C.cells = k;
    return C;
}

long int BinarySearch(const number B, const int shift)
{
    unsigned Down = 0;
    unsigned Up = Base;
    number C;
    C.positive = true;

    // Binary search starts
    while (Up - 1 > Down)
    {
        C = multInt(B, div(Up + Down, 2).quot);

        switch ( compare(Remainder, C, shift) ) {
            case 0: Down = div(Down + Up, 2).quot;
                    break;
            case 1: Up = div(Down + Up, 2).quot;
                    break;
            case 2: Up = div(Down + Up, 2).quot;
                    Down = Up;
                    break;
        }
    }
    C = multInt(B, div(Up + Down, 2).quot);

    if (compare(Remainder, C, 0) == 0)
    {
        Remainder = subtract(Remainder, C, shift);
    }
    else
    {
        C = subtract(C, Remainder, shift);
        Remainder = C;
    }

    return div(Up + Down, 2).quot;
}

void division2(const number A, const number B)
{
    // Remainder and quotient are global variables!
    int shift;
    Remainder = A;
    shift = A.cells - B.cells;
    if (compare(A, B, shift) == 1)
        shift--;

    Quotient.cells = shift + 1;

    while (shift >= 0)
    {
        Quotient.digits[shift + 1] = BinarySearch(B, shift);
        shift--;
    }
}

void division(const number A, const number B)
{
    // Remainder and Quotient are global variables!

    Remainder.positive = true;
    Quotient.positive = true;
    Quotient.cells = 0;
    Remainder.cells = 0;

    for (int i = 1; i <= Limit; i++)
    {
        Remainder.digits[i] = 0;
        Quotient.digits[i] = 0;
    }

    if ((B.cells == 1) && (B.digits[1] == 0))
    {
        printf("Error: dividing by zero\n");
        exit(1);
    }

    switch ( compare(A, B, 0) )
    {
        case 0: division2(A, B);
                break;
        case 1: Quotient.cells++;
                Remainder = A;
                break;
        case 2: printf("Numbers are the same\n");
                Remainder.cells++;
                Quotient.cells = 1;
                Quotient.digits[1] = 1;
                break;
    }
}

number subtract2(const number A, const number B)
{
    number C;
    if (compare(A, B, 0) != 1)
    {
        C = subtract(A, B, 0);
        C.positive = true;
        return C;
    }
    else
    {
        C = subtract(B, A, 0);
        C.positive = false;
        return C;
    }
}

number calculate(const number A, const number B, const char operation)
{
    number D;
    switch ( operation )
    {
        case '+':
            // +++ and ---
            if (A.positive == B.positive)
            {
                D = sum(A, B, 0);
                D.positive = A.positive;
                return D;
            }
            // ++-
            if (A.positive && !B.positive)
                return subtract2(A, B);
            // -++
            if (!A.positive && B.positive)
            {
                D = subtract2(A, B);
                //Changes sigh of an output
                if (D.positive)
                    D.positive = false;
                else
                    D.positive = true;
                return D;
            }
            break;
        case '-':
            // +--
            if (A.positive && !B.positive)
                return sum(A, B, 0);
            // ---
            if (!A.positive && !B.positive)
            {
                D = subtract2(A, B);
                //Changes sigh of an output
                if (D.positive)
                    D.positive = false;
                else
                    D.positive = true;
                return D;
            }
            // --+
            if (!A.positive && B.positive)
            {
                D = sum(A, B, 0);
                D.positive = false;
                return D;
            }
            // +-+
            if (A.positive && B.positive)
                return subtract(A, B, 0);
            break;
        case '*':
            D = multiplication(A, B);
            if (A.positive == B.positive)
                D.positive = true;
            else
                D.positive = false;
            return D;
            break;
        case 'd':
            division(A, B);
            D = Quotient;
            if (A.positive == B.positive)
                D.positive = true;
            if (!A.positive && B.positive)
                D.positive = false;
            if (A.positive && !B.positive)
                D.positive = false;
            return D;
            break;
        case 'm':
            division(A, B);
            D = Remainder;
            if (A.positive && B.positive)
                D.positive = true;
            if (!A.positive && !B.positive)
                D.positive = false;
            if (!A.positive && B.positive)
                D.positive = false;
            if (A.positive && !B.positive)
                D.positive = true;
            return D;
            break;
    }
    return A;
}