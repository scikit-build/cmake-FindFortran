
#include <iostream>

#define lapack_complex_float std::complex<float>
#define lapack_complex_double std::complex<double>
#include <lapacke.h>

int main(int, char*[])
{
  std::cout << "Hello" << std::endl;

  return 0;
}
