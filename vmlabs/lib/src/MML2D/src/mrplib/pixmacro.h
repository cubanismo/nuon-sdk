
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* PIX Macros
 * rwb 5/26/98
 * Used to to do direct Pixel manipulation from a C program.
 */
#ifndef pixmacro_h
#define pixmacro_h

#define kTrans 0xFF000000
 
#define Reserve( n0, n1, n2, n3 )		\
register int junk##n0 asm ( "r"#n0 );		\
register int junk##n1 asm ( "r"#n1 );		\
register int junk##n2 asm ( "r"#n2 );		\
register int junk##n3 asm ( "r"#n3 );

#define ClrPix( Spix )				\
asm ( "nop \n sub_p "#Spix", "#Spix : : );

#define AddPix( Spix, Sresult )			\
asm ( "nop \n add_p "#Spix", "#Sresult :: );

#define MulPix( Spix, Vscalar )			\
asm ( "nop \n mul_p %0, "#Spix", >>#30, "#Spix : : "r" (Vscalar) );

#define MulPixInt( Spixin, Vscalar, Spixout )			\
asm ( "nop \n mul_p %0, "#Spixin", >>#16, "#Spixout : : "r" (Vscalar) );
	
#define DotPix( Sreg, Svec, Spix )		\
asm ( "nop \n dotp "#Svec", "#Spix",>>#30, "#Sreg :: );

#define GetDRam( Spix, Sxy ) 			\
asm ( "nop \n ld_p ("#Sxy"), "#Spix" \n nop " ::);

#define GetDRamPP( Spix, Sxy, Sx ) 		\
asm ( "nop \n ld_p ("#Sxy"), "#Spix" " ::);		\
asm ( "addr #1<<16, "#Sx" " ::);	

#define GetDRamMM( Spix, Sxy, Sx ) 		\
asm ( "nop \n ld_p ("#Sxy"), "#Spix" " ::);		\
asm ( "addr #-1<<16, "#Sx ::);		

#define GetDRamInd( Spix, Sreg ) 		\
asm ( "nop \n ld_p ("#Sreg"), "#Spix" \n nop " ::);

#define PutDRam( Spix, Sxy ) 			\
asm ( "nop \n st_p "#Spix", ("#Sxy")" ::);

#define PutDRamPP( Spix, Sxy, Sx ) 		\
asm ( "nop \n st_p "#Spix", ("#Sxy")" ::);	\
asm ( "addr #1<<16, "#Sx ::);	
	
#define PutDRamMM( Spix, Sxy, Sx ) 		\
asm ( "nop \n st_p "#Spix", ("#Sxy")" ::);	\
asm ( "addr #-1<<16, "#Sx ::);		

#define GetDRamPPDec( Spix, Sxy, Sx, Sctr )	\
asm ( "nop \n ld_p ("#Sxy"), "#Spix" " ::);		\
asm ( "addr #1<<16, "#Sx" " ::);			\
asm ("dec "#Sctr : :);

#define PutDRamPPDec( Spix, Sxy, Sx, Sctr )	\
asm ( "nop \n st_p "#Spix", ("#Sxy")" ::);	\
asm ( "addr #1<<16, "#Sx ::);			\
asm ("dec "#Sctr : :);
	
#define GetDRamMMDec( Spix, Sxy, Sx, Sctr )	\
asm ( "nop \n ld_p ("#Sxy"), "#Spix" " ::);		\
asm ( "addr #-1<<16, "#Sx" " ::);		\
asm ("dec "#Sctr : :);
	
#define PutDRamMMDec( Spix, Sxy, Sx, Sctr )	\
asm ( "nop \n st_p "#Spix", ("#Sxy")" ::);	\
asm ( "addr #-1<<16, "#Sx ::);			\
asm ("dec "#Sctr : :);

#define ClrPixAlpha( Spix )				\
asm ( "nop \n sub_sv "#Spix", "#Spix : : );

#define AddPixAlpha( Spix, Sresult )			\
asm ( "nop \n add_sv "#Spix", "#Sresult :: );

#define MulPixAlpha( Spix, Vscalar )			\
asm ( "nop \n mul_sv %0, "#Spix", >>#30, "#Spix : : "r" (Vscalar) );

#define MulPixIntAlpha( Spixin, Vscalar, Spixout )			\
asm ( "nop \n mul_sv %0, "#Spixin", >>#16, "#Spixout : : "r" (Vscalar) );

#define GetDRamAlpha( Spix, Sxy ) 			\
asm ( "nop \n ld_pz ("#Sxy"), "#Spix" \n nop " ::);

#define GetDRamAlphaPP( Spix, Sxy, Sx ) 		\
asm ( "nop \n ld_pz ("#Sxy"), "#Spix" " ::);	\
asm ( "addr #1<<16, "#Sx" " ::);	
	
#define GetDRamAlphaMM( Spix, Sxy, Sx ) 		\
asm ( "nop \n ld_pz ("#Sxy"), "#Spix" " ::);		\
asm ( "addr #-1<<16, "#Sx ::);		

#define GetDRamAlphaInd( Spix, Sreg ) 		\
asm ( "nop \n ld_pz ("#Sreg"), "#Spix" \n nop " ::);

#define PutDRamAlpha( Spix, Sxy ) 			\
asm ( "nop \n st_pz "#Spix", ("#Sxy")" ::);

#define PutDRamAlphaPP( Spix, Sxy, Sx ) 		\
asm ( "nop \n st_pz "#Spix", ("#Sxy")" ::);	\
asm ( "addr #1<<16, "#Sx ::);	
	
#define PutDRamAlphaMM( Spix, Sxy, Sx ) 		\
asm ( "nop \n st_pz "#Spix", ("#Sxy")" ::);	\
asm ( "addr #-1<<16, "#Sx ::);		

#define GetDRamAlphaPPDec( Spix, Sxy, Sx, Sctr )	\
asm ( "nop \n ld_pz ("#Sxy"), "#Spix" " ::);		\
asm ( "addr #1<<16, "#Sx" " ::);			\
asm ("dec "#Sctr : :);

#define PutDRamAlphaPPDec( Spix, Sxy, Sx, Sctr )	\
asm ( "nop \n st_pz "#Spix", ("#Sxy")" ::);	\
asm ( "addr #1<<16, "#Sx ::);			\
asm ("dec "#Sctr : :);
	
#define GetDRamAlphaMMDec( Spix, Sxy, Sx, Sctr )	\
asm ( "nop \n ld_pz ("#Sxy"), "#Spix" " ::);		\
asm ( "addr #-1<<16, "#Sx" " ::);		\
asm ("dec "#Sctr : :);
	
#define PutDRamAlphaMMDec( Spix, Sxy, Sx, Sctr )	\
asm ( "nop \n st_pz "#Spix", ("#Sxy")" ::);	\
asm ( "addr #-1<<16, "#Sx ::);			\
asm ("dec "#Sctr : :);

#if 0
/* OLD DEFINITIONS */
#define Push( Svec ) asm ( "nop \n push "#Svec ::);
#define Pop( Svec ) asm ( "nop \n pop "#Svec" \n nop \n" ::);

#else
#ifdef BB

#define Push( Svec ) asm ( "nop \n push "#Svec ::);
#define Pop( Svec ) asm ( "nop \n pop "#Svec" \n nop \n" ::);

#else


#define Push( Svec ) 		\
asm ( "sub #16,r31" :::"r31", "cc");	\
asm ( "st_v "#Svec",(r31)" ::);


#define regv0 "r0","r1","r2","r3"
#define regv1 "r4","r5","r6","r7"
#define regv2 "r8","r9","r10","r11"
#define regv3 "r12","r13","r14","r15"
#define regv4 "r16","r17","r18","r19"
#define regv5 "r20","r21","r22","r23"
#define regv6 "r24","r25","r26","r27"
#define regv7 "r28","r29","r30","r31"
#define Pop( Svec ) asm volatile ("nop \n ld_v (r31),"#Svec" \n add #16,r31" :::"r31","cc",reg ## Svec );


/*
#define Pop( Svec )			\
asm ( "nop");                   \
asm ( "ld_v (r31), "#Svec ::);	\
asm ( "add #16,r31" :::"r31","cc");		
*/
#endif
#endif

#define SetIndex( Sbase, Sctl, Sx, Sy, Vbase, Vctl, Vx, Vy )	\
asm ( "nop \n st_s %0, "#Sbase : : "r" (Vbase));			\
asm ( "nop \n st_s %0, "#Sctl : : "r" (Vctl) );			\
asm ( "nop \n mvr %0, "#Sx : : "r" (Vx<<16) );			\
asm ( "nop \n mvr %0, "#Sy : : "r" (Vy<<16) );

#define IncIndex( Sx )					\
asm ( "nop \n addr #1<<16, "#Sx ::);

#define SetMpeCtrl( Sio, Vio )			\
asm volatile( "nop \n st_s %0, "#Sio :: "r" (Vio));

#define GetMpeCtrl( Sio, Vio )			\
asm volatile( "nop \n ld_s "#Sio", %0 \n nop": "=r" (Vio) :);

#define SetFixed( Sreg, Const )			\
asm ( "nop \n mv_s #fix("#Const",30), "#Sreg::);

#define SetVector( Svec, V1, V2, V3, V4 )	\
asm ( "nop \n mv_s %0, "#Svec"[0] \n mv_s %1, "#Svec"[1] \n mv_s %2, "  \
#Svec"[2] \n mv_s %3, "#Svec"[3]" : 		\
: "r" (V1), "r" (V2), "r" (V3), "r" (V4));

#define StoreVector( Svec, Vaddr )		\
asm ("nop \n st_v "#Svec", (%0)" : : "r" (Vaddr));

#define LoadVector( Svec, Vaddr )		\
asm ("nop \n ld_v  (%0),"#Svec" \n nop" : : "r" (Vaddr));

#define StorePix( Svec, Vaddr )		\
asm ("nop \n st_p "#Svec", (%0)" : : "r" (Vaddr));

#define StorePixZ( Svec, Vaddr )		\
asm ("nop \n st_pz "#Svec", (%0)" : : "r" (Vaddr));

#define LoadPix( Svec, Vaddr )		\
asm ("nop \n ld_p  (%0),"#Svec" \n nop" : : "r" (Vaddr));

#define LoadPixZ( Svec, Vaddr )		\
asm ("nop \n ld_pz  (%0),"#Svec" \n nop" : : "r" (Vaddr));

#define GetRegister( Sreg, Val )		\
asm ("nop \n mv_s "#Sreg", %0":"=r" (Val):);

#define MoveRegister( Ssrc, Sdes )		\
asm ("nop \n mv_s "#Ssrc","#Sdes :: );

#define SetRegister( Sreg, Const )		\
asm ("nop \n mv_s #"#Const", "#Sreg::);

#define AddRegister( Sreg, Val )		\
asm ("nop \n add %0, "#Sreg::"r" (Val):"cc");

#define ShiftRegisterLeft( Sreg, Const )		\
asm ("nop \n asl #"#Const", "#Sreg:::"cc");
 
#define Loop( Sctr, Vnum )			\
asm ("nop \n st_s %0, "#Sctr :: "r" (Vnum) );

#define Repeat( Sctr, Vptr )			\
asm ( "nop \n jmp "#Sctr"ne, (%0), nop" : : "r" ((int*)Vptr));

#define DecCtr( Sctr )				\
asm volatile("nop \n dec "#Sctr : :);

#define Break( Sctr, Vptr )			\
asm ( "nop \n jmp "#Sctr"eq, (%0), nop" : : "r" ((int*)Vptr));

/* These macros are required to work around the dcache
freeze bug in both OZ and ARIES.  We must prvent a memory
access to a cached address (that might cause a cache miss)
from being immediately followed by a mem ref to a non-cached
address.
*/
/*
 * better macro to access an "internal memory" value from cached
 * code; this is designed to protect against a cache bug
 * which causes problems for consecutive loads, one from
 * cached memory which causes a miss, the next from
 * uncached (local) memory
 */
#define SL( x, y ) _SetLocalVar( x, y );

#define SLV( u,v,w,x,y ) _SetLocalVector( u,v,w,x,y );

#define _GetLocal(variable)                                          \
__extension__                                                           \
({      register int retvalue;                                          \
        register volatile void *addr = &variable;                       \
        __asm__ volatile                                                \
        (" nop\n"                                                       \
         " ld_io   (%1),%0\n"                                            \
         " nop\n"                                                       \
        : "=r"(retvalue)                        /* outputs */           \
        : "r"(addr)                             /* inputs  */           \
        );                                                              \
        retvalue;                                                       \
})

#define _SetLocalVar(variable,value)                                   \
__extension__                                                           \
({      register int theval = (int)value;                               \
        register volatile void *addr = &variable;                       \
        __asm__ volatile                                                \
        (" .nooptimize\n"                                               \
         " nop\n"                                                       \
         " st_s   %1,(%0)\n"                                            \
         " .optimize\n"                                                 \
        :                                       /* outputs */           \
        : "r"(addr),"r"(theval)                 /* inputs  */			\
        : "memory"           											\
        );                                                              \
	theval;                                                         	\
})

/* may change the value of vecAdr */
#define _SetLocalVector(vecAdr,val0,val1,val2,val3)                     \
__extension__                                                           \
({		register int temp = (int)vecAdr;								\
      __asm__ volatile                                                	\
        (" .nooptimize\n"                                               \
         " nop\n"                                                       \
		 " mv_s			%0, %5\n"										\
         "{ st_s		%1,(%5)\n"                                      \
         " add			#4, %5 }\n"										\
         " {st_s		%2, (%5) \n"									\
         " add			#4, %5	}\n"									\
         " {st_s		%3, (%5) \n"									\
         " add			#4, %5 }\n"										\
         " st_s			%4, (%5) \n"									\
         " .optimize\n"                                                 \
        :                                       /* outputs */           \
        : "r"(vecAdr),"r"(val0),"r"(val1),"r"(val2),"r"(val3),"r"(temp) /* inputs  */ \
        : "cc", "memory"           												\
        );                                                              \
})

#define _GetLocalShort(variable)                                          \
__extension__                                                           \
({      register int retvalue;                                          \
        register volatile void *addr = &variable;                       \
        __asm__ volatile                                                \
        (" .nooptimize\n"                                               \
         " nop\n"                                                       \
         " ld_w   (%1),%0 \n"								\
         " nop\n"                                                       \
         " asr #16, %0 \n"                                            \
         " .optimize\n"                                                 \
        : "=r"(retvalue)                        /* outputs */           \
        : "r"(addr)                             /* inputs  */           \
        );                                                              \
        retvalue;                                                       \
})
#define _SetLocalShortVar(variable,value)                                   \
__extension__                                                           \
({      register int theval = (int)value;                               \
        register volatile void *addr = &variable;                       \
        register int temp;								\
        __asm__ volatile                                                \
        (" .nooptimize\n"                                               \
         " nop\n"										\
         " btst #1, %0\n"								\
         " bra eq, `over\n"								\
         " ld_s (%0), %2\n"								\
         " nop\n"										\
         " and #0xFFFF0000, %2, %2\n"						\
         " bra `out, nop\n"									\
         " `over: asl #16, %1\n"							\
         " and #0xFFFF, %2, %2\n"							\
         " `out: or %1, %2\n"                                           \
         " st_s %2,(%0)\n"                                  	      \
         " .optimize\n"                                                 \
        :                                       /* outputs */           \
        : "r"(addr),"r"(theval),"r"(temp)       /* inputs  */           \
        );                                                              \
	theval;                                                         \
})

#endif
