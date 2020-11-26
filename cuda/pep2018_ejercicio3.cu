__global__ void sumreduction(int *A, int N, int *sum ) {

    // Declare memoria compartida para el bloque
    __shared__ temp[blockDim.x];
    int NCopy = N; 

    int tid = blockDim.x*blockIDx.x + threadIdx.x; // ID global de la hebra
    
    // Cargar bloque de memoria compartida
    //Cada hebra carga su posición
    temp[threadIdx.x] = A[tid];

    // Sincronizar a que todas hayan terminado
    __syncthreads();

    // Reduccion iterativa dentro del bloque
    while(N > 1){
        if(threadIdx.x < N/2){
            temp[threadIdx.x] = temp[threadIdx.x] + temp[threadIdx.x + N/2)
        }
        __syncthreads();
        N = N/2;
    }

    for(int i = N ; i > 1; i/=2 ){
        if(threadIdx.x < i/2){
            temp[threadIdx.x] = temp[threadIdx.x] + temp[threadIdx.x + i/2)
        }
        __syncthreads();
    }


    // Reduccion total a memoria global sum
    if(threadIdx.x == 0){
        atomicAdd(&sum,temp[0]);
    }
}
    
    __host__ main(){
        
    }