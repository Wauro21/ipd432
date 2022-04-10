#ifndef EUCMOD_H
#define EUCMOD_H

#define VECTOR_LENGTH 1024

//#include <cmath>
#include "ap_int.h"
#include "hls_math.h"
#include <cstdint>

typedef uint8_t INPUT;
typedef ap_uint<26> OUTPUT;
/*
A function that takes two vectors of length VECTOR_LENGTH and computes the Euclidian distance between the individual values of each vector.
*/
void eucDis(INPUT A[VECTOR_LENGTH], INPUT B[VECTOR_LENGTH], OUTPUT* C);

#endif
