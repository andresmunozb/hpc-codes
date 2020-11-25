
// SIN CUDA // 
#define N 10000000

void vector_add(float *out, float *a, float *b, int n) {
    for(int i = 0; i < n; i++){
        out[i] = a[i] + b[i];
    }
}

int main(){
    float *a, *b, *out; 

    // Allocate memory
    a   = (float*)malloc(sizeof(float) * N);
    b   = (float*)malloc(sizeof(float) * N);
    out = (float*)malloc(sizeof(float) * N);

    // Initialize array
    for(int i = 0; i < N; i++){
        a[i] = 1.0f; b[i] = 2.0f;
    }

    // Main function
    vector_add(out, a, b, N);
}

// CON CUDA /// 
__global__ void vector_add(float *out, float *a, float *b, int n) {
    int i = blockDim.x*blockIDx.x + threadIdx.x; // global tid
         if (id < n)
            out[i] = a[i] + b[i];
    }
}