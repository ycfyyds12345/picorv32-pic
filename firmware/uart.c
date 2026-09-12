#include "uart.h"
#define UART (*(volatile uint32_t*)0x02000008)
void uart_putc(char c){UART=(uint8_t)c;}
int uart_getc(void){int v;do{v=(int)UART;}while(v<0);return v;}
void uart_write(const void*data,unsigned n){const char*p=data;while(n--)uart_putc(*p++);}
void uart_read(void*data,unsigned n){uint8_t*p=data;while(n--)*p++=uart_getc();}
