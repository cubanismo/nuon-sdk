/* 
 * Copyright (C) 1995-2001 VM Labs, Inc.
 *
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
*/

#ifndef __MML2D_H_
#define __MML2D_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/types.h>

/*
   Naming Conventions:
   
   * typedef types have initial lowercase letters
   * defined constants begin with k
   * enumerated constants begin with e
*/

/* Some basic platform defines. Provide defaults if not
 * previously defined by compiler switches etc.
 */
/* When building libraries, USE_DISPATCHER is defined by makefile
platform defines.  But it is also needs to be defined for apps;
generally it should be 0, unless the app is going to run on a 
different processor than the library mrp's, e.g. on a STB remote host.
*/
#ifndef USE_DISPATCHER
#define USE_DISPATCHER 0
#endif
      

/**************************/
/* Basic Type Definitions */
/**************************/

#ifndef uint32_h
#define uint32_h
typedef signed char	int8;
typedef short int	int16;
typedef int		int32;	  	/* Assume int is 32 bits */
#ifndef NO_DRAWTEXT
typedef unsigned long	mmlColor;
#endif
#endif
#ifdef NO_DRAWTEXT
typedef unsigned long	mmlColor;
#endif
  			  
typedef int	   			f16Dot16;
typedef int				f2Dot30;
typedef int				scalar;
typedef int				f24Dot8;
typedef int				f28Dot4;
typedef short int		f10Dot6;
typedef short int		f8Dot8;
typedef short int		f2Dot14;

#ifndef _SYS_TYPES_H
typedef signed char     sint8;      /* integer in range -128 to +127 */
#endif
typedef unsigned short  uint10;		/* integer in range 0 to 1023    */
typedef unsigned char   select2;    /* one of 2 enumerated constants */
typedef unsigned char   select4;    /* one of 4 enumerated constants */
typedef unsigned char   select8;    /* one of 8 enumerated constants */
typedef unsigned char   select16;   /* one of 16 enumerated constants */
typedef unsigned char   padOne;     /* pad for missing one UInt8 */
typedef short           padTwo;     /* pad for missing two UInt8s */
typedef int				coord;		/* naturally 16 bits, but use int for arg passing efficieincy - dont use in structs */

typedef unsigned char	textCode;
//typedef unsigned short	textCode;

/**********************************/
/* Pre-defined fixed point values */
/**********************************/

#define kFixOne			(0x00010000)
#define kFracOne		(0x40000000)
#define kIgnore			(0x00abcdef)
#define kSFixOne		(0x4000)
#define k2Dot14One		(0x4000)



/********************/
/* Enumerated types */
/********************/

enum eBool{
    eFalse,
    eTrue,
    eNotSet = kIgnore
};
typedef enum eBool eBool;


/*************************/
/* Library status values */
/*************************/

typedef enum 
{
	eMinStatus,
	eOK,
	eSuccess = eOK,
	eSysMemAllocFail,
	eMerMemAllocFail,
	eUninitialized,
	eCacheFull,
	eOutOfLines,
	eBadScale,
	eT2Err,
	eGlyphTooBig,
	eIllegalCharCode,
	eErr,
	eMaxStatus

} mmlStatus;



/***********************************/
/* System resources data structure */
/***********************************/
/* Created at hardware init.  Has  */
/* SDRAM size and addresses, and   */
/* info about host CPI, if any.    */
/***********************************/

#define kHost_ctd			(0x0)				/* offset of comm bus transmit buffer */
#define kHost_crd			(0x0)				/* offset of comm bus recv buffer (same as xmit) */
#define kHost_cctl			(0x10)				/* offset of comm bus control register */
#define kXmitIdMask			(0xFF)
#define kXmitRetryMask		(0x1000)
#define kXmitFullMask		(0x8000)
#define kRcvFullMask		(0x80000000)
#define kRcvIdMask			(0xFF0000)
#define kodmactl			(0x20500500)		/* hex addresses of other bus and main bus control registers */
#define kmdmactl			(0x20500600)
#define kMerlinParAdr		(0x80020000)
#define kBlackBirdPlatform	(2)
#define kGamePlatform 		(1)
	
typedef struct
{
	uint32			NumFonts;			/* number of registered fonts in entire system */
	void*			FontArray;			/* Pointer to array of FontDescriptors */
	void*			NextMerlinSDRAM;	/* Next available Merlin SDRAM address */
	uint32			AvailMerlinSDRAM;	/* Num bytes of free Merlin SDRAM */
	void*			NextMerlinSysRam;	/* Next available Merlin SDRAM address */
	uint32			AvailMerlinSysRam;	/* Num bytes of free Merlin SDRAM */
	uint32			DispatcherId;		/* Comm Bus ID of Merlin MPE doing dispatching */
	int				platform;
	uint32			bbAvailDtram;
	void*			bbDtramAdr;
	uint32			intDataAvailDtram;
	void*			intDataAdr;

} mmlSysResources;



