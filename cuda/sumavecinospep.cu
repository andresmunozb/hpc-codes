#include <stdio.h>

#define N 256
#define T 32
#define V 5


__global__ void sumavecinos(float *a, int n, float *b, int v)
{
    int tid = blockDim.x * blockIdx.x + threadIdx.x; // id global
    int size = n/64; // tamaño de la memoria compartida
    __shared__ float temp[size];
	for(int i=tid-v;i<=tid+v;i++)
	{
		if(i>=0 && i < n) // caso en que i esta dentro de los extremos
            temp[threadIdx.x] += a[i];
        else if(i<0) //caso que el i sea negativo
            temp[threadIdx.x] += a[n+(i%n)];
        else // caso en que i sea mayor que el tamaño del arreglo
            temp[threadIdx.x] += a[(i%n)-1];
    }
    __syncthreads(); // se sincronizan las hebras
    if (threadIdx.x == 0) // solamente la primera hebra copia a memoria global
		for (int i=0; i < size; i++)
            b[tid+i] = temp[i];
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
	cudaMemcpy(h_b, d_b, sizeof(float)*N, cudaMemcpyDeviceToHost);

	for (int i=0; i < N; i++)
		printf("%f\n", h_b[i]);

	cudaFree(d_a);
    cudaFree(d_b);
    free(h_a);
    free(h_b);

	exit(0);
}

