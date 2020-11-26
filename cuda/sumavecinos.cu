#include <stdio.h>

#define N 1024
#define T 32
#define V 5


__global__ void sumavecinos(float *a, int n, float *b, int v)
{
	int tid = blockDim.x * blockIdx.x + threadIdx.x;
	int sum=0;
	for(int i=tid-v;i<=tid+v;i++)
	{
		printf("%d\n",i);
		if(i>=0 && i < N)
			sum= sum + a[i];
	}
	b[tid] = sum;	
}


int main() {

	//MEMORIA HOST
	float *h_a = (float *) malloc(N*sizeof(float));
	float *h_b = (float *) malloc(N*sizeof(float));
	// SE INICIALIZA
	for (int i=0; i < N; i++)
		h_a[i] = i;

	//MEMORIA A DEVICE
	float *d_a, *d_b;
	cudaMalloc((void **) &d_a, N*sizeof(float));
	cudaMalloc((void **) &d_b, N*sizeof(float));
	cudaMemcpy(d_a, h_a, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, N*sizeof(float), cudaMemcpyHostToDevice);

	//LLAMADO A KERNEL
	sumavecinos<<<N/T, T>>>(d_a, N, d_b, V);

	//RESULADO DESDE DEVICE A HOST
	cudaMemcpy(h_b, d_b, sizeof(float), cudaMemcpyDeviceToHost);

	/*for (int i=0; i < N; i++)
		printf("%f\n", h_b[i]);*/

	cudaFree(d_a);
    cudaFree(d_b);
    free(h_a);
    free(h_b);

	exit(0);
}