/***************************************************************************

Pixmaps describe how a particular contiguous chunk of allocated memory is to 
be interpreted as an image.  Pixmaps are subclassed into Application pixmaps 
and Display pixmaps.  
 
Application pixmaps are laid out in raster order, and can not be directly 
displayed by the Merlin VDG.  Application pixmap memory is always allocated 
in System Ram and can be addressed directly via *(pixmapP->memP).  A major 
purpose of an application pixmap is to act as a source for a block-transfer 
to a display pixmap.  

Display pixmaps can be framebuffers for the Merlin Video hardware.  Display 
pixmap memory must be allocated in Merlin SDRAM, and should only be addressed 
procedurally.  Display pixmaps are generally laid out in a special bilinear 
layout that allows efficient dma access to vertical strips, etcetera.  

Different data types are used for the two subclasses, so that compilers can 
do type checking in the functions that only accept one of the subclasses as a 
parameter; e.g.  ScaledCopyRect( mmlAppPixmap* srcP, mmlDisplayPixmap* destP, 
...) Any pixmap may be correctly passed to a function that specifies 
mmlPixmap as a parameter by casting the subclass to the superclass, e.g.  

	mmlAppPixmap map1;
	mmlInitAppPixmaps( &map1, 640, 480, NULL, e8Clut, 1 );
	mmlSetClut( (mmlPixmap*)&map1, clutPtr );

The pixmap initializers allow the programmer to either specify an already 
allocated area of memory to be used for the pixmap memory, or to have the 
initializer function allocate the memory.  If the memory is automatically 
allocated, the programmer should call ReleasePixmaps to free the memory when 
the pixmap is no longer used.

Provision is made for initializing an array of pixmaps of the same type with 
a single call.  When the pixel type is e655Z, this actually results in memory 
being allocated for a Z buffer that is shared by the color buffers.  In this 
case, the programmer must make sure to Release the array of pixmaps with a 
single ReleasePixmaps call that points to the first pixmap in the array.  

Warnings -- It is illegal to attempt to initialize a Display Pixmap with an 
address that is not in Merlin SDRAM.  It is possible to initialize an 
Application Pixmap with an SDRAM address.

If the application can be guaranteed to always run on Native Merlin platforms 
(never on combination Host-Merlin platforms), then the SDRAM Application 
pixmap can be addressed directly via *(PixmapP->memP), but it is considered 
poor practice to create such non portable code.  

Coordinate conventions:

	* left < right
	* top < bottom.
	* pixmap coordinates go from 0 to N
	* scanline numbers go from 1 to N
	* scanline pixel positions go from 1 to N

***************************************************************************/

#define kPixField			(0xF0)
#define kPixShift 			(4)
#define kAspectField 		(0x2)
#define kBitFixAspect		(1<<8)
#define kSrcFlagsField 		(0x1FF)
#define kNBufField			(0x300)
#define kNBufShift			(8)
#define kLeftVisiblePixel	(36)

#define PIXFORMAT( x ) ((mmlPixFormat)((x & kPixField)>>kPixShift ))

/* 

Note these are application formats, they do not correspond exactly to the pix 
formats used in the dma flags.  In particular, MPEG formats are not 
represented and are replaced by RGB formats.  

*/
#ifndef mlPixType_h
#define mlPixType_h
typedef enum
{
	eMinFormat,
	eClut4,
	e655,
	eClut8,
	e888Alpha,
	e655Z,
	e888AlphaZ,
	eGRB655,
	eRGBAlpha1555,
	eRGB0555,
	eGRB888Alpha,
	eClut4GRB888Alpha,
	eClut8GRB888Alpha,
	eClut8GRB655,
	eClut8655,
	eMPEG,
	eMaxFormat

}mmlPixFormat;
#endif


typedef enum 
{
	eBackwardsA = 1,
	eVertical = 0x100,
	eBackwardsB = 0x200,
	eCluster = 0x800,
	eRead = 0x2000,
	ePixDma = 0xC000,
	eDup	= (1 << 26 )
	
} mmlDisplayFlags;



/* Properties bit fields

	0 : 0 - needs freeing?
	1 : 1 - aspect ratio
	2 : 2 - DisplayPixmap ?
	4 : 7 - pixel format
	8 : 9 - num buffers in this array of pixmaps
*/

