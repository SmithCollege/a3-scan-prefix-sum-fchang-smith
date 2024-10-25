#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


__global__ void scan(int size, int* input, int* output) {
    int gidx = blockIdx.x * blockDim.x + threadIdx.x;
    if (gidx < size) {
        output[gidx] = input[gidx];
    }
    __syncthreads(); 

    for (int stride = 1; stride < size; stride *= 2) {
        if (gidx >= stride && gidx < size) {
            output[gidx] = output[gidx] + output[gidx - stride];
        }
        __syncthreads(); 
    }
}


double get_clock() {
 struct timeval tv; int ok;
 ok = gettimeofday(&tv, (void *) 0);
 if (ok<0) { printf("gettimeofday error"); }
 return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

int main() {
  int size[] = {100, 1000, 10000, 100000, 1000000};
  for (int j = 0; j < 5; j++) {
     // allocate memory
     int* input;
     int* output;
     int* d_input;
     int* d_output;
  
     input = (int*)malloc(sizeof(int) * size[j]);
     output = (int*)malloc(sizeof(int) * size[j]);
     cudaMalloc(&d_input, sizeof(int) * size[j]);
     cudaMalloc(&d_output, sizeof(int) * size[j]);

     // initialize inputs
     for (int i = 0; i < size[j]; i++) {
     	 input[i] = 1;
     }
  
     cudaMemcpy(d_input, input, sizeof(int) * size[j], cudaMemcpyHostToDevice);
  
     // do the scan
     int thread = 128;
     double t0 = get_clock();
  
     scan<<<(size[j]+thread-1)/thread, thread>>>(size[j], d_input, d_output);
     cudaDeviceSynchronize();
  
     double t1 = get_clock();
     printf("time for input size %d: %f s\n", size[j], t1-t0);
     cudaMemcpy(output, d_output, sizeof(int) * size[j], cudaMemcpyDeviceToHost);

     // free mem
     free(input);
     free(output);
     cudaFree(d_input);
     cudaFree(d_output);
  }

  return 0;
}
