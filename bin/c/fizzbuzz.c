/* kinda fizzbuzz i think */

#include <stdio.h>

int main(){
  printf("Fizzbuzz from 1 through 100.\n");
	int hundred;
	for (hundred = 1; hundred <= 100; hundred++){
		printf("%d", hundred);
		if (hundred % 3 == 0) {
			printf("Fizz");
		} if (hundred % 5 == 0) {
			printf("Buzz\n");
		} else {
			printf("\n");
		}
	}
	return 0;
}

