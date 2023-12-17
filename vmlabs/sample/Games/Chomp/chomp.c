/*
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

/*
    Includes
*/

#include <stdio.h>
#include <stdlib.h>
#include <nuon/sprite.h>
#include <nuon/termemu.h>
#include <nuon/bios.h>
#include <nuon/dma.h>
#include <nuon/video.h>
#include <nuon/joystick.h>
#include <nuon/nise.h>

/*
    Level definitions
*/

#include "levels.h"

/*
    Bunch of constants
*/

#define SCREEN_WIDTH 360
#define SCREEN_HEIGHT 240
#define DMAFLAGS  (DMA_PIXEL_WRITE | ((SCREEN_WIDTH/8)<<16) | (4<<4) | (1<<11))                                          

#define TILESIZE 8
#define INC 1
#define INCG 1

#define OFFX 37
#define OFFY 20

#define SPRITESIZE 32
#define CHOMPERSIZE 40

#define GHOSTSCALE 0x7000
#define CHOMPERSCALE   0x7000
#define SCORESCALE 0x8000
#define LIVESSCALE  0x6000

#define SCOREX 40
#define SCOREY 215

#define CHASEBARX 180
#define CHASEBARY 215

#define DELAY 15

#define RATIO 2


#define NUM_SPRITES 16
#define NUM_BUFFERS 3
#define MAX_GHOSTS 5

/*
    Binaries (see data.s)
*/

extern char SpriteImage[];
extern char StartScreen[];
extern char GameOverScreen[];
extern char GameCompleteScreen[];
extern char LevelCompleteScreen[];
extern char GameBeginWav[];
extern char ChomperChompWav[];
extern char FruitEatWav[];
extern char ChaseWav[];
extern char GhostEatWav[];
extern char ChomperDiesWav[];
extern char ExtraChomperWav[];
extern char Digits[];

/*
    Structures for the ghosts and chomperman
*/

typedef struct
{
	SPRITE *ghost;
	int gphase;
	int startx,starty;
	int ghostx,ghosty;
	int nghostx,nghosty;
	int ghostAx,ghostAy;
	int gincx,gincy;
	int way;
	int last_way;
	int hist[16],in,out;
	int active;
} GHOST;


typedef struct
{
	SPRITE *chomperman;
	int mphase,aphase;
	int startx,starty;
	int chomperx,chompery;
	int nchomperx,nchompery;
	int chomperAx,chomperAy;
	int incx,incy;
	int angle;
	int direction,ndir;
} CHOMPERMAN;

/*
    Local prototypes
*/

int PlayWAV(void *wavaddr, int voice, PCMPOS *Pan, int volume, int echo );
void InitGhost(int i);


/*
    Globals
*/

SPR_IMAGE_INFO source,StartScr,GameOverScr,DigitsScr,CompleteScr,LevelScr;
PCMPOS Pan;

void *FrameBuffer[NUM_BUFFERS],*MazeBuf;
static int fps;
int drawBuffer = 0;
char *localScratch;
int localSize;
SPRITE *scani;
int saphase;

GHOST ghosts[MAX_GHOSTS];
CHOMPERMAN chomper;

int score;
int extra;
int lives;
int gameover;
int chase;
int pills;
int collected;
int delay;
int level;
int ghostsEaten;
int gDivider,gDividerCnt;
int pDivider,pDividerCnt;
int numGhosts;
int chasevoice;

unsigned char maze[MAZE_W*MAZE_H];

/*
    Copy via DMA
*/


void CopyMaze(char *d,char *s,int pages)
{
	while(pages)
	{
		_DMALinear((64<<16)+(1<<13),s,localScratch);
		_DMALinear((64<<16),d,localScratch);
		pages--;
		s=&s[256];
		d=&d[256];
	}
}

/*
    Simple routine to draw a filled rectangle (via DMA)
*/

void myFillRect(char *screen, int dmaflags, int initx, int inity, int wide, int high, int color)
{
    int x, y;
    int lastx, lasty;
 
    lastx = initx + wide;
    lasty = inity + high;
 
    for (x = initx; x < lastx; x += 8) {
                for (y = inity; y < lasty; y += 8) {
                _raw_plotpixel(dmaflags, (void *)screen, (8<<16)|x, (8<<16)|y, color);
                }
    }
}

/*
    Convert ASCII description of a maze inta a real framebuffer
*/


