#include <stdio.h>

__global__ void print_kernel() {
    printf("Hello from block %d, thread %d\n", blockIdx.x, threadIdx.x);
}

__host__ int main() {
    print_kernel<<<10, 10>>>();
    cudaDeviceSynchronize();
}