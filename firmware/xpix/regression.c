#include <stdint.h>
static volatile uint32_t *const mem=(uint32_t*)0x60000;
static void out(char c){*(volatile unsigned*)0x10000000=c;}
static void num(unsigned n){char s[12];unsigned i=0;do{s[i++]='0'+n%10;n/=10;}while(n);while(i)out(s[--i]);}
static unsigned cyc(void){unsigned v;__asm__ volatile("rdcycle %0":"=r"(v)::"memory");return v;}
static unsigned ins(void){unsigned v;__asm__ volatile("rdinstret %0":"=r"(v)::"memory");return v;}
int main(void){unsigned c=cyc(),n=ins(),sum=0;for(unsigned i=0;i<1024;i++)mem[i]=(i*17)^0x1234;for(unsigned i=0;i<1024;i++){unsigned x=mem[i];sum+=(x&1)?x+3:x-1;}unsigned ni=ins()-n,cc=cyc()-c;
 const char*s="REGULAR,";while(*s)out(*s++);num(cc);out(',');num(ni);out(',');num(sum);out('\n');
 return sum==9150976?1:2;}