void CreateMaze(SPR_IMAGE_INFO *img, long *frame, char *maze, int w, int h)
{
	unsigned int x,y,c,b,sx,sy;
	unsigned char newmaze[1024];
	
	sx=128;
	sy=0;
	pills=numGhosts=0;
	chomper.startx=18;	
	chomper.starty=19;	
	
	for (x=0;x<w;x++)
		for (y=0;y<h;y++)
		{
			b=15;
			c=maze[x+y*w];
			switch(c)
			{
				case '#':
					if (!x) b&=~8;
					if (x==w-1) b&=~2;
					if (!y) b&=~4;
					if (y==h-1) b&=~1;

					if ((b&1) && maze[x+(y+1)*w]!='#')
						b&=~1;
					if ((b&2) && maze[(x+1)+y*w]!='#')
						b&=~2;
					if ((b&4) && maze[x+(y-1)*w]!='#')
						b&=~4;
					if ((b&8) && maze[(x-1)+y*w]!='#')
						b&=~8;
					break;
				case ' ':
					b=0;
					break;
				case '.':
					pills++;
					b=128;
					break;
				case '*':
					pills++;
					b=129;
					break;
				case 'o':
					pills++;
					b=130;
					break;
				case 'X':
					chomper.startx=x;	
					chomper.starty=y;	
					b=0;
					break;
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
					ghosts[c-'1'].startx=x;
					ghosts[c-'1'].starty=y;
					if (c-'1'+1>numGhosts)
						numGhosts=c-'1'+1;	
					b=0;
					break;
			}	
			newmaze[x+y*w]=b;
		}
	
	for (x=0;x<w;x++)
		for (y=0;y<h;y++)
		{
		
			b=newmaze[x+y*w];
			if (!b)
			{
				sx=160;
				sy=0;
			}
			else
			{
				if (b>=128)
				{
					if (b==128)
					{
						sx=120;
						sy=0;
					}
					if (b==129)
					{
						sx=120;
						sy=40;
					}
					if (b==130)
					{
						sx=120;
						sy=80;
					}
				}
				else
				{
					if (b<8)
						sx=192;
					else
						sx=224;
					sy = (b&0x7)*32;
				}
			}
			SPRBlitter(img->img, img->dmaflags, sx, sy, SPRITESIZE, SPRITESIZE,
                	(char *)frame, DMAFLAGS, x*TILESIZE+OFFX, y*TILESIZE+OFFY,
                	TILESIZE*0x10000/SPRITESIZE, TILESIZE*0x10000/SPRITESIZE, 0,
                	0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
                	0x40000002, 0);
		}

}

/*
    Erase a "pill" from maze and screen
*/

void DeletePill(SPR_IMAGE_INFO *img, long *frame,int x,int y)
{
	myFillRect((void *)frame,DMAFLAGS,x*TILESIZE+OFFX-TILESIZE/2, y*TILESIZE+OFFY-TILESIZE/2,TILESIZE,TILESIZE,kBlack);
	maze[x+y*MAZE_W]=' ';
}

/*
 * wait for video
 * returns the number of elapsed fields
 * since the last sync
 */

int
VideoSync(void)
{
    static int frames;
    static int lastfield;
    static int lastsecond;
    int ret;

    int curfield;

    /* we want to view the buffer we just finished
       drawing */

    /* set the video to point at the drawn buffer */
    _VidChangeBase(VID_CHANNEL_MAIN,DMAFLAGS,FrameBuffer[drawBuffer]);

    /* find out how many fields have been drawn */
    curfield = _VidSync(-1);

    /* remember that we've drawn a frame */
    frames++;

    /* have more than 60 fields (1 second) passed? */
    if (curfield - lastsecond >= 60) {
        fps = frames;
        frames = 0;
        lastsecond = curfield;
    }

    /* draw to a new buffer */
    drawBuffer++;
    if (drawBuffer >= NUM_BUFFERS)
        drawBuffer = 0;

#if NUM_BUFFERS == 2
    /* wait until a new field starts (so it's no longer
       showing the field we're going to draw on) */
    curfield = _VidSync(0);
#endif

    ret = curfield - lastfield;
    while (ret == 0) {
        curfield = _VidSync(-1);
        ret = curfield - lastfield;
    }
    lastfield = curfield;
    return ret;
}

/*
    Start a score animation
*/

void StartScoreAnimation(int s,int x, int y)
{
	if (scani)
		SPRSetSpriteSource(scani,s*SPRITESIZE,6*SPRITESIZE,SPRITESIZE,SPRITESIZE);
	else
		scani=SPRCreateSprite(&source,s*SPRITESIZE,6*SPRITESIZE,SPRITESIZE,SPRITESIZE);
    
	SPRAddSprite(scani, x*TILESIZE+OFFX, y*TILESIZE+OFFY, 0, SCORESCALE, SCORESCALE, 0x40000002, kBlack, 1);
	SPRSetSpriteXY(scani,x*TILESIZE+OFFX, y*TILESIZE+OFFY);
	
	saphase=60;		
}

/*
    Continue score animation
*/

void DoScoreAnimation(void)
{
	if (saphase)
	{
		SPRSetSpriteScale(scani,SCORESCALE+(60-saphase)*0x444,SCORESCALE+(60-saphase)*0x444);
		SPRSetSpriteRotation(scani,(60-saphase)*0x800);
		saphase--;
		if (!saphase)
			SPRRemoveSprite(scani);	
	}	
}

