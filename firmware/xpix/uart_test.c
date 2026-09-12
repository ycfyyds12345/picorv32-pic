#include "uart.h"
#include "../uart.c"
int main(void){uart_write("XPix\n",5);for(unsigned i=0;i<4;i++){unsigned x=uart_getc();if(x!=(unsigned[]){0,0x7f,0x80,0xff}[i])return 2;((volatile unsigned char*)0x10000)[i]=x;uart_putc(((volatile unsigned char*)0x10000)[i]);}return 1;}
