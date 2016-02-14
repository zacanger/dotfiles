//My attempt at a fizzbuzz program. Wish me luck ;_;
#include <stdio.h>
int main(){
	printf("Listing numbers from 1 to 100.\nIf a number is a multiple of three, I will append 'Fizz' to it.\nIf it's a multiple of 5, I will append 'Buzz'.\nFor multiples of both 3 and 5, I will append 'FizzBuzz'.\n");
	int hundred;
	for (hundred = 1; hundred <= 100; hundred++){
		printf("%d", hundred);
		if (hundred % 3 == 0){
			printf("Fizz");
		}
		if (hundred % 5 == 0){
			printf("Buzz\n");
		}
		else{
			printf("\n");
		}
	}
	return 0;
}

