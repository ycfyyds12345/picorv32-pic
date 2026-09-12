#ifndef UART_H
#define UART_H
#include <stdint.h>
void uart_putc(char c);
int uart_getc(void);
void uart_write(const void *data,unsigned n);
void uart_read(void *data,unsigned n);
#endif