/*
    Start dead ghost animation
*/

void StartGhostDeadAnimation(int g,int x, int y)
{
	ghosts[g].active=0;
    
	ghosts[g].ghostAx=x*TILESIZE+OFFX;
	ghosts[g].ghostAy=y*TILESIZE+OFFY;
	ghosts[g].gphase=60;
	ghosts[g].gincx=(MAZE_W/2-x)*TILESIZE/ghosts[g].gphase;		
	ghosts[g].gincy=(MAZE_H/2-y)*TILESIZE/ghosts[g].gphase;		
    SPRSetSpriteSource(ghosts[g].ghost,SPRITESIZE*4,SPRITESIZE*6,SPRITESIZE,SPRITESIZE);
    SPRSetSpriteScale(ghosts[g].ghost,0x20000/RATIO,0x20000/RATIO);
}

/*
    Control Chomperman (by joystick or remote control)
*/

void ControlChomperman(void)
{
	int edge,joystick,i;
	static int old_joystick;
	
    joystick = _Controller[1].buttons | _Controller[0].buttons; /* logical OR between joystick and remote */                                                                               
	edge = (joystick ^ old_joystick) & joystick; 
	if (edge && joystick)
		chomper.ndir=joystick;
		
	if (chomper.mphase)
	{
		chomper.chomperAx+=chomper.incx;
		chomper.chomperAy+=chomper.incy;
		SPRSetSpriteXY(chomper.chomperman,chomper.chomperAx,chomper.chomperAy);
//		SPRSetSpriteRotation(chomper.chomperman,chomper.angle);
	    SPRSetSpriteSource(chomper.chomperman,chomper.aphase*CHOMPERSIZE,CHOMPERSIZE*(chomper.angle/0x4000),SPRITESIZE,SPRITESIZE);
		chomper.mphase--;
		if (!chomper.mphase)
		{
			chomper.chomperx=chomper.nchomperx;
			chomper.chompery=chomper.nchompery;
			chomper.incx=chomper.incy=0;

			for(i=0;i<numGhosts;i++)
			if (ghosts[i].active && ghosts[i].ghostx==chomper.chomperx && ghosts[i].ghosty==chomper.chompery)
			{
				if (chase)
				{
					ghostsEaten++;
					PlayWAV((void *)GhostEatWav, -1, &Pan, 0x40000000, 0x40000000 );
					score+=ghostsEaten>2?800:400;
					StartScoreAnimation(ghostsEaten>2?3:2,chomper.chomperx,chomper.chompery);
					StartGhostDeadAnimation(i,chomper.chomperx,chomper.chompery);
				}
				else
				{
					PlayWAV((void *)ChomperDiesWav, -1, &Pan, 0x40000000, 0x40000000 );
					gameover=1;
				}
			}


			if (maze[chomper.chomperx+MAZE_W*chomper.chompery]=='.')
			{
				PlayWAV((void *)ChomperChompWav, -1, &Pan, 0x40000000, 0x40000000 );
				DeletePill(&source,MazeBuf,chomper.chomperx,chomper.chompery);
				score+=10;
				collected++;
			}
			if (maze[chomper.chomperx+MAZE_W*chomper.chompery]=='*')
			{
				PlayWAV((void *)FruitEatWav, -1, &Pan, 0x40000000, 0x40000000 );
				DeletePill(&source,MazeBuf,chomper.chomperx,chomper.chompery);
				score+=100;
				StartScoreAnimation(0,chomper.chomperx,chomper.chompery);
				collected++;
			}
			if (maze[chomper.chomperx+MAZE_W*chomper.chompery]=='o')
			{
				chasevoice=PlayWAV((void *)ChaseWav, 1, &Pan, 0x40000000, 0x40000000 );
				DeletePill(&source,MazeBuf,chomper.chomperx,chomper.chompery);
				ghostsEaten=0;
				score+=200;
				StartScoreAnimation(1,chomper.chomperx,chomper.chompery);
				chase=5*60;
				collected++;
			}
		}	
	} else
	{
		if (chomper.ndir&CTRLR_DPAD_RIGHT)
		{
			if (maze[(chomper.chomperx+1)+MAZE_W*chomper.chompery]!='#')
				chomper.direction=chomper.ndir;
		}else
		if (chomper.ndir&CTRLR_DPAD_LEFT)
		{
			if (maze[(chomper.chomperx-1)+MAZE_W*chomper.chompery]!='#')
				chomper.direction=chomper.ndir;
		}else
		if (chomper.ndir&CTRLR_DPAD_DOWN)
		{
			if (maze[chomper.chomperx+MAZE_W*(chomper.chompery+1)]!='#')
				chomper.direction=chomper.ndir;
		}else
		if (chomper.ndir&CTRLR_DPAD_UP)
			if (maze[chomper.chomperx+MAZE_W*(chomper.chompery-1)]!='#')
				chomper.direction=chomper.ndir;
				
		if (chomper.direction&CTRLR_DPAD_RIGHT)
		{
			if (maze[(chomper.chomperx+1)+MAZE_W*chomper.chompery]!='#')
			{
				chomper.nchomperx=chomper.chomperx+1;
				chomper.incx=INC;
				chomper.angle=0;
				chomper.mphase=TILESIZE/INC;
			}
			else
				chomper.direction=0;
		}
		else
		if (chomper.direction&CTRLR_DPAD_LEFT)
		{
			if (maze[(chomper.chomperx-1)+MAZE_W*chomper.chompery]!='#')
			{
				chomper.nchomperx=chomper.chomperx-1;
				chomper.incx=-INC;
				chomper.angle=0x8000;
				chomper.mphase=TILESIZE/INC;
			}
			else
				chomper.direction=0;
		}
		else
		if (chomper.direction&CTRLR_DPAD_DOWN)
		{
			if (maze[chomper.chomperx+MAZE_W*(chomper.chompery+1)]!='#')
			{
				chomper.nchompery=chomper.chompery+1;
				chomper.incy=INC;
				chomper.angle=0x4000;
				chomper.mphase=TILESIZE/INC;
			}
			else
			{
				chomper.direction=0;
			}
		}
		else
		{
			if (chomper.direction&CTRLR_DPAD_UP)
			{
				if (maze[chomper.chomperx+MAZE_W*(chomper.chompery-1)]!='#')
				{
					chomper.nchompery=chomper.chompery-1;
					chomper.incy=-INC;
					chomper.angle=0xc000;
					chomper.mphase=TILESIZE/INC;
				}
				else
					chomper.direction=0;
			}
		}
		chomper.chomperAx=chomper.chomperx*TILESIZE+OFFX;
		chomper.chomperAy=chomper.chompery*TILESIZE+OFFY;
	}
	old_joystick=joystick;
}

