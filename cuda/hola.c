void main (){
int i, b, c;
b = 0;
#pragma omp parallel for private(i,a,b)
for (i = 0; i < 10; i++) {
b++;
a = b+i;
}
c = a + b;
}