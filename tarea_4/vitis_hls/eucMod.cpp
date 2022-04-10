#include "eucMod.h"
void eucDis(INPUT A[VECTOR_LENGTH], INPUT B[VECTOR_LENGTH], OUTPUT* C){
    #pragma HLS expression_balance
    #pragma HLS ARRAY_PARTITION variable=A type=complete  dim=1
    #pragma HLS ARRAY_PARTITION variable=B type=complete dim=1
    ap_uint<26> temp = 0;
    eachElement:for(int index = 0; index < VECTOR_LENGTH; index ++){
      #pragma HLS loop_tripcount max=1024
      #pragma HLS unroll factor=128
      if(A[index] > B[index]){
        temp += (A[index]-B[index])*(A[index]-B[index]);
      }
      else{
        temp += (B[index]-A[index])*(B[index]-A[index]);
      }
    }
    C[0] = hls::sqrt(temp);
}