/*
    Ghost AI
*/

void ControlGhost(int g)
{
	int x,y,c,visual,i;
    int ways,pw[4],sight[4];
	char savemaze[1024];		
	int destx,desty;
			
	if (ghosts[g].gphase)
	{
		ghosts[g].ghostAx+=ghosts[g].gincx;
		ghosts[g].ghostAy+=ghosts[g].gincy;
		SPRSetSpriteXY(ghosts[g].ghost,ghosts[g].ghostAx,ghosts[g].ghostAy);
		ghosts[g].gphase--;
		if (!ghosts[g].gphase)
		{
			if (!ghosts[g].active)
				InitGhost(g);
				
			ghosts[g].ghostx=ghosts[g].nghostx;
			ghosts[g].ghosty=ghosts[g].nghosty;
			ghosts[g].gincx=ghosts[g].gincy=0;
			
			if (ghosts[g].active)
			if (ghosts[g].ghostx==chomper.chomperx && ghosts[g].ghosty==chomper.chompery)
			{
				if (chase)
				{
					ghostsEaten++;
					PlayWAV((void *)GhostEatWav, -1, &Pan, 0x40000000, 0x40000000 );
					score+=ghostsEaten>2?800:400;
					StartScoreAnimation(ghostsEaten>2?3:2,chomper.chomperx,chomper.chompery);
					StartGhostDeadAnimation(g,chomper.chomperx,chomper.chompery);
				}
				else
				{
					PlayWAV((void *)ChomperDiesWav, -1, &Pan, 0x40000000, 0x40000000 );
					gameover=1;
				}
			}

		}	
	}
	else
	{

		destx=chomper.chomperx;
		desty=chomper.chompery;
		
		if (chase)
		{
			destx=MAZE_W-destx;
			desty=MAZE_H-destx;
		}

		x=ghosts[g].ghostx;	
		y=ghosts[g].ghosty;	




	/* Do we have visual contact with chomperman?*/
		visual=0;
		
		x=ghosts[g].ghostx;	
		y=ghosts[g].ghosty;	
		sight[3]=0;
		do
		{
			sight[3]++;
			y--;
			c=maze[x+y*MAZE_W];
			if (c!='#')
			{
				if (y==desty && x==destx)
				{
					visual=1;
					ghosts[g].way=3;
					break;					
				}
			}
		} while (c!='#');
		if (!visual)
		{
			x=ghosts[g].ghostx;	
			y=ghosts[g].ghosty;	
			sight[2]=0;
			do
			{
				sight[2]++;
				y++;
				c=maze[x+y*MAZE_W];
				if (c!='#')
				{
					if (y==desty && x==destx)
					{
						visual=1;
						ghosts[g].way=2;
						break;					
					}
				}
			} while (c!='#');
		}
		if (!visual)
		{
			x=ghosts[g].ghostx;	
			y=ghosts[g].ghosty;	
			sight[1]=0;
			do
			{
				sight[1]++;
				x--;
				c=maze[x+y*MAZE_W];
				if (c!='#')
				{
					if (y==desty && x==destx)
					{
						visual=1;
						ghosts[g].way=1;
						break;					
					}
				}
			} while (c!='#');
		}
		if (!visual)
		{
			x=ghosts[g].ghostx;	
			y=ghosts[g].ghosty;	
			sight[0]=0;
			do
			{
				sight[0]++;
				x++;
				c=maze[x+y*MAZE_W];
				if (c!='#')
				{
					if (y==desty && x==destx)
					{
						visual=1;
						ghosts[g].way=0;
						break;					
					}
				}
			} while (c!='#');
		}


/* Go into direction of ChomperMan if possible*/

		if (!visual)
		{
			i=rand()%3+1;
			x=ghosts[g].ghostx;	
			y=ghosts[g].ghosty;	
			if (sight[0]>i && ghosts[g].last_way!=1 && destx>x)
			{
				visual=1;
				ghosts[g].way=0;
			}		
			if (sight[1]>i && ghosts[g].last_way!=0 && destx<x)
			{
				visual=1;
				ghosts[g].way=1;
			}		
			if (sight[2]>i && ghosts[g].last_way!=3 && desty>y )
			{
				visual=1;
				ghosts[g].way=2;
			}		
			if (sight[3]>i && ghosts[g].last_way!=2 && desty<y)
			{
				visual=1;
				ghosts[g].way=3;
			}		
		}

/* Go somewhere where we never have been (the last 16 moves)  */

		memcpy(savemaze,maze,MAZE_W*MAZE_H);
		if (!visual)
		{
			i=ghosts[g].out;
			while(i!=ghosts[g].in)
			{
				maze[ghosts[g].hist[i]]='#';
				i++;
				if (i==16)
					i=0;
			}

		/* Now pick random direction*/

			ways=0;
			if (maze[(x+1)+y*MAZE_W]!='#') pw[ways++]=0;
			if (maze[(x-1)+y*MAZE_W]!='#') pw[ways++]=1;
			if (maze[x+(y+1)*MAZE_W]!='#') pw[ways++]=2;
			if (maze[x+(y-1)*MAZE_W]!='#') pw[ways++]=3;

			memcpy(maze,savemaze,MAZE_W*MAZE_H);
			if (!ways)
			{
				if (maze[(x+1)+y*MAZE_W]!='#') pw[ways++]=0;
				if (maze[(x-1)+y*MAZE_W]!='#') pw[ways++]=1;
				if (maze[x+(y+1)*MAZE_W]!='#') pw[ways++]=2;
				if (maze[x+(y-1)*MAZE_W]!='#') pw[ways++]=3;
			}

			ghosts[g].way=pw[rand()%ways];

		}	

			
		x=ghosts[g].ghostx;	
		y=ghosts[g].ghosty;

		
		switch(ghosts[g].way)
		{

			case 0:
				if (maze[(x+1)+y*MAZE_W]!='#')
				{
					ghosts[g].gphase=TILESIZE/INCG;
					ghosts[g].gincx=INCG;
					ghosts[g].nghostx=x+1;
				}
				else
					ghosts[g].way=-1;
			break;		
			case 1:
				if (maze[(x-1)+y*MAZE_W]!='#')
				{
					ghosts[g].gphase=TILESIZE/INCG;
					ghosts[g].gincx=-INCG;
					ghosts[g].nghostx=x-1;
				}		
				else
					ghosts[g].way=-1;
			break;		
			case 2:
				if (maze[x+(y+1)*MAZE_W]!='#')
				{
					ghosts[g].gphase=TILESIZE/INCG;
					ghosts[g].gincy=INCG;
					ghosts[g].nghosty=y+1;
				}		
				else
					ghosts[g].way=-1;
			break;		
			case 3:
				if (maze[x+(y-1)*MAZE_W]!='#')
				{
					ghosts[g].gphase=TILESIZE/INCG;
					ghosts[g].gincy=-INCG;
					ghosts[g].nghosty=y-1;
				}
				else
					ghosts[g].way=-1;
			break;
		}
		ghosts[g].last_way=ghosts[g].way;		


		i=ghosts[g].in;
		ghosts[g].hist[i]=ghosts[g].nghostx+MAZE_W*ghosts[g].nghosty;
		i++;
		if(i==16)
			i=0;
		if (i==ghosts[g].out)
		{
			ghosts[g].out++;
			if (ghosts[g].out==16)
				ghosts[g].out=0;	
		}
		ghosts[g].in=i;
	}
}

