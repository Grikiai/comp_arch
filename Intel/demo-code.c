 /*
 * Illustrates how to call the sum function we wrote in assembly language.
 */


#include <stdio.h>
#include <stdint.h>


extern void writeToOutput(char* input, FILE* output);
extern char* format;
#define N 256


int main() {

     printf("labas");
     /* file names */
     FILE* fin = fopen("input.csv", "r");
     FILE* fout = fopen("output.txt", "w");

     char data[N*N]={0};
     fread(data, N*N, 1, fin);

     /* open first file,  keep track of columns, convert asci to num in 3RD column, sort stack, read ......*/

     writeToOutput(data, fout);

     fclose(fin);
     fclose(fout);

    return 0;
}