typedef enum 
{
	eNeedsFreeing = 1,
	eSquarePixels = 2,
	eDisplayMap = 4

} mmlPixmapProperties;



typedef enum
{
	eMinLayer,
	eMain,
	eOverlay,
	eSubPicture,
	eMaxLayer

} mmlVideoLayer;



typedef enum 
{
	eTV = 0,
	eSquare = 2

} mmlPixAspect;



typedef enum 
{
	eNoVideoFilter = 0,
	eTwoTapVideoFilter = 2,
	eFourTapVideoFilter = 4

} mmlVideoFilter;



typedef struct mmlPixmap
{
	uint32		dmaFlags;	/* width<<13 | eCluster | ePixDma | pixFormat */
	void*		memP;
	uint16		wide;
	uint16		high;
	uint32		properties;	/* needsFreeing */
	mmlColor*	yccClutP;

} mmlPixmap;
	


typedef struct 
{
	uint32		dmaFlags;	/* width <<16 | pixFormat */
	void*		memP;
	uint16		wide;
	uint16		high;
	uint32		properties; /* squarePixels << 1 | needsFreeing */
	mmlColor*	yccClutP;

} mmlAppPixmap;



typedef struct 
{
	uint32		dmaFlags;
	void*		memP;
	uint16		wide;
	uint16		high;
	uint32		properties;
	mmlColor*	yccClutP;

} mmlDisplayPixmap;





#define kColorBlack    		({0,0,0})
#define kDrawSource    		(0)
#define kVector0       		({0, 0, 0})
#define kUnchanged     		(0)
#define kDefaultBlur		(0)
#define kOpaque				(0xFFFFFFFF)
#define kThin				(10)
#define kStandardSize		(28)
#define kBlackIndex			(1)
#define kWhiteIndex			(2)
#define kStandardReserve	(16)
#define kHoriz 				(0)
#define kVert 				(1)



typedef enum
{
	eMinOp,
	eNoDraw,
	eSrcCopy,
	eBlendSrcAlpha,
	eBlendConstantAlpha,
	eComplement,
	eMaxOp

} mmlDrawOp;



typedef enum
{
	eMinZ,
	eZnone,
	eZlt,
	eZle,
	eZeq,
	eZne,
	eZge,
	eZgt,
	eMaxZ

} mmlZCompare;



typedef enum
{
	eMinFill,
	eHollow=0,
	eFilled=1,
	eMaxFill

} m2dFill;



typedef enum
{
/*	eMinLineKind,g
	eOpaqueSquare,
	eOpaqueRound,
	eTranslucent,
	eChalk,
	eNeon,
	eMaxLineKind*/
	eMinLineKind,
	eLine1,
	eLine2,
	eLine3,
	eLine4,
	eLine5,
	eLine6,
    eLine3clut,
    eLine7clut

} m2dLineKind;



typedef enum
{
	eMinWeight,
	ePlain,
	eBold,
	eMaxWeight

} m2dTextWeight;



typedef enum
{
	eMinEmphasis,
	eNormal,
	eItalic,
	eMaxEmphasis

} m2dTextEmphasis;



/* These are the fundamental 2D Graphics objects.
    All data structures are public. BUT
    Clients are urged to use the C_Struct accessor ->
    rather than walking a struct with a pointer.  This
    will allow the code to recompile correctly when we
    later change the definition of the data structure.
*/

/* 2d points and rects use unsigned short coordinates rather than fixed point. */

typedef struct 
{
    uint16   x;
    uint16   y;

} m2dPoint;



typedef struct
{
    m2dPoint   leftTop;
    m2dPoint   rightBot;

} m2dRect;



typedef struct
{
    f2Dot30     xrite;
    f2Dot30     yrite;
    f2Dot30     zrite;
    f2Dot30     xdown;
    f2Dot30     ydown;
    f2Dot30     zdown; 
    f2Dot30     xhead;
    f2Dot30     yhead;
    f2Dot30     zhead;
    f16Dot16    xpos;
    f16Dot16    ypos;
    f16Dot16    zpos;

} mmlMatrix;



typedef struct
{
    f16Dot16    t00, t01;
    f16Dot16    t10, t11;

} ml2by2Matrix;


/* Style characteristics of line, its thickness, cap,
 join, dash, pattern, etc.
 */

