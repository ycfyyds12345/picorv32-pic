#include "uart.h"
#include "xpix.h"
#include "../uart.c"
#ifndef SERVER_PIXELS
#define SERVER_PIXELS 65536
#endif
#define A ((uint8_t*)0x10000)
#define B ((uint8_t*)0x20000)
#define X ((uint8_t*)0x50000)
#ifndef BASELINE
#define BASELINE 0
#endif
static uint32_t run(unsigned op,uint32_t a,uint32_t b,uint32_t t){
#if BASELINE
 uint32_t r=0;for(unsigned k=0;k<4;k++){unsigned x=(a>>(8*k))&255,y=(b>>(8*k))&255,z=0;
 switch(op){case 0:z=x>y?x-y:y-x;break;case 1:z=x>=y?255:0;break;case 2:z=x+y>255?255:x+y;break;case 3:z=x>y?x:y;break;case 4:z=x<y?x:y;break;case 5:z=(x>y?x-y:y-x)>=(t&255)?255:0;break;}r|=z<<(8*k);}return r;
#else
 switch(op){case 0:return px_absdiff8(a,b);case 1:return px_thresh8(a,b);case 2:return px_addus8(a,b);case 3:return px_maxu8(a,b);case 4:return px_minu8(a,b);default:return px_thresh8(px_absdiff8(a,b),t);}
#endif
}
int main(void){unsigned threshold=40;uart_write("XPIX1\n",6);
 for(;;){unsigned cmd=uart_getc();
 if(cmd==1||cmd==2){uint8_t*p=cmd==1?A:B;uart_putc('R');for(unsigned i=0;i<SERVER_PIXELS;i++){p[i]=uart_getc();if((i&255)==255||i==SERVER_PIXELS-1)uart_putc('K');}}
 else if(cmd>=0x10&&cmd<=0x15){for(unsigned i=0;i<SERVER_PIXELS/4;i++)((uint32_t*)X)[i]=run(cmd-0x10,((uint32_t*)A)[i],((uint32_t*)B)[i],threshold*0x01010101u);uart_putc('K');}
 else if(cmd==0x20){uart_write(X,SERVER_PIXELS);}
 else if(cmd==0x30){threshold=uart_getc();uart_putc('K');}
 else uart_putc('E');
 }
}
