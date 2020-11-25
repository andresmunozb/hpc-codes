#include <stdio.h>

__global__ void traspose(double *A, int N)
{
    int i, j;
	i = blockDim.x*blockIdx.x + threadIdx.x;  // global index x (horizontal)
	j = blockDim.y*blockIdx.y + threadIdx.y;  // global index y (vertical)

	float temp;
	if (i > j) {
		temp = A[j*N + i];
		A[j*N + i] = A[i*N + j];
		A[i*N + j] = temp;
	}
}

__host__ void matrix_print(double *m, int n)
{
    for (int i=0;i<n;i++){
        for(int j=0;j<n;j++)
            printf("%f ", m[i*n + j]);
        printf("\n");
    }  
}

__host__ int main(int argc,char* argv[])
{
    // Tamaño de los vectores
    int n = 8;

    double *h_a = (double*)malloc(n*n*sizeof(double));
    double *d_a;
    cudaMalloc(&d_a, n*n*sizeof(double));

    for(int i = 0; i < n*n; i++ )
        h_a[i] = i;
    matrix_print(h_a,n);
    printf("\n");
    cudaMemcpy( d_a, h_a, n*n*sizeof(double), cudaMemcpyHostToDevice);

    int blockSize, gridSize;
 
    blockSize = 4; //threads
    gridSize = (int)ceil((float)n/blockSize); //blocks
    //printf("%i\n", gridSize);
    
    traspose<<<gridSize, blockSize>>>(d_a, n);

    cudaMemcpy( h_a, d_a, n*n*sizeof(double), cudaMemcpyDeviceToHost );

    matrix_print(h_a,n);
    
    cudaFree(d_a);
    free(h_a);
    return 0;
}