typedef struct
{
	mmlColor 		foreColor;
	uint32  		thick;			// uses only the lower 16 bits
    uint32			alpha;			// uses only the lower 16 bits - 0 = transparent
	m2dLineKind 	lineKind;
	mmlColor 		foreColor2; 	// used by aaline5.s & aaline6.s

	//  colorBlend* - This is made the 0th byte of foreColor* 
	//  Range: 00 - 3F. 
	
	// Relevant only to aaline6. If foreColor were $f080803f 
	// and foreColor2 were $f0808000, you get a white line 
	// that tapers off to nothing. Setting the last byte of
	// both colors to 00 produces no display.

	int32			colorBlend1;	// used by aaline6.s, uses only the lower 8 bits
	int32			colorBlend2;	// used by aaline6.s, uses only the lower 8 bits

	int32			lineRandNum[4];	// used by aaline4.s

} m2dLineStyle;


/*Style characteristics of circle; eccentricity, edge thickness, etc. */

typedef struct
{
	uint32			width;			// uses only the lower 16 bits
	mmlColor		foreColor;
	mmlColor		foreColor2; 	// unused, just a placeholder
    f24Dot8			xScale;			// really 2.8 format currently, upper 22 bits are unused
    f24Dot8			yScale;			// really 2.8 format currently, upper 22 bits are unused
	uint32	    	alpha;		
//	f8Dot8			blur;			// 0x0800 is very thin line.  0xe000 is fat line.
//  m2dFill			fill;
	int32			fill;			// 0 = Open, 1 = Filled

} m2dEllipseStyle;


typedef struct
{
    f16Dot16   x;
    f16Dot16   y;
    f16Dot16   z;

} mmlVector;


/* Graphics Context struct - will probably change a lot yet */

typedef struct
{
	mmlSysResources*	sysResP;
    f16Dot16			z;
	int32				alpha;			/*  8, 16 & 32 bits are used. 0 always = transparent */
    mmlColor			foreColor;
   	mmlColor			backColor;
    void*				fontContextP;
	mmlMatrix			transform;		/*  restrict to styled draws ? */
    uint32				clutForeIndex;
   	uint32				clutBackIndex;
	uint32				nClutAlpha;		// number of gradations of a color. Used for clut mode
	mmlDrawOp			drawOp;			/*  how src and dest are combined. */
    mmlZCompare			zCompare;		/*  interaction with viewport Z buffer */
	eBool				transparentSource;
	eBool				fixAspect;
	mmlStatus			err;			/* mostly for bbird */
	uint32				disCopyBlend;	/* 1 for do blend, 0 for dont */
	m2dLineStyle		defaultLS;
	m2dEllipseStyle		defaultES;
	int					textBase;
	int					textMax;
	int					textDiv;
	int					textMin;
	eBool				transparentOverlay;	/* Honor trans bits to make Main Ch show thru Overlay */
	int					rgbTransparentValue;	/* 15 bit RGB value to be translated to 0,0,0 */
	void*				sequence;			/* pointer to active mmlSequence */
	f16Dot16			textWidthScale;
	int					translucentText;
	
} mmlGC;







/***************************************************************************

For now, color is represented as packed Y:Cr:Cb:Control in 32 bits.  May 
eventually add some other formats.  Use int rather than unsigned int, so we 
can use enumerated constants for colors.  

typedef int mmlColor;

The basic MML color element is a single 32 bit long packed as 
Y:Cb:Cr:Control, each field using 8 bits.  Later we may introduce structs to 
hold different formats.  Conversion is provided between mmlColors and RGB 
components.

When the least significant byte is used as an alpha value by the hardware:

	00 = opaque
	FF = transparent.
	
We follow the same convention in software.  So these colors are all opaque 
colors.  

***************************************************************************/

/* The following colors are appropriate for default NTSC output.  They
 * are based on 75 percent amplitude and include a 7.5 IRE setup for
 * the video.
 */
enum colors
{
   	kNTSCWhite	= 0xB4808000,
   	kWhite		= 0xEB808000,
   	kBlack		= 0x10808000,
   	kYellow		= 0xA28E2C00,
   	kCyan		= 0x832C9C00,
	kMagenta	= 0x54C6B800,
	kRed		= 0x41D46400,
	kGreen		= 0x703A4800,
	kBlue		= 0x2372D400,
	kGray		= 0x80808000,
};

/* constants acceptable as the 'select' argument for mmlSafeColorLimits() */
typedef enum
{
	eSafeColorDisable  = -2,
	eSafeColorDefault  = -1,
	eSafeColorCustom   = 0,
	eSafeColorNTSC     = 1,
	eSafeColorNTSCZero = 2,
	eSafeColorPAL      = 3,
} mmlSafeColorSel;

/* Public API types */
typedef enum
{
	eLetter,
	eNumber,
	ePunctuation,
	eWhiteSpace,
	eGraphic,
	eExtra

} charKind;


