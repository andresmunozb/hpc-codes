#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define N 1024
#define MAX_V 255
int main()
{
    int *A = (int *)malloc(N * sizeof(int));
    int *histogram = (int *)malloc(MAX_V  * sizeof(int));
    for (int i = 0; i < N; i++)
        A[i] = (rand() % (MAX_V -1 - 0 + 1)) + 0;

    #pragma omp parallel
    {
        int i, histogram_private[MAX_V];
        for (i = 0; i < MAX_V; i++)
            histogram_private[i] = 0;

        #pragma omp for schedule(dynamic, 8)
        for (i = 0; i < N; i++)
            histogram_private[A[i]]++;

        #pragma omp critical
        {
            for (i = 0; i < MAX_V; i++)
                histogram[i] += histogram_private[i];
        }
    }
    for (int i = 0; i < MAX_V; i++)
         printf("%d ", histogram[i]);
    int sum = 0;
    for (int i = 0; i < MAX_V; i++)
         sum+=histogram[i];
    printf("sum: %d\n",sum);
    free(A);
    free(histogram);
    return 0;
}