/*
    Initialize ghosts
*/


void InitGhost(int i)
{
	ghosts[i].active=1;
	ghosts[i].way=-1;
	ghosts[i].gphase=ghosts[i].gincx=ghosts[i].gincy=0;
	ghosts[i].nghosty=ghosts[i].ghosty=ghosts[i].starty;
	ghosts[i].nghostx=ghosts[i].ghostx=ghosts[i].startx;
	ghosts[i].ghostAy=ghosts[i].ghosty*TILESIZE+OFFY;
	ghosts[i].ghostAx=ghosts[i].ghostx*TILESIZE+OFFX;
	ghosts[i].hist[0]=ghosts[i].ghostx+MAZE_W*ghosts[i].ghosty;
	ghosts[i].in=ghosts[i].out=0;	
    if (SPRAddSprite(ghosts[i].ghost, ghosts[i].ghostAx, ghosts[i].ghostAy, 0, GHOSTSCALE, GHOSTSCALE, 0x40000002, kBlack, 1)<0)
		SPRModifySprite(ghosts[i].ghost, ghosts[i].ghostAx, ghosts[i].ghostAy, 0, GHOSTSCALE, GHOSTSCALE, 0x40000002, kBlack, 1);
    SPRSetSpriteSource(ghosts[i].ghost,CHOMPERSIZE*(i%3),CHOMPERSIZE*4,SPRITESIZE,SPRITESIZE);

}

