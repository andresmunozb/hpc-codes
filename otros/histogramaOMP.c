#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <omp.h>
#define N 10
/* luego 6000  */
#define NG 10
/* luego 256   */

// OMP  // 

int minReduction(int arr[]){
    int max_val = arr[0];
    int index = 0;
    #pragma omp parallel for reduction(min : max_val)
    for(int i=0;i<N; i++)
    {
        printf("thread id = %d and i = %d", omp_get_thread_num(), i);
        if(arr[i] < max_val)
        {
            max_val = arr[i];  
        }
    }


    printf("\nmax_val = %d", max_val);
}

int minTask(int h[])
{
    int min;
    int indexMin;
    min = h[0];
    indexMin = 0;
    int minThreads;
    int indexMinThreads;
    #pragma omp parallel // shared(min, indexMin) private(minThreads,indexMinThreads) num_threads(2)
    {
        minThreads = min;
        indexMinThreads = indexMin;
        // #pragma omp for schedule(static, 2)
        // #pragma omp single nowait

        #pragma omp task untied
        {
            for (int i = 0; i < N/2; i++)
            {
                if (h[i] < minThreads)
                {
                    minThreads = h[i];
                    indexMinThreads = i;
                }
            }
        }
        #pragma omp task untied
        {
            for (int i = N/2 +1; i < N; i++)
            {
                if (h[i] < minThreads)
                {
                    minThreads = h[i];
                    indexMinThreads = i;
                }
            }
        }

        #pragma omp critical 
            if (minThreads < min)
            {
                min = minThreads;
                indexMin = indexMinThreads;
            }
        
    }
    printf("\nEl minimo es: %d\n", min);
    printf("Su pos es: %d\n", indexMin);
    return min;
}


int min(int h[])
{
    int min;
    int indexMin;
    min = h[0];
    indexMin = 0;
    int minThreads;
    int indexMinThreads;
    #pragma omp parallel shared(min, indexMin) private(minThreads,indexMinThreads) num_threads(2)
    {
        minThreads = min;
        indexMinThreads = indexMin;
        #pragma omp for schedule(static, 2)
        for (int i = 0; i < N; i++)
        {
            if (h[i] < minThreads)
            {
                minThreads = h[i];
                indexMinThreads = i;
            }
        }
        #pragma omp critical 
            if (minThreads < min)
            {
                min = minThreads;
                indexMin = indexMinThreads;
            }
        
    }
    printf("\nEl minimo es: %d\n", min);
    printf("Su pos es: %d\n", indexMin);
    return min;
}

int main()
{

    struct timeval t0, t1;
    double tej;
    int IMA[N][N], histo[NG], B[N], C[N];
    int i, j, tid, hmin, imin, spm = 0, x;
    // Inicializacion de variables (aleatorio)
    for (i = 0; i < N; i++)
        for (j = 0; j < N; j++)
            IMA[i][j] = rand() % NG;
    // se imprimen la matriz
    /*printf("\n  Matriz IMA ");
    for (i = 0; i < N; i++)
    {
        printf("\n");
        for (j = 0; j < N; j++)
            printf(" %3d", IMA[i][j]);
        printf("\n");
    }*/
    for (i = 0; i < NG; i++)
        histo[i] = 0; // toma de tiempos

    gettimeofday(&t0, 0); // 1. Calculo del histograma de IMA ???????

    #pragma omp parallel shared(histo) num_threads(4) // private(max) shared(gmax) num_threads(4)
    {
    #pragma omp for schedule(static, 2)
        for (int p = 0; p < N; p++)
        {
            for (int q = 0; q < N; q++)
            {
                int tid = omp_get_thread_num();
#pragma omp critical
                //printf("tid  = %d\n", tid);
                histo[IMA[p][q]]++;
            }
        }
    }
    printf("Histograma:\n");
    for (i = 0; i < NG; i++)
    {
        printf("%i ", histo[i]);
    }
    /*printf("\n  SPM = %d\n\n", spm); //
    tej = (t1.tv_sec - t0.tv_sec) + (t1.tv_usec - t0.tv_usec) / 1e6;
    printf("\n T. ejec. (serie) = %1.3f ms \n\n", tej * 1000); */
    int d = min(histo);
    d = minReduction(histo);
    return 0;
}