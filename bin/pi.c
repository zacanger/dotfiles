//Why does this print (an approximation to) pi?

#include <stdio.h>
int main(){
  unsigned s=1,p=0,k,n=1<<16;
  while(k=s%n*(s%n),s++)p+=(k+s/n*(s/n)>=k);
  printf("%f\n",4.0*p/n/n);
  return 0;
}
