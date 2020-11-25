 

//a) Numero de hebras = N

__global__ simpleHist(int *A, int N, int *H, int M) {

	int gid = blockId.x*blockDim.x + threadId.x; // global ID

	atomicAdd(&H[A[gid]], 1);  // muy importante. Es Sección Crítica
}

// b) Numero de hebras > N

__global__ simpleHist(int *A, int N, int *H, int M) {

	int gid = blockId.x*blockDim.x + threadId.x; // global ID

	if (gid < N)  // por definición 0 <= H[j] <= M-1
	   atomicAdd(&H[A[gid]], 1);  // muy importante. Es Sección Crítica
}

// c) Numero de hebras < N

__global__ simpleHist(int *A, int N, int *H, int M) {

	int gid = blockId.x*blockDim.x + threadId.x; // global ID
	int fulloffset = gridDim.x*blockDim.x;       // numero total de hebras
	
	int i = gid;
	while (i < N)  {
	   atomicAdd(&H[A[gid]], 1);  // muy importante. Es Sección Crítica
	   i += fulloffset;           // full stride asegura única posición en A[]
	}
}


//2) Con shared mem

//*** Solucion 1 ***
// --------------------

_global__ simpleHist(int *A, int N, int *H, int M) {

	int gid = blockId.x*blockDim.x + threadId.x; // global ID
	int lid = threadId.x // local ID

	__shared__ int sharedH[M] // se acepta mem dinámica

	sharedH[lid] = 0; // muy importante. H[] está inicializado pero no sharedH[]	
	atomicAdd(&sharedH[A[gid]], 1); // Sección crítica

	__synchthreads();

	if (lid == 0) // solo hebra 0 del bloque reduce
	   for (int i=0; i < M; i++)
		atomicAdd(&H[i], sharedH[i]);
}



/*
*** Solucion 2 ***
--------------------
*/
__global__ simpleHist(int *A, int N, int *H, int M) {

	int gid = blockId.x*blockDim.x + threadId.x; // global ID
	int lid = threadId.x // local ID

	__shared__ int sharedA[blockdim.x] // se acepta mem dinámica
	
	sharedA[lid] = A[gid]; // Cargar memoria compartida!!!!

	int Hlocal[M]; // El histograma es local

	if (lid == 0) 
	   for (int i=0; i < M; i++) Hlocal[i] = 0; // muy importante. H[] está inicializado pero no Hlocal[];

	atomicAdd(&Hlocal[sharedA[lid]], 1);  // muy importante. Es Sección Crítica

	__synchthreads();

	if (lid == 0) // solo hebra 0 del bloque reduce
	   for (int i=0; i < M; i++)
		atomicAdd(&H[i], Hlocal[i]);
}


/*
3) OpenMP


*** Solución 1 ***
------------------
*/

void Hist(int *A, int N, int *H, int M, int n) {


        #pragma omp parallel num_threads(n)   // por defecto todo compartido
	{
	    #pragma omp for 
	    for (int i=0; i < N; i++)
		#pragma omp atomic
			H[A[i]]++;   // Esto es mas ficiente que sección crítica
	}	
}

/*

*** Solución 2 ***
------------------

*/
void Hist(int *A, int N, int *H, int M, int n) {


        #pragma omp parallel num_threads(n)   // por defecto todo compartido
	{
	    #pragma omp for 
	    for (int i=0; i < N; i++)
		#pragma omp critical
			H[A[i]]++;   
	}	
}

/*
4) Amdahl's Law

a)
Esta ley dice que el speedup de una aplicación paralela, DE CARGA FIJA, está limitado
por la porción secuencial de dicha aplicación. Es decir no importa si tenemos infinito número de 
procesadores  para acelerar la aplicación, el speedup siempre está cotado, de la siguiente
manera

Sea f la porción de trabajo secuencial de una aplicación, es decir aquella parte del código
que no puede paralelizarse, y se 1-f la parte paralelizable. Luego, según Amdahl el Speedup
está acotado por

S <= 1/f 

independientemente del número de procesadores.

b) Según lo anterior f = 1/4 y 1-f = 3/4. Si se usa un procesador 3 veces más rápico, entonces
la porción paralelizable se reduce a 

		1 x 3       1
                -   -   =   -
		3   4       4

Luego, la porciones de la aplicación son  1/4 + 1/  = 1/2.  Por lo tanto, el Speedup es 2, es decir
se ejecuta dos veces más rápido.

c) Según a)

	    1
        S=  -   = 4
           1/4


*/ 