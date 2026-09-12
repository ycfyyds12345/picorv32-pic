#ifndef XPIX_H
#define XPIX_H
#include <stdint.h>
#define PX_FN(name,op) static inline uint32_t name(uint32_t a,uint32_t b) { uint32_t r; __asm__ volatile (".insn r 0x2b, " #op ", 0, %0, %1, %2" : "=r"(r):"r"(a),"r"(b));return r; }
PX_FN(px_absdiff8,0)
PX_FN(px_thresh8,1)
PX_FN(px_addus8,2)
PX_FN(px_maxu8,3)
PX_FN(px_minu8,4)
#endif
