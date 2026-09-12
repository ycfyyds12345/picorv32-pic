#include "xpix.h"
int main(void) {
 if(px_absdiff8(0xff0080c8,0x00ff8064)!=0xffff0064) return 2;
 if(px_thresh8(0xff81807f,0x80808080)!=0xffffff00) return 3;
 if(px_addus8(0xff808000,0xff807f00)!=0xffffff00) return 4;
 if(px_maxu8(0xff0080c8,0x00ff8064)!=0xffff80c8) return 5;
 if(px_minu8(0xff0080c8,0x00ff8064)!=0x00008064) return 6;
 __asm__ volatile(".insn r 0x2b,0,0,x0,%0,%0"::"r"(123));
 unsigned r;__asm__ volatile("addi %0,x0,0":"=r"(r));if(r) return 7;
 for(unsigned i=0;i<32;i++) if(px_addus8(i,1)!=i+1) return 8;
 return 1;
}