typedef enum
{
	eAscii,
	eUnicode,
	eShiftJis

} textEncoding;


typedef enum
{
	eNonScalable = 1,
	eTrueType = 2,
	eT2K = 2

} typeTechnology;


typedef enum
{
	eOpaque,
	eBlend,
	eClutAlpha,
	eClutOpaque

} textMix;

typedef enum
{
	eOldModel,
	eNewModel
	
} textModel;

/* copy mode flags for textstyle */

#define kFillRect 0x10000000


// The types "struct mmlFontStuff" and "struct mmlFontStruct"
// are not defined here.

typedef struct mmlFontStuff* mmlFontContext;

typedef struct mmlFontStruct* mmlFont;

extern uint8 SysFont[];
extern uint8 SysFontEnd[];
extern uint8 SysFontBold[];
extern uint8 SysFontBoldEnd[];

typedef struct
{
	mmlFont		fontP;
	int			fontSize;
	f28Dot4		tracking;	/* number of sixteenths of pixel space to add between letters */
	mmlColor		foreColor;
	mmlColor		backColor;
	int			copyMode;
	f16Dot16		xScale;

} mmlTextStyle;

typedef struct
{
	uint32		columnHeight; /* yAscender + yDescender + yLineGap */
	uint32		base;		/* pixels from top */
	f16Dot16		ascent;
	f16Dot16		descent;
	f16Dot16		maxWidth;
	uint32		ttPointSize;	/* point size actually used for rendering */
	uint32		firstCharCode;
	uint32		lastCharCode;
	uint32		numCharacters;
} mmlLayoutMetrics;


typedef struct {
	int		maxCommands;
	int		numCommands;
	void* 	cmdP;
} mmlSequence;


/*****************************/
/* MML2D Function Prototypes */
/*****************************/

/* Internal MML2D Functions */

mmlMatrix* mmlIdentMatrix( mmlMatrix* matP );


/* Set Pixmap fields.*/
void mmlSetPixmapFormat( mmlPixmap* sP, mmlPixFormat pix, mmlColor* clutP );


/* Initialize Graphics Context with a bunch of vanilla default values */

void mmlInitGC( mmlGC* gcP, mmlSysResources* srP );



/* Initialize/Exit MML2D Library */
void mmlMemConfig( void* localStart, int localSize,
						void* sysStart, int sysSize,
						void* vidStart, int vidSize );
						
void mmlPowerUpGraphics( mmlSysResources* hP );

void mmlCloseGraphics(mmlSysResources* srP );



/* Initialize video hardware */

void mmlSimpleVideoSetup(mmlDisplayPixmap* sp, mmlSysResources* srP, mmlVideoFilter filttype);



/* Initialize an array of application pixmaps */
mmlStatus mmlInitAppPixmaps( mmlAppPixmap* sP, mmlSysResources* srP, int wide, int high ,
		mmlPixFormat pix, int numBuffers, void* memP );

mmlStatus mmlInitDisplayPixmaps( mmlDisplayPixmap* sP, mmlSysResources* srP, int wide, int high ,
	mmlPixFormat pix, int numBuffers, void* memP );
                   


/* Release allocated Pixmaps */

void mmlReleasePixmaps( mmlPixmap* sP, mmlSysResources* srP, int numPixmaps );



/* Miscellaneous Functions */

uint8 mlpFormatToSize( mmlPixFormat pix );

void mmlSetPixmapClut( mmlPixmap* sP, mmlColor* clutP );



/* Raster Operations */

void m2dFillColr( mmlGC* gcP, mmlDisplayPixmap* destP, m2dRect* rP, mmlColor color );
#define  m2dFillColor m2dFillColr
void m2dFillClut( mmlGC* gcP, mmlDisplayPixmap* destP, m2dRect* rP, mmlColor color );

void m2dCopyRect(mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint pt );

void m2dCopyRectDis(mmlGC* gcP, mmlDisplayPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint pt );

mmlStatus m2dScaledCopy(mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP,
 m2dRect* rP, m2dRect* targP, int hnum, int hden, int vnum, int vden );

void m2dCopyClutRect(mmlGC* gcP, mmlPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint pt );
void m2dCopyRectFast( mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint dpt );
void m2dCopyRect16( mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint dpt );
void m2dCopyTileAll( mmlGC* gcP, mmlDisplayPixmap* destP, uint8* tileP, int left, int top, int pixWide, int pixHigh,
int rowPixStride, int xDest, int yDest, void* clutP );
void m2dCopyTile8( mmlGC* gcP, mmlDisplayPixmap* destP, uint8* tileP, int left, int top, int pixWide, int pixHigh,
int rowPixStride, int xDest, int yDest, void* clutP, int transIndex );
void m2dScrollUp( mmlGC* gcP, mmlDisplayPixmap* destP, m2dRect* rP, int skip );


