#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

double get_clock() {
 struct timeval tv; int ok;
 ok = gettimeofday(&tv, (void *) 0);
 if (ok<0) { printf("gettimeofday error"); }
 return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main() {
  int size[] = {100, 1000, 10000, 100000, 1000000};
  for (int k = 0; k < 5; k++) {
      // allocate memory
      int* input = malloc(sizeof(int) * size[k]);
      int* output = malloc(sizeof(int) * size[k]);

      // initialize inputs
      for (int i = 0; i < size[k]; i++) {
        input[i] = 1;
       }

      // do the scan
      double t0 = get_clock();
      for (int i = 0; i < size[k]; i++) {
        int value = 0;
        for (int j = 0; j <= i; j++) {
          value += input[j];
        }
        output[i] = value;
      }
      double t1 = get_clock();
      printf("time for input size %d: %f s\n", size[k], t1-t0);

      // free mem
      free(input);
      free(output);
  }
  return 0;
}
