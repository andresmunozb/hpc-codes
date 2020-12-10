#include <omp.h>
#include <stdio.h>
int main()
{
    int flag[2] = {0, 0};
    int final[2] = {8, 6};
    int me, you;
    #pragma omp parallel num_threads(2) private(me, you) shared(flag, final)
    {
        me = omp_get_thread_num(); // ES 0 O 1 
        flag[me] = 1; // flag[0]= 1 - flag[1] = 1
        #pragma omp flush(flag)
        you = (me == 0) ? 1 : 0; // NUNCA CAMBIA 
        while (flag[you] == 0); // BARRERA
        
        final[me] = final[you] + me + 1; // 7 
        //final[0] = final[1] + 0 + 1; // 7
        //final[1] = final[0] + 1 + 1; // 10
        printf("me: %d, final[me]: %d\n",me,final[me]);
    }
    return 0;
}