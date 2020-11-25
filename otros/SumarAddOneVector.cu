global_ void sumreduction(int *A, int N, int *sum ) {

// Declare memoria compartida para el bloque
_shared_ float temp[T];

int tid = blockDim.x*blockIDx.x + threadIdx.x; // ID global de la hebra

// Cargar bloque de memoria compartida
temp[tid] = A[tid]; 

// Sincronizar a que todas hayan terminado
__syncthreads(); // TB barrier

// Reduccion iterativa dentro del bloque
while(N > 1){
    if( tid < N/2 ) 
        temp[tid] = temp[tid] + temp[tid + N/2];
    __syncthreads();
    if(tid == 0)
        N = N/2;
}

// Reduccion total a memoria global sum
if(tid == 0)
    atomicAdd(sum, temp[0]); //atomic add to global memory
}

_host_ main(){
    
}