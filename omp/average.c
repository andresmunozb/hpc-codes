#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define N 1024

int main()
{
    int *A = (int *)malloc(N * sizeof(int));

    for (int i = 0; i < N; i++)
    {
        A[i] = (rand() % (66666 - 0 + 1)) + 0;
        printf("%d ", A[i]);
    }
    printf("\n");

    int gsum = 0;

    #pragma omp parallel shared(gsum) num_threads(4)
    {
        int sum = 0; //variable local apra cada hebra
        #pragma omp for schedule(dynamic, 8)
        for (int i = 0; i < N; i++)
            sum += A[i];

        #pragma omp critical
            gsum += sum;
    }
    printf("omp average = %d\n", gsum/N);

    // check with sequential code
    gsum = 0;
    for (int i = 0; i < N; i++)
        gsum += A[i];
    printf("sequential average = %d\n", gsum/N);
    free (A);

    return 0;
}