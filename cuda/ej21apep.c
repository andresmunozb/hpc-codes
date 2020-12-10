
#include <omp.h>

void main()
{
    int c;
#pragma omp parallel
    {
        int a = 0;                   // se declara la a de manera local
        int b = 0;                   // se declara b de manera local
        int local_c = 0;             // suma parcial
#pragma omp for schedule(dynamic, 2) // for dinamico
        for (int i = 0; i < 10; i++)
        {
            b++;
            a = b + i;
            local_c = a + b; // se actualiza la variable local
        }
#pragma omp critial
        c += local_c; // se actualiza la variable global
                      // a partir de la local
    }
}

void main()
{
    int S, Slocal;
#pragma omp parallel shared(S) private(Slocal)
    {
#pragma omp master
        {
            S = 10;
        }
#pragma omp barrier // se espera a todas las hebras \
                    // para que tengan el mismo valor
        Slocal = S;
        ... // contin´ua c´odigo que usa Slocal
    }
}

void main()
{
    int S, Slocal;
#pragma omp parallel shared(S) private(Slocal)
    {
#pragma omp master
        {
            S = 10;
        }
        // cualquiera de las otras hebras puede pasar
        // sin que el S cambie antes de asignar  la variable S
        // por lo tanto quedaria con basura la variable S
        Slocal = S;
        ... // contin´ua c´odigo que usa Slocal
    }
}

int i, j; // el valor j es sobrescrito por todas las hebras
// ya que es global produciendo incosistencias en la ejecucion.
#pragma omp parallel for
for (i = 0; i < 10; i++)
    for (j = 0; j < 10; j++) // error al sobrescribir j
    {
        a[i][j] = compute(i, j)
    }

int i; // i es global
#pragma omp parallel for
for (i = 0; i < 10; i++)
{          // cada hebra recibe diferentes i
           // es decir nunca se repiten los i en la distribucion del for
    int j; // se defino un j por cada i
    for (j = 0; j < 10; j++)
    {
        a[i][j] = compute(i, j)
    }
}

int main()
{
    int flag[2] = {0, 0};
    int final[2] = {8, 6};
    int me, you
    #pragma omp parallel num_threads(2) private(me, you) shared(flag, final)
    {
        me = omp_get_thread_num();
        flag[me] = 1;
    #pragma omp flush(flag)
        you = (me == 0) ? 1 : 0;
        while (flag[you] == 0)
            ; // esperar al otro
        // error en esta linea ya que se modifica
        // el valor que se utiliza por la otra hebra
        final[me] = final[you] + me + 1;
    }
}


int main()
{
    int flag[2] = {0, 0};
    int final[2] = {8, 6};
    int me, you
    #pragma omp parallel num_threads(2) private(me, you) shared(flag, final)
    {
        me = omp_get_thread_num();
        flag[me] = 1;
    #pragma omp flush(flag)
        you = (me == 0) ? 1 : 0;
        while (flag[you] == 0)
            ; // esperar al otro
        // error en esta linea ya que se modifica
        // el valor que se utiliza por la otra hebra
        mi_final = final[you] + me + 1;
        #pragma omp barrier // Se espera a que las dos
        // hebras ejecuten el codigo 
        final[me] = mi_final;
    }
}