/* Line Draw Functions */

void m2dInitLineStyle( mmlGC* gcP, m2dLineStyle* lineS, mmlColor color, int32 thick, uint32 alpha,
	m2dLineKind lineKind );	 

void m2dDraw2DLine( mmlGC* gcP, mmlDisplayPixmap* destP, int32 xBeg,
	 int32 yBeg, int32 xEnd, int32 yEnd );

#define m2dDrawLine m2dDraw2DLine

void m2dDrawStyled2Dline(mmlGC *gcP, mmlDisplayPixmap *destP, m2dLineStyle *sP,
	 int xBeg, int yBeg, int xEnd, int yEnd);

#define m2dDrawStyledLine m2dDrawStyled2Dline

void m2dDrawPolyLine(mmlGC *gcP, mmlDisplayPixmap *destP, int32 xc, int32 yc,
	f24Dot8 xscale, f24Dot8 yscale, int32 angle, int32* pPtsLst);



/* Ellipse & Circle Functions */

void m2dInitEllipseStyle( mmlGC* gcP, m2dEllipseStyle* circleS, f16Dot16 ratio,
	mmlColor color1, f24Dot8 xScale, f24Dot8 yScale, uint32 alpha, int32 fill);

void m2dDrawEllipse(mmlGC *gcP, mmlDisplayPixmap *destP, int32 xc, int32 yc, int32 rad);

void m2dDrawEllipse8(mmlGC *gc, mmlDisplayPixmap *V, int a, int b, int x, int y, mmlColor color);

void m2dDrawStyledEllipse(mmlGC *gcP, mmlDisplayPixmap *destP, m2dEllipseStyle *sP, int32 xc, int32 yc, int32 rad);

void m2dDrawQuadArc(mmlGC *gcP, mmlDisplayPixmap *destP, int32 xc, int32 yc, int32 rad, int32 quadrant);

void m2dDrawStyledQuadArc(mmlGC *gcP, mmlDisplayPixmap *destP, m2dEllipseStyle *sP, int32 xc, int32 yc,
    int32 rad, int32 quadrant);


/* m2dSequence commands.  These functions are used
to capture a sequence of 2d commands that can then be
executed as a single call.  This is mostly useful for 
improving efficiency when commands are dispatched to 
another processor.
*/
mmlStatus mmlOpenSeq( mmlGC* gcP, mmlSequence* seqP, int numCmds );

mmlStatus mmlReopenSeq( mmlGC* gcP, mmlSequence* seqP, int numMoreCmds );

void mmlExecuteSeq( mmlGC* gcP, mmlSequence* seqP );

void mmlCloseSeq( mmlGC* gcP, mmlSequence* seqP );

void mmlReleaseSeq( mmlGC* gcP, mmlSequence* seqP );

mmlStatus SeqAddCmd( mmlSequence* seqP, long funcode, long parBlockP, long arg2, long arg3 );


/* Simple setters & getters */

m2dPoint m2dSetPoint(  uint16 x, uint16 y );
m2dRect* m2dSetRect( m2dRect* rP, uint16 left, uint16 top, uint16 right, uint16 bottom );



/*Functions to convert color spaces.  Don't introduce RGB color object. Keep all 
colors in YCC and therefore don't have to have double API calls for each kind
of color.
*/

/* initialize a color from 8 bit unsigned Y, Cr, and Cb components */
mmlColor mmlColorFromYCC(uint8 y, uint8 cr, uint8 cb);

/* initialize a color from 8 bit R, G, and B components */
mmlColor mmlColorFromRGB(uint8 r, uint8 g, uint8 b);

/* initialize a color from floating point Y, Cr, and Cb components,
   with 0.0 <= Y <= 1.0, and -0.5 <= Cr,Cb <= 0.5 */
mmlColor mmlColorFromYCCf(double y, double cr, double cb);

/* initialize a color from floating point R, G, and B components,
   with 0.0 <= R,G,B <= 1.0 */
mmlColor mmlColorFromRGBf(double r, double g, double b);

/* retrieve 8 bit Y, Cr, Cb color components */
void mmlGetYCCComponents(mmlColor color, uint8 *y, uint8 *cr, uint8 *cb);

/* retrieve floating point Y, Cr, Cb color components */
void mmlGetYCCFloatComponents(mmlColor color, double *y, double *cr, double *cb);

