#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define SIZE 128

__global__ void scan(int size, int* input, int* output){
  int gidx = blockIdx.x*blockDim.x + threadIdx.x;
  output[gidx] = 0;
  for (int i  = 0; i < gidx+1; i++) {
      output[gidx] += input[i];
  }
}

double get_clock() {
 struct timeval tv; int ok;
 ok = gettimeofday(&tv, (void *) 0);
 if (ok<0) { printf("gettimeofday error"); }
 return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main() {
  // allocate memory
  int* input;
  int* output;
  int* d_input;
  int* d_output;
  
  input = (int*)malloc(sizeof(int) * SIZE);
  output = (int*)malloc(sizeof(int) * SIZE);
  cudaMalloc(&d_input, sizeof(int) * SIZE);
  cudaMalloc(&d_output, sizeof(int) * SIZE);

  // initialize inputs
  for (int i = 0; i < SIZE; i++) {
    input[i] = 1;
  }
  
  cudaMemcpy(d_input, input, sizeof(int) * SIZE, cudaMemcpyHostToDevice);
  
  // do the scan
  int thread = 32;
  double t0 = get_clock();
  
  scan<<<(SIZE+SIZE-1)/thread, thread>>>(SIZE, d_input, d_output);
  cudaDeviceSynchronize();
  
  double t1 = get_clock();
  printf("time for input size %d: %f s\n", SIZE, t1-t0);

  // check results
  cudaMemcpy(output, d_output, sizeof(int) * SIZE, cudaMemcpyDeviceToHost);

  for (int i = 0; i < SIZE; i++) {
    printf("%d ", output[i]);
  }
  printf("\n");

  // free mem
  free(input);
  free(output);
  cudaFree(d_input);
  cudaFree(d_output);

  return 0;
}
