#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

// OMP  // 
int main()
{

    int N = 10;
    int hilos = 4;
    int vector[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    float sum = 0;
    float avg = 0;
    #pragma omp parallel shared(sum) num_threads(4)
    {
        int internalSum = 0;
        #pragma omp for schedule(static, 2)
        for (int i = 0; i < N; i++)
        {
            internalSum = internalSum + vector[i];
        }
        #pragma omp critical
            sum = sum + internalSum;
    }

    avg = sum / N;
    printf("Promedio: %f\n", avg);
   
}