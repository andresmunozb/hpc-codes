#include <stdio.h>

__global__ void suma(double* a, double* b, double* c, int n)
{
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    if (tid < n)
        c[tid] = a[tid] + b[tid];
}

__host__ int main(int argc,char* argv[])
{
    // Tamaño de los vectores
    int n = 1024*1024;

    double *h_a = (double*)malloc(n*sizeof(double));
    double *h_b = (double*)malloc(n*sizeof(double));
    double *h_c = (double*)malloc(n*sizeof(double));

    double *d_a;
    double *d_b;
    double *d_c;

    cudaMalloc(&d_a, n*sizeof(double));
    cudaMalloc(&d_b, n*sizeof(double));
    cudaMalloc(&d_c, n*sizeof(double));

    for(int i = 0; i < n; i++ ) {
        h_a[i] = 1.0;
        h_b[i] = 2.0;
    }

    cudaMemcpy( d_a, h_a, n*sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy( d_b, h_b, n*sizeof(double), cudaMemcpyHostToDevice);

    int blockSize, gridSize;
 
    blockSize = 128; //threads
    gridSize = (int)ceil((float)n/blockSize); //blocks
    printf("%i\n", gridSize);
    
    suma<<<gridSize, blockSize>>>(d_a, d_b, d_c,n);
    cudaMemcpy( h_c, d_c, n*sizeof(double), cudaMemcpyDeviceToHost );

    for(int i=0;i<n;i++)
        printf("%f ", h_c[i]);
    
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(h_a);
    free(h_b);
    free(h_c);
    return 0;
}