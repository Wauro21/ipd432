#include <iostream>
#include <fstream>
#include "eucMod.h"
#define REL_TOL 1.0
int main(void){
  std::cout << "Running C++ Simulation!" << std::endl;

  // Vectors
  INPUT A[VECTOR_LENGTH], B[VECTOR_LENGTH];
  OUTPUT C, D;
  double D_temp;

  // Read goldenReference

  std::ifstream reference("goldenreference.csv");
  if(!reference.is_open()){
    std::cout << "Referencia no pudo ser abierta!" << std::endl;
    exit(1);
  }
  int line_counter = 0;
  std::string temp_line;
  while(std::getline(reference, temp_line,',')){
    if(line_counter == VECTOR_LENGTH){
      break;
    }
    else{
      A[line_counter] = (uint8_t) stoi(temp_line);
      std::getline(reference, temp_line);
      B[line_counter] = (uint8_t) stoi(temp_line);
      D_temp += (A[line_counter] - B[line_counter])*(A[line_counter] - B[line_counter]);
      line_counter += 1;
    }
  }
  D = (uint16_t) sqrt(D_temp);
  reference.close();
  // Calculate vector:
  eucDis(A,B,&C);
  // Compute error:
  float direct_error = abs(D-C);
  float relative_error = 100*direct_error/D;
  std::cout << "-----------------------------------" << std::endl;
  std::cout << "Valor esperado: " << D << std::endl;
  std::cout << "Valor calculado: " << C << std::endl;
  std::cout << "Diferencia directa: " << direct_error << std::endl;
  std::cout << "Diferencia relativa: " << relative_error << std::endl;
  std::cout << "-----------------------------------" << std::endl;
  if(direct_error > REL_TOL){
    std::cout << "[ERROR] FAILED! Difference exceeds tolerance" << std::endl;
  }
  else{
    std::cout << "PASSED!" << std::endl;
  }
  std::cout << "-----------------------------------" << std::endl;
}
