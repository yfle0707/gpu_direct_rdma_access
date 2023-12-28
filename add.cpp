#include <hip/hip_runtime.h>
//#include <iostream>

// Kernel to perform element-wise addition of two arrays
__global__ void addArrays(float* result, const float* a, const float* b, size_t size) {
    size_t idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size) {
        result[idx] = a[idx] + b[idx];
	printf("Hello from block %d, thread %d, idx %d, result %f\n", hipBlockIdx_x, hipThreadIdx_x, idx, result[idx]);

    }
}

__global__ void hipKernel() {
    printf("Hello from HIP kernel!\n");
}

int main() {
    // Specify the size of the arrays
    const size_t dataSize = 1000;

    // Allocate host memory for arrays
    float* hostA = (float*)malloc(dataSize * sizeof(float));
    float* hostB = (float*)malloc(dataSize * sizeof(float));
    float* hostResult = (float*)malloc(dataSize * sizeof(float));

    // Initialize host data
    for (size_t i = 0; i < dataSize; ++i) {
        hostA[i] = static_cast<float>(i);
        hostB[i] = static_cast<float>(i * 2);
    }

    // Allocate device memory for arrays
    float* deviceA;
    float* deviceB;
    float* deviceResult;
    hipMalloc((void**)&deviceA, dataSize * sizeof(float));
    hipMalloc((void**)&deviceB, dataSize * sizeof(float));
    hipMalloc((void**)&deviceResult, dataSize * sizeof(float));

    // Copy data from host to GPU
    hipMemcpy(deviceA, hostA, dataSize * sizeof(float), hipMemcpyHostToDevice);
    hipMemcpy(deviceB, hostB, dataSize * sizeof(float), hipMemcpyHostToDevice);

    // Launch the kernel with one block and 256 threads per block
    dim3 blockSize(256);
    dim3 gridSize((dataSize + blockSize.x - 1) / blockSize.x);
    addArrays<<<gridSize, blockSize>>>(deviceResult, deviceA, deviceB, dataSize);

    // Copy result from GPU to host
    hipMemcpy(hostResult, deviceResult, dataSize * sizeof(float), hipMemcpyDeviceToHost);

    // Verify the result
    for (size_t i = 0; i < dataSize; ++i) {
        if (hostResult[i] != hostA[i] + hostB[i]) {
//            std::cerr << "Verification failed at index " << i << std::endl;
            break;
        }
    }

//    std::cout << "Sum computation on GPU successful!" << std::endl;

            hipKernel<<<1, 1>>>();

    // Free allocated memory
    free(hostA);
    free(hostB);
    free(hostResult);
    hipFree(deviceA);
    hipFree(deviceB);
    hipFree(deviceResult);

    return 0;
}

