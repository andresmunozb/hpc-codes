#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define N 1027


int main()
{
    int *A = (int *)malloc(N * sizeof(int));

    for (int i = 0; i < N; i++)
    {
        A[i] = (rand() % (66666 - 0 + 1)) + 0;
        printf("%d ", A[i]);
    }
    printf("\n");

    int gmax = -1;
    int threads = 4;
    int blocksize = N / threads;
    #pragma omp parallel num_threads(threads) shared(gmax)
    {
        #pragma omp single
        for (int i = 0; i < N-(N%threads); i += blocksize)
        {
            #pragma omp task untied firstprivate(i)
            {
                int max = -1;
                for(int j=i;j<i+blocksize;j++){
                    if (A[j] > max)
                        max = A[j];
                }

                #pragma omp critical
                if (max > gmax)
                    gmax = max;
            }
        }
        #pragma omp single
        #pragma omp task untied
        {
            
            int max = -1;
            for(int j=N-(N%threads);j<N;j++){
                printf("j: %d\n",j);
                if (A[j] > max)
                    max = A[j];
            }
            printf("max: %d\n",max);
            printf("gmax: %d\n",gmax);
            #pragma omp critical
            if (max > gmax)
                gmax = max;
        }
        #pragma omp taskwait

    }
    printf("omp max = %d\n", gmax);

    free(A);
    return 0;
}