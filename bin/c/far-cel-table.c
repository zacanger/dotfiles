#include <stdio.h>

main(){
  float fahr, celsius;
  int lower, upper, step;

  lower = 0;
  upper = 300;
  step  = 20;

  fahr = lower;

  printf("FAHRENHEIT*******CELSIUS\n");

  while (fahr <= upper) {
    celsius = (5.0/9.0) * (fahr-32.0);
    printf("%8.0f %10.1f\n", fahr, celsius);
    fahr = fahr + step;
  }

  lower = 0;
  upper = 100;
  step  = 5;

  celsius = lower;

  printf("CELSIUS*******FAHRENHEIT\n");

  while (celsius <= upper) {
    fahr = ((9.0/5.0) * celsius) + 32.0;
    printf("%8.0f %10.1f\n", celsius, fahr);
    celsius = celsius + step;
  }

}