/*
    Initialize all sprites
*/

void InitSprites()
{
	int i;
    for(i=0;i<numGhosts;i++)
		InitGhost(i);

	chase=0;
	chomper.direction=0;
	chomper.nchomperx=chomper.chomperx=chomper.startx;
	chomper.nchompery=chomper.chompery=chomper.starty;
	chomper.chomperAx=chomper.chomperx*TILESIZE+OFFX;
	chomper.chomperAy=chomper.chompery*TILESIZE+OFFY;
	chomper.incx=chomper.incy=chomper.mphase=0;
    if (SPRAddSprite(chomper.chomperman, chomper.chomperx*TILESIZE+OFFX, chomper.chompery*TILESIZE+OFFY, 0, CHOMPERSCALE, CHOMPERSCALE, 0x40000002, kBlack, 1)<0)
		SPRModifySprite(chomper.chomperman, chomper.chomperx*TILESIZE+OFFX, chomper.chompery*TILESIZE+OFFY, 0, CHOMPERSCALE, CHOMPERSCALE, 0x40000002, kBlack, 1);
}

/*
    Wait for a joystick (or remote) button
*/

void WaitForJoysick(int but)
{
	int edge,joystick;
	int old_joystick=0;
	
    do
	{
		joystick = _Controller[1].buttons |_Controller[0].buttons;                                                                               
		edge = (joystick ^ old_joystick) & joystick; 
		old_joystick = joystick;
	} while (!(edge & but));
}

/*
    Draw Score
*/

void DrawScore(char *frame,int x,int y)
{
	char temp[256],*s;
	
#if 1
	sprintf(temp,"%05d",score);
#else
	sprintf(temp,"%d",fps);
#endif
	s=temp;
	while(*s)
	{
		SPRBlitter(DigitsScr.img, DigitsScr.dmaflags, 1+(int)(*s-'0')*32, 1, 30, 30,
            	frame, DMAFLAGS, x, y,
            	SCORESCALE, SCORESCALE, 0x10000,
            	0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
            	0x40000002, kBlack);
		s++;
		x+=24*SCORESCALE/0x10000;
	}
	
	x+=24*SCORESCALE/0x10000;
	SPRBlitter(DigitsScr.img, DigitsScr.dmaflags, 1+lives*32, 1, 30, 30,
            frame, DMAFLAGS, x, y,
            SCORESCALE, SCORESCALE, 0x10000,
            0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
            0x40000002, kBlack);
	x+=24*SCORESCALE/0x10000;
	SPRBlitter(DigitsScr.img, DigitsScr.dmaflags, 384, 0, 32, 32,
            frame, DMAFLAGS, x, y,
            SCORESCALE, SCORESCALE, 0x10000,
            0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
            0x40000002, kBlack);
	x+=24*SCORESCALE/0x10000;
	SPRBlitter(source.img, source.dmaflags, 40, 0, 32, 32,
            frame, DMAFLAGS, x, y,
            LIVESSCALE, LIVESSCALE, 0x10000,
            0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
            0x40000002, kBlack);
}

/*
    Main loop
*/