/* retrieve floating point R, G, B color components */
void mmlGetRGBFloatComponents(mmlColor color, double *r, double *g, double *b);

/* hacked way to lighten colors */
mmlColor lightenColor( mmlColor input, int percent );

/* convert the given YCC color into something that is guaranteed safe
 * for the output monitor (NTSC or PAL).
 */
mmlColor mmlSafeColor( mmlColor color );

/* Advanced feature:  Choose the set of limits used to restrict colors
 * to make them safe for NTSC or PAL.
 */
int mmlSafeColorLimits( mmlSafeColorSel select );

/* Set custom safe-color limits and select that set */
int mmlCustomSafeColorLimits( double ped, double smax, double smin, double cmax );


/* Public API Prototypes for text */

charKind CharKindQ( textCode k, textEncoding standard );

mmlStatus mmlInitFontContext( mmlGC* gc, mmlSysResources *sysResP,
	 mmlFontContext* fcP, int cacheSize );
	 
void mmlSetTextModel( mmlFontContext fcP, textModel model );

void mmlGetFontName( mmlFont f, textCode** nameP );
	 
mmlFont mmlAddFont( mmlFontContext fcP, textCode typeface[],
	typeTechnology tech, uint8* location, int size );
	
void mmlRemoveFont( mmlFontContext fcP, mmlFont font );

void mmlGetRegisteredFonts( mmlFontContext fcP, mmlFont fonts[], int* numFontsP );

void mmlSetTextProperties( mmlFontContext fcP, mmlFont fontP, int fontSize,
	mmlColor fore, mmlColor back, textMix copyMode, int flags, f28Dot4 tracking  );

void mmlSimpleDrawText( mmlFontContext fcP,  mmlDisplayPixmap* screenP,
	textCode str[], int numGlyphs, m2dRect* rP);
	
void mmlSimpleDrawBaseline( mmlFontContext fcP,  mmlDisplayPixmap* screenP,
	textCode str[], int numGlyphs, int baseX, int baseY);

void mmlGetTextBox( mmlFontContext fcP, textCode t[], int first, int last,
	m2dRect* rP );

void mmlInitTextStyle( mmlTextStyle* tsP, mmlFont fontP, int fontSize,
	mmlColor fore, mmlColor back, textMix copyMode, int flags, f28Dot4 tracking  );

void mmlInitScaledTextStyle( mmlTextStyle* tsP, mmlFont fontP, int fontSize,
	mmlColor fore, mmlColor back, textMix copyMode, int flags, f28Dot4 tracking, f16Dot16 xScale  );

void mmlSetTextStyle( mmlFontContext fcP, mmlTextStyle* tsP );

mmlLayoutMetrics* mmlGetStyleLayoutMetrics( mmlFontContext fcP, mmlTextStyle* tS );

mmlLayoutMetrics* mmlGetLayoutMetrics( mmlFontContext fcP );

/***************************************************************************
Special 2d Objects.  These are convenient high-level objects with
efficient api implementations.
***************************************************************************/
typedef struct m2dBox m2dBox;
struct m2dBox{
	int		maxWidth;
	int		maxHeight;
	int		maxLineWidth;
	int		width;
	int		height;
	int		lineWidth;
	int		visibleQ;
	int		rowSizeLongs;
	int		colSizeLongs;
	int		pixSizeBytes;
	mmlColor 	color;
	int		left;
	int		top;
	void*		memP;
};
mmlStatus m2dInitBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP, int maxWidth, int maxHeight, int maxLineWidth );
void m2dDrawBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP, int width,
	int height, int lineWidth, int left, int top, mmlColor color );
void m2dEraseBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP );
void m2dRedrawBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP );
void m2dReleaseBox( m2dBox* bP );

typedef struct 
{
	uint32		dmaFlags;  /* wide<<13 | 0xC840 */
	void*		imageP;
	uint16		wide;	   
	uint16		high;	   
	void*		restoreP;
	uint16		left;
	uint16		top;
	mmlDisplayPixmap* screenP;	

} m2dArrow;

mmlStatus m2dInitArrow(mmlSysResources* srP, m2dArrow* aP, uint32 wide, uint32 high );
void m2dSetArrowPixel( mmlGC* gcP, m2dArrow* aP, int x, int y, mmlColor c );
void m2dMoveArrow( mmlGC* gcP, m2dArrow* aP, mmlDisplayPixmap* destP,
	coord newLeft, coord newTop );
