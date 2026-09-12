#include <stdint.h>
#include "xpix.h"
#ifndef THRESHOLD
#define THRESHOLD 40
#endif
#define N 65536
#define A ((uint8_t*)0x10000)
#define B ((uint8_t*)0x20000)
#define S ((uint8_t*)0x30000)
#define P ((uint8_t*)0x40000)
#define X ((uint8_t*)0x50000)
static unsigned threshold=THRESHOLD;
static void putc_debug(char c){*(volatile unsigned*)0x10000000=(unsigned)c;}
static void text(const char*s){while(*s)putc_debug(*s++);}
static void number(unsigned v){char b[12];unsigned i=0;do{b[i++]='0'+v%10;v/=10;}while(v);while(i)putc_debug(b[--i]);}
static unsigned cycle(void){unsigned v;__asm__ volatile("rdcycle %0":"=r"(v)::"memory");return v;}
static unsigned instret(void){unsigned v;__asm__ volatile("rdinstret %0":"=r"(v)::"memory");return v;}
__attribute__((noinline)) static void scalar_abs(void){for(unsigned i=0;i<N;i++){unsigned a=A[i],b=B[i];S[i]=a>b?a-b:b-a;}}
__attribute__((noinline)) static void packed_abs(void){for(unsigned i=0;i<N/4;i++){uint32_t aa=((uint32_t*)A)[i],bb=((uint32_t*)B)[i],r=0;{unsigned a=(aa>>0)&255,b=(bb>>0)&255;r|=(uint32_t)(a>b?a-b:b-a)<<0;}{unsigned a=(aa>>8)&255,b=(bb>>8)&255;r|=(uint32_t)(a>b?a-b:b-a)<<8;}{unsigned a=(aa>>16)&255,b=(bb>>16)&255;r|=(uint32_t)(a>b?a-b:b-a)<<16;}{unsigned a=(aa>>24)&255,b=(bb>>24)&255;r|=(uint32_t)(a>b?a-b:b-a)<<24;}((uint32_t*)P)[i]=r;}}
__attribute__((noinline)) static void xpix_abs(void){uint32_t t=threshold*0x01010101u;(void)t;for(unsigned i=0;i<N/4;i++){uint32_t a=((uint32_t*)A)[i],b=((uint32_t*)B)[i];((uint32_t*)X)[i]=px_absdiff8(a,b);}}
__attribute__((noinline)) static void scalar_thresh(void){for(unsigned i=0;i<N;i++){unsigned a=A[i],b=B[i];S[i]=a>=b?255:0;}}
__attribute__((noinline)) static void packed_thresh(void){for(unsigned i=0;i<N/4;i++){uint32_t aa=((uint32_t*)A)[i],bb=((uint32_t*)B)[i],r=0;{unsigned a=(aa>>0)&255,b=(bb>>0)&255;r|=(uint32_t)(a>=b?255:0)<<0;}{unsigned a=(aa>>8)&255,b=(bb>>8)&255;r|=(uint32_t)(a>=b?255:0)<<8;}{unsigned a=(aa>>16)&255,b=(bb>>16)&255;r|=(uint32_t)(a>=b?255:0)<<16;}{unsigned a=(aa>>24)&255,b=(bb>>24)&255;r|=(uint32_t)(a>=b?255:0)<<24;}((uint32_t*)P)[i]=r;}}
__attribute__((noinline)) static void xpix_thresh(void){uint32_t t=threshold*0x01010101u;(void)t;for(unsigned i=0;i<N/4;i++){uint32_t a=((uint32_t*)A)[i],b=((uint32_t*)B)[i];((uint32_t*)X)[i]=px_thresh8(a,b);}}
__attribute__((noinline)) static void scalar_addus(void){for(unsigned i=0;i<N;i++){unsigned a=A[i],b=B[i];S[i]=(unsigned)a+b>255?255:a+b;}}
__attribute__((noinline)) static void packed_addus(void){for(unsigned i=0;i<N/4;i++){uint32_t aa=((uint32_t*)A)[i],bb=((uint32_t*)B)[i],r=0;{unsigned a=(aa>>0)&255,b=(bb>>0)&255;r|=(uint32_t)((unsigned)a+b>255?255:a+b)<<0;}{unsigned a=(aa>>8)&255,b=(bb>>8)&255;r|=(uint32_t)((unsigned)a+b>255?255:a+b)<<8;}{unsigned a=(aa>>16)&255,b=(bb>>16)&255;r|=(uint32_t)((unsigned)a+b>255?255:a+b)<<16;}{unsigned a=(aa>>24)&255,b=(bb>>24)&255;r|=(uint32_t)((unsigned)a+b>255?255:a+b)<<24;}((uint32_t*)P)[i]=r;}}
__attribute__((noinline)) static void xpix_addus(void){uint32_t t=threshold*0x01010101u;(void)t;for(unsigned i=0;i<N/4;i++){uint32_t a=((uint32_t*)A)[i],b=((uint32_t*)B)[i];((uint32_t*)X)[i]=px_addus8(a,b);}}
__attribute__((noinline)) static void scalar_max(void){for(unsigned i=0;i<N;i++){unsigned a=A[i],b=B[i];S[i]=a>b?a:b;}}
__attribute__((noinline)) static void packed_max(void){for(unsigned i=0;i<N/4;i++){uint32_t aa=((uint32_t*)A)[i],bb=((uint32_t*)B)[i],r=0;{unsigned a=(aa>>0)&255,b=(bb>>0)&255;r|=(uint32_t)(a>b?a:b)<<0;}{unsigned a=(aa>>8)&255,b=(bb>>8)&255;r|=(uint32_t)(a>b?a:b)<<8;}{unsigned a=(aa>>16)&255,b=(bb>>16)&255;r|=(uint32_t)(a>b?a:b)<<16;}{unsigned a=(aa>>24)&255,b=(bb>>24)&255;r|=(uint32_t)(a>b?a:b)<<24;}((uint32_t*)P)[i]=r;}}
__attribute__((noinline)) static void xpix_max(void){uint32_t t=threshold*0x01010101u;(void)t;for(unsigned i=0;i<N/4;i++){uint32_t a=((uint32_t*)A)[i],b=((uint32_t*)B)[i];((uint32_t*)X)[i]=px_maxu8(a,b);}}
__attribute__((noinline)) static void scalar_min(void){for(unsigned i=0;i<N;i++){unsigned a=A[i],b=B[i];S[i]=a<b?a:b;}}
__attribute__((noinline)) static void packed_min(void){for(unsigned i=0;i<N/4;i++){uint32_t aa=((uint32_t*)A)[i],bb=((uint32_t*)B)[i],r=0;{unsigned a=(aa>>0)&255,b=(bb>>0)&255;r|=(uint32_t)(a<b?a:b)<<0;}{unsigned a=(aa>>8)&255,b=(bb>>8)&255;r|=(uint32_t)(a<b?a:b)<<8;}{unsigned a=(aa>>16)&255,b=(bb>>16)&255;r|=(uint32_t)(a<b?a:b)<<16;}{unsigned a=(aa>>24)&255,b=(bb>>24)&255;r|=(uint32_t)(a<b?a:b)<<24;}((uint32_t*)P)[i]=r;}}
__attribute__((noinline)) static void xpix_min(void){uint32_t t=threshold*0x01010101u;(void)t;for(unsigned i=0;i<N/4;i++){uint32_t a=((uint32_t*)A)[i],b=((uint32_t*)B)[i];((uint32_t*)X)[i]=px_minu8(a,b);}}
__attribute__((noinline)) static void scalar_motion(void){for(unsigned i=0;i<N;i++){unsigned a=A[i],b=B[i];S[i]=(a>b?a-b:b-a)>=threshold?255:0;}}
__attribute__((noinline)) static void packed_motion(void){for(unsigned i=0;i<N/4;i++){uint32_t aa=((uint32_t*)A)[i],bb=((uint32_t*)B)[i],r=0;{unsigned a=(aa>>0)&255,b=(bb>>0)&255;r|=(uint32_t)((a>b?a-b:b-a)>=threshold?255:0)<<0;}{unsigned a=(aa>>8)&255,b=(bb>>8)&255;r|=(uint32_t)((a>b?a-b:b-a)>=threshold?255:0)<<8;}{unsigned a=(aa>>16)&255,b=(bb>>16)&255;r|=(uint32_t)((a>b?a-b:b-a)>=threshold?255:0)<<16;}{unsigned a=(aa>>24)&255,b=(bb>>24)&255;r|=(uint32_t)((a>b?a-b:b-a)>=threshold?255:0)<<24;}((uint32_t*)P)[i]=r;}}
__attribute__((noinline)) static void xpix_motion(void){uint32_t t=threshold*0x01010101u;(void)t;for(unsigned i=0;i<N/4;i++){uint32_t a=((uint32_t*)A)[i],b=((uint32_t*)B)[i];((uint32_t*)X)[i]=px_thresh8(px_absdiff8(a,b),t);}}
static unsigned measure(void (*f)(void),unsigned *ni){unsigned c0=cycle(),i0=instret();f();unsigned i1=instret(),c1=cycle();*ni=i1-i0;return c1-c0;}
int main(void){
 unsigned failed=0;
 text("workload,scalar_cycles,packed_cycles,xpix_cycles,scalar_instret,packed_instret,xpix_instret,mismatch_packed,mismatch_xpix\n");
{unsigned si,pi,xi,sc,pc,xc,mp=0,mx=0;
 sc=measure(scalar_abs,&si);pc=measure(packed_abs,&pi);xc=measure(xpix_abs,&xi);
 for(unsigned i=0;i<N;i++){mp+=S[i]!=P[i];mx+=S[i]!=X[i];}
 failed|=mp|mx;
 text("abs,");number(sc);putc_debug(',');number(pc);putc_debug(',');number(xc);putc_debug(',');number(si);putc_debug(',');number(pi);putc_debug(',');number(xi);putc_debug(',');number(mp);putc_debug(',');number(mx);putc_debug('\n');
 *(volatile unsigned*)0x10000000=0x80000000u|0;
 }
{unsigned si,pi,xi,sc,pc,xc,mp=0,mx=0;
 sc=measure(scalar_thresh,&si);pc=measure(packed_thresh,&pi);xc=measure(xpix_thresh,&xi);
 for(unsigned i=0;i<N;i++){mp+=S[i]!=P[i];mx+=S[i]!=X[i];}
 failed|=mp|mx;
 text("thresh,");number(sc);putc_debug(',');number(pc);putc_debug(',');number(xc);putc_debug(',');number(si);putc_debug(',');number(pi);putc_debug(',');number(xi);putc_debug(',');number(mp);putc_debug(',');number(mx);putc_debug('\n');
 *(volatile unsigned*)0x10000000=0x80000000u|1;
 }
{unsigned si,pi,xi,sc,pc,xc,mp=0,mx=0;
 sc=measure(scalar_addus,&si);pc=measure(packed_addus,&pi);xc=measure(xpix_addus,&xi);
 for(unsigned i=0;i<N;i++){mp+=S[i]!=P[i];mx+=S[i]!=X[i];}
 failed|=mp|mx;
 text("addus,");number(sc);putc_debug(',');number(pc);putc_debug(',');number(xc);putc_debug(',');number(si);putc_debug(',');number(pi);putc_debug(',');number(xi);putc_debug(',');number(mp);putc_debug(',');number(mx);putc_debug('\n');
 *(volatile unsigned*)0x10000000=0x80000000u|2;
 }
{unsigned si,pi,xi,sc,pc,xc,mp=0,mx=0;
 sc=measure(scalar_max,&si);pc=measure(packed_max,&pi);xc=measure(xpix_max,&xi);
 for(unsigned i=0;i<N;i++){mp+=S[i]!=P[i];mx+=S[i]!=X[i];}
 failed|=mp|mx;
 text("max,");number(sc);putc_debug(',');number(pc);putc_debug(',');number(xc);putc_debug(',');number(si);putc_debug(',');number(pi);putc_debug(',');number(xi);putc_debug(',');number(mp);putc_debug(',');number(mx);putc_debug('\n');
 *(volatile unsigned*)0x10000000=0x80000000u|3;
 }
{unsigned si,pi,xi,sc,pc,xc,mp=0,mx=0;
 sc=measure(scalar_min,&si);pc=measure(packed_min,&pi);xc=measure(xpix_min,&xi);
 for(unsigned i=0;i<N;i++){mp+=S[i]!=P[i];mx+=S[i]!=X[i];}
 failed|=mp|mx;
 text("min,");number(sc);putc_debug(',');number(pc);putc_debug(',');number(xc);putc_debug(',');number(si);putc_debug(',');number(pi);putc_debug(',');number(xi);putc_debug(',');number(mp);putc_debug(',');number(mx);putc_debug('\n');
 *(volatile unsigned*)0x10000000=0x80000000u|4;
 }
{unsigned si,pi,xi,sc,pc,xc,mp=0,mx=0;
 sc=measure(scalar_motion,&si);pc=measure(packed_motion,&pi);xc=measure(xpix_motion,&xi);
 for(unsigned i=0;i<N;i++){mp+=S[i]!=P[i];mx+=S[i]!=X[i];}
 failed|=mp|mx;
 text("motion,");number(sc);putc_debug(',');number(pc);putc_debug(',');number(xc);putc_debug(',');number(si);putc_debug(',');number(pi);putc_debug(',');number(xi);putc_debug(',');number(mp);putc_debug(',');number(mx);putc_debug('\n');
 *(volatile unsigned*)0x10000000=0x80000000u|5;
 }
return failed?2:1;}
