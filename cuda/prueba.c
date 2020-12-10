#include <stdio.h>

int main(){
    int N = 3; 
    printf("%d\n",N+(-1%N));
    printf("%d\n",(4%N)-1);

    return 0 ;
}