void m2dHideArrow( mmlGC* gcP, m2dArrow* aP );
void m2dRedrawArrow( mmlGC* gcP, m2dArrow* aP );
void m2dShowArrow( mmlGC* gcP, m2dArrow* aP, mmlDisplayPixmap* destP, coord left, coord top );
void m2dDeleteArrow( mmlSysResources* srP, m2dArrow* aP );

/***************************************************************************
FAST MACROS - These 2d graphics functions are implemented as macros.  They have different
expansions, depending upon whether or not the function is going to execute on the same
MPE that is executing the app that made the graphics call.  This is done in order to
increase speed.
***************************************************************************/

/* Function prototypes required to support the 2d Macros.  These are not public API functions
and should not be invoked by most applications.
*/	
mmlStatus mmlExecutePrimitive(mmlGC* gcP, uint32 prim, void* paramBlockP,
	 int parSize, uint32 option2, uint32 option3 );
extern void MovePixDirect( int flags, uint32* buffer, void* frameP, int x, int y,
 int numPix, int vert, uint32* tile, int readQ );	
extern void SmallFillDirect(int flags, void* frameAdr, int xDesc, int yDesc, void* mdmaBlock, int color ); 

extern void* _localRamPtr;
extern int _localRamSize;

#if USE_DISPATCHER == 0 

#define m2dDrawPoint( gcP, destP, x, y, color )		\
SmallFillDirect( ((destP)->dmaFlags & 0xFF08F0), (destP)->memP, (x)|(1<<16), (y)|(1<<16), _localRamPtr, color );

#define m2dSmallFill( gcP, destP, x, y, color, xLen, yLen )		\
SmallFillDirect( ((destP)->dmaFlags & 0xFF08F0), (destP)->memP, ((x)|((xLen)<<16)), ((y)|((yLen)<<16)), _localRamPtr, (color)&0xFFFFFF00 );

#define m2dReadPixels(gcP, buffer, destP, x, y, num, verticalQ )	\
MovePixDirect( (destP)->dmaFlags, buffer, (destP)->memP, x, y, num, verticalQ, (uint32*)_localRamPtr, 1 )

#define m2dWritePixels(gcP, buffer, destP, x, y, num, verticalQ )	\
MovePixDirect( (destP)->dmaFlags, buffer, (destP)->memP, x, y, num, verticalQ, (uint32*)_localRamPtr, 0 )

#else
#define m2dDrawPoint( gcP, destP, x, y, color )									\
{																\
int adr = ((int)((destP)->memP) & ~0xFF) | (((destP)->dmaFlags & 0xFF0000 )>>16);			\
int coords = (((destP)->dmaFlags & 0x8F0)<<16) | (y<<10) | x;						\
mmlExecutePrimitive( gcP, eDrawPoint, (void*)adr, 0, coords , color );					\
}

#define m2dSmallFill( gcP, destP, x, y, color, xLen, yLen )							\
{																\
int adr = ((int)((destP)->memP) & ~0xFF) | (((destP)->dmaFlags & 0xFF0000 )>>16);			\
int coords = ((yLen)<<26) | ((y)<<16) | ((xLen)<<10) | (x) ;						\
int colflags = ((color)&0xFFFFFF00) | (((destP)->dmaFlags & 0x8F0)>>4);					\
mmlExecutePrimitive( gcP, eSmallFill, (void*)adr, 0, coords , colflags );				\
}

#define m2dReadPixels(gcP, buffer, destP, x, y, num, verticalQ )						\
{																						\
int adr = ((int)((destP)->memP) & ~0xFF) | (((destP)->dmaFlags & 0x7F0000 )>>16) | 0x80;		\
int flags = (verticalQ<<31) | (((destP)->dmaFlags & 0x800 )<<19)|(((destP)->dmaFlags & 0xF0 )<<22); \
flags = flags | ((num-1)<<20) | (y<<10) | x;  										\
mmlExecutePrimitive( gcP, eMovePix, (void*)adr, 0, buffer , flags );					\
}

#define m2dWritePixels(gcP, buffer, destP, x, y, num, verticalQ )						\
{																						\
int adr = ((int)((destP)->memP) & ~0xFF) | (((destP)->dmaFlags & 0x7F0000 )>>16);		\
int flags = (verticalQ<<31) | (((destP)->dmaFlags & 0x800 )<<19)|(((destP)->dmaFlags & 0xF0 )<<22); \
flags = flags | ((num-1)<<20) | (y<<10) | x;  										\
mmlExecutePrimitive( gcP, eMovePix, (void*)adr, 0, buffer , flags );					\
}

#endif

#ifdef __cplusplus
}
#endif

#endif /* __MML2D_H_ */