int main()
{
    int i,ret,fr,next,pinc;
	VidDisplay display;
	VidChannel mainchannel;
	
    /* Setup audio */

   	AUDIOInit();

    Pan.PCMPanLR = 0;
    Pan.PCMPanFB = 0;
    Pan.PCMPanUD = 0;

    /* Get some local memory for DMA */

	localScratch=_MemLocalScratch(&localSize);
	
    /* Setup video */

    for(i=0;i<NUM_BUFFERS;i++)
	    FrameBuffer[i]=_MemAlloc(SCREEN_WIDTH*SCREEN_HEIGHT*4,512,kMemSDRAM);
	MazeBuf=_MemAlloc(SCREEN_WIDTH*SCREEN_HEIGHT*4,512,kMemSDRAM);

	myFillRect(MazeBuf,DMAFLAGS,0,0,SCREEN_WIDTH,SCREEN_HEIGHT,kBlack);

 	display.dispwidth = -1;
	display.dispheight = -1;
	display.bordcolor=0x20100000;
	display.progressive=0;
	for(i=0;i<6;i++)
		display.reserved[i]=0;
	
	mainchannel.dmaflags=DMAFLAGS;
	mainchannel.base=FrameBuffer[0];
	mainchannel.dest_xoff = -1;
	mainchannel.dest_yoff = -1;
	mainchannel.dest_width = 720;
	mainchannel.dest_height = 480;
	mainchannel.src_xoff = 0;
	mainchannel.src_yoff = 0;
	mainchannel.src_width = SCREEN_WIDTH;
	mainchannel.src_height = SCREEN_HEIGHT;
	mainchannel.clut_select=0;
	mainchannel.alpha=0;
	mainchannel.vfilter=VID_VFILTER_2TAP;
	mainchannel.hfilter=VID_HFILTER_4TAP;
	for(i=0;i<5;i++)
		mainchannel.reserved[i]=0;
   
    InitTerminalX(0,(int)FrameBuffer[0],SCREEN_WIDTH, SCREEN_HEIGHT, DMAFLAGS, kBlack);                                                              
    _VidConfig ( &display, &mainchannel, 0, 0L); 

	srand(_VidSync(-1));
			
    /* Use MPEs 0,1 and 2 for rendering, 16 pixel slices */
   
    SPRInit(0,2,16);

    /* Set to the second framebuffer */
   
    SPRSetDestScreen(FrameBuffer[1], DMAFLAGS,  0,  0,  SCREEN_WIDTH-1,  SCREEN_HEIGHT-1, kBlack);
    
    /* Install the TGA images */
   
    SPRInstallTGAImage(SpriteImage, 1, &source, 0x04020400);
    SPRInstallTGAImage(StartScreen, 1, &StartScr, 0x00);
    SPRInstallTGAImage(GameOverScreen, 1, &GameOverScr, 0x00);
    SPRInstallTGAImage(GameCompleteScreen, 1, &CompleteScr, 0x00);
    SPRInstallTGAImage(LevelCompleteScreen, 1, &LevelScr, 0x00);
    SPRInstallTGAImage(Digits, 1, &DigitsScr, 0x00);

    /* Create sprites */

    for(i=0;i<MAX_GHOSTS;i++)
        ghosts[i].ghost=SPRCreateSprite(&source,CHOMPERSIZE*(i%3),CHOMPERSIZE*4,SPRITESIZE,SPRITESIZE);
    chomper.chomperman=SPRCreateSprite(&source,CHOMPERSIZE,0,SPRITESIZE+1,SPRITESIZE+1);

    /* main game loop */

	for(;;)
	{
	
	    /* Start screen */

		myFillRect(FrameBuffer[0],DMAFLAGS,0, 0,720,480,kBlack);
	    _VidChangeBase(VID_CHANNEL_MAIN,DMAFLAGS,FrameBuffer[0]);

		SPRBlitter(StartScr.img, StartScr.dmaflags, 0, 0, 600, 400,
            	FrameBuffer[0], DMAFLAGS, SCREEN_WIDTH/2, SCREEN_HEIGHT/2,
            	0x10000*SCREEN_WIDTH/720, 0x10000*SCREEN_HEIGHT/480, 0,
            	0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
            	0x40000002, 0);

		WaitForJoysick(JOY_START);

		score=0;
		lives=2;
		level=0;
		extra=1000;  /* next extra life at 1000 points */
		
	    /* Level loop */

		do
		{
			ret=PlayWAV((void *)GameBeginWav, -1, &Pan, 0x40000000, 0x40000000 );

			collected=0;
			delay=0;
			pDividerCnt=pDivider=1;
			gDividerCnt=gDivider=levels[level].gDivider;

			memcpy(maze,levels[level].maze,MAZE_W*MAZE_H);
			myFillRect(MazeBuf,DMAFLAGS,0, 0,SCREEN_WIDTH,SCREEN_HEIGHT,kBlack);
			CreateMaze(&source, MazeBuf, maze, MAZE_W, MAZE_H);

			InitSprites();

			for(i=0;i<NUM_BUFFERS;i++)
			{
				myFillRect(FrameBuffer[i],DMAFLAGS,0, 0,SCREEN_WIDTH,SCREEN_HEIGHT,kBlack);
				CopyMaze(FrameBuffer[i],MazeBuf,SCREEN_WIDTH*SCREEN_HEIGHT*4/256);
			}

			next=chomper.aphase=0;
			pinc=1;


		    /* Inner game play loop */
    	
			for(;;)
    		{
				if (score>extra)
				{
					PlayWAV((void *)ExtraChomperWav, -1, &Pan, 0x40000000, 0x40000000 );
					lives++;
					extra+=2000;
				}
				if (delay)
					_TimeToSleep(delay);

				if (collected==pills)
				{
				    /* Level done */
				
					PCMVoiceOff(chasevoice);
					level++;
			    	DrawScore(FrameBuffer[drawBuffer],SCOREX,SCOREY);
					if (level==NUMLEVELS)
					{
						SPRBlitter(CompleteScr.img, CompleteScr.dmaflags, 0, 0, 256, 128,
            					FrameBuffer[drawBuffer], DMAFLAGS, SCREEN_WIDTH/2, SCREEN_HEIGHT/2,
            					0x18000*SCREEN_WIDTH/720, 0x18000*SCREEN_HEIGHT/480, 0,
            					0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
            					0x40000002, 0);

					}
					else
					{
						SPRBlitter(LevelScr.img, LevelScr.dmaflags, 0, 0, 256, 128,
            					FrameBuffer[drawBuffer], DMAFLAGS, SCREEN_WIDTH/2, SCREEN_HEIGHT/2,
            					0x18000*SCREEN_WIDTH/720, 0x18000*SCREEN_HEIGHT/480, 0,
            					0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
            					0x40000002, 0);

					}
			    	VideoSync();
					WaitForJoysick(JOY_A);
					break;
				}
				if (chase)
				{
    				for(i=0;i<numGhosts;i++)
						if (ghosts[i].active)
							SPRSetSpriteType(ghosts[i].ghost,0x2+(chase%32)*0x2000000+0x2000000);
						else
							SPRSetSpriteType(ghosts[i].ghost,0x40000002);
					chase--;
					if (!chase)
    				{
						for(i=0;i<numGhosts;i++)
							SPRSetSpriteType(ghosts[i].ghost,0x40000002);
						PCMVoiceOff(chasevoice);
					}
				}
				if (gameover)
				{
				    /* Game over */

					if (PCMGetUsedVoices())
					{
						SPRSetSpriteRotation(chomper.chomperman,gameover*0x800);
						SPRSetSpriteScale(chomper.chomperman,CHOMPERSCALE-gameover*0x100/RATIO,CHOMPERSCALE-gameover*0x100/RATIO);
						gameover++;
					}
					else
					{
						lives--;
						gameover=0;
						InitSprites();
						if (!lives)
						{
			        		DrawScore(FrameBuffer[drawBuffer],80,420);
							SPRBlitter(GameOverScr.img, GameOverScr.dmaflags, 0, 0, 256, 128,
            						FrameBuffer[drawBuffer], DMAFLAGS, SCREEN_WIDTH/2, SCREEN_HEIGHT/2,
            						0x10000*SCREEN_WIDTH/720, 0x10000*SCREEN_HEIGHT/480, 0,
            						0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
            						0x40000002, 0);

			        		VideoSync();
							WaitForJoysick(JOY_A);
							level=NUMLEVELS; /* force restart */
							break;
						}
					}
				}
				else
				{
					pDividerCnt--;
					if (!pDividerCnt)
					{
						ControlChomperman();
						pDividerCnt=pDivider;
					}
					gDividerCnt--;
					if (!gDividerCnt)
					{
						for (i=0;i<numGhosts;i++)
							ControlGhost(i);
						gDividerCnt=gDivider;
					}
					DoScoreAnimation();

					fr=_VidSync(-1);
					if (fr>next && chomper.direction)
					{
						next=fr+4;
						SPRSetSpriteSource(chomper.chomperman,chomper.aphase*CHOMPERSIZE,CHOMPERSIZE*(chomper.angle/0x4000),SPRITESIZE,SPRITESIZE);
						
						chomper.aphase+=pinc;
						if (chomper.aphase==0 || chomper.aphase==2) pinc=-pinc;
					}
      			}
        		VideoSync();


				CopyMaze(FrameBuffer[drawBuffer],MazeBuf,SCREEN_WIDTH*SCREEN_HEIGHT*4/256);

        		/* print Score */   

        		DrawScore(FrameBuffer[drawBuffer],SCOREX,SCOREY);

				if (chase)
					myFillRect(FrameBuffer[drawBuffer],DMAFLAGS,CHASEBARX, CHASEBARY,chase/RATIO,TILESIZE,kGreen);

        		/* Process display list */   

	    		SPRSetDestScreen(FrameBuffer[drawBuffer], DMAFLAGS,  0,  0,  SCREEN_WIDTH-1,  SCREEN_HEIGHT-1, kBlack);
        		SPRDraw(0,0);


        		SPRWait();

    		}
		} while (level<NUMLEVELS);
	}
}
