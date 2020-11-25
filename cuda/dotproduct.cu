#include <stdio.h>

#define N 1024*1024
#define T 32


__global__ void dotproduct(float *a, float *b, float *result)
{
	int i = threadIdx.x;
	int j = blockIdx.x*T + i;
	__shared__ float temp[T];

	temp[i] = a[j] * b[j];
	printf("%d\n", blockIdx);

	__syncthreads();

	if (threadIdx.x == 0) {
		float sum = 0.0;
		for (i=0; i < T; i++) sum += temp[i];
		atomicAdd(result, sum);
	}
}


int main() {

	float *a = (float *) malloc(N*sizeof(float));
	float *b = (float *) malloc(N*sizeof(float));
	float c = 0.0;
	for (int i=0; i < N; i++)
		a[i] = b[i] = i;

	float *d_a, *d_b, *d_c;

	cudaMalloc((void **) &d_a, N*sizeof(float));
	cudaMalloc((void **) &d_b, N*sizeof(float));
	cudaMalloc((void **) &d_c, sizeof(float));
	cudaMemcpy(d_a, a, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_c, &c, sizeof(float), cudaMemcpyHostToDevice);

	dotproduct<<<N/T, T>>>(d_a, d_b, d_c);

	cudaMemcpy(&c, d_c, sizeof(float), cudaMemcpyDeviceToHost);

	printf("c = %f\n", c);

	exit(0);
}

