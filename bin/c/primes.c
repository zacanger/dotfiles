//Why does this print out all prime numbers below 1000000?

#include <stdio.h>

#define n 1000000

int i=1,j=n,p[n*2];
int main(){
  while(i<n)j<n?p[j+=i]++:p[++i]||printf("%d\n",j=i);
}
