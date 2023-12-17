/*
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

typedef struct priqueue {
    struct priqueue *next;
    unsigned long priority;
} PriorityQueueMember;

/* here's the queue as a whole */
typedef struct pqueue {
    PriorityQueueMember *list;
} PriorityQueue;

void    *QInitMem(void *mem, unsigned num_elems,
                unsigned size_elems);
void     QInit(PriorityQueue *queue,
                PriorityQueueMember *initialmem);

void     QAdd(PriorityQueue *queue, PriorityQueueMember *member);
int      QRemove(PriorityQueue *queue, PriorityQueueMember *member);
PriorityQueueMember * QGetHead(PriorityQueue *queue);
void     QPutHead(PriorityQueue *queue, PriorityQueueMember *m);
int      QIsEmpty(PriorityQueue *q);

/* priority macros */
#define ComparePriorities(a,b) ((long)((a) - (b)))
#define LowerPriority(a,b) (ComparePriorities(a,b) > 0)
#define LowerOrEqualPriority(a,b) (ComparePriorities(a,b) >= 0)
#define HigherPriority(a,b) (ComparePriorities(a,b) < 0)
#define HigherOrEqualPriority(a,b) (ComparePriorities(a,b) <= 0)

#ifdef __GNUC__
	#define PACKED __attribute__ ((packed))
#else
	#define PACKED
#endif

typedef struct
{
	void *img;
	long dmaflags;
	long width,height;
} PACKED SPR_IMAGE_INFO;

typedef struct
{
	long dmaflags;
	void *dest;
	short clip_max_x;
	short clip_min_x;
	short clip_max_y;
	short clip_min_y;
    int bgColor;
} PACKED RASTER_INFO;

enum SpriteTypes
{
	kSpriteSimple = 0,
	kSpriteSimpleTrans = 1,
	kSpriteInterpolatedTrans = 2,
	kSpriteInterpolated = 3
};

typedef struct
{
    PriorityQueueMember q;
    PriorityQueue *parent;

	short x,y;		  /* Dest position */
	short w,h;        /* sprite width and height */
	long src_x,src_y; /* source offset (16:16) */
	long xscale,yscale; /* X ans Y scale (16:16) */
    long angle;       /* rotation angle (16.16) 0.0 = 0 deg, 1.0 = 360 deg*/
	long trans;       /* Translucency/Mix  (2:30)
	                     lower 4 bits are sprite type!!!!*/
	long dmaflags;    /* dmaflags source (READ BIT!!!)*/	
	void *source;     /* source buffer */
	long transColor;  /* transparent pixel value */
	long tint;        /* tint color*/	
} PACKED SPRITE;

void SPRFill(int initx, int inity, int wide, int high, int color);
int SPRInit(int startmpe, int endmpe,int sliceHeight);
int SPRSetDestScreen(void *scr, long dmaflags, int minx, int miny, int maxx, int maxy, int bgColor);
int SPRInstallTGAImage(char *tga, int mode, SPR_IMAGE_INFO *info, int transColorRGB);
int SPRSetSourceImage(char *scr, int dmafl, int width, int height, SPR_IMAGE_INFO *info);
SPRITE *SPRCreateSprite(SPR_IMAGE_INFO *info,int x, int y, int w, int h);
SPRITE *SPRCloneSprite(SPRITE *s);
int SPRAddSprite(SPRITE * sprite, int x, int y, int angle, int xscale, int yscale, int type, int tc, int depth);
int SPRModifySprite(SPRITE * sprite, int x, int y, int angle, int xscale, int yscale, int type, int tc, int depth);
int SPRRemoveSprite(SPRITE *sprite);
int SPRDeleteSprite(SPRITE *sprite);
void SPRSetSpriteSource(SPRITE * sprite, int x, int y, int w, int h);
void SPRSetSpriteXY(SPRITE * sprite, int x, int y);
void SPRSetSpriteScale(SPRITE * sprite, int xscale, int yscale);
void SPRSetSpriteRotation(SPRITE * sprite, int angle);
void SPRSetSpriteType(SPRITE * sprite, int type);
void SPRSetSpriteTColor(SPRITE * sprite, int tc);
void SPRSetSpriteDepth(SPRITE * sprite, int depth);
void SPRDraw(int clrScreen, int wait);
void SPRWait(void);
int SPRBlitter(char *src, long src_dmaflags, int src_x, int src_y, int src_w, int src_h,
                char *dest, long dest_dmaflags, int dest_x, int dest_y,
                int scalex, int scaley, int angle,
                int clip_min_x,int clip_min_y,int clip_max_x,int clip_max_y,
                int type, int transColor);

