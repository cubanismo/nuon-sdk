#include <nuon/mutil.h>
#include <nuon/synth.h>

#define PATCHNUM 51
/**************************************************************************/
/**************************************************************************/
/**************************************************************************/


#define MIDIDIRECT 	(1)
#define LOWLEVEL 	(1)
#define HIGHLEVEL 	(0)

#define TIMER 		(0)

static AUDIO_RESOURCES audiorsc = { 1, 0, 0, 0 };

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

void delay(void)
{
#if TIMER
	long time,sec,usec;
	time=GetTimer(&sec,&usec);
	while (GetTimer(&sec,&usec)<time+100);	
#else
	long l;
	for(l=0;l<1000000;l++);
#endif
}



int main()
{
	short note,i,j;
	long voices[16];

#if HIGHLEVEL
short			id;
long 			packet[4], info[4];
unsigned char 	event[4];
#endif	


#if TIMER
	InitTimer();
#endif
	        	
	AUDIOInitX(&audiorsc);

	for( i = 0; i < 16; i++ )
		SYNTHMidiControlChange(i,7,127);

	for(;;)
	{


#if MIDIDIRECT	
// Playing some notes using the Midi Direct API

		SYNTHMidiProgramChange(0,PATCHNUM);
		
		for (j=0;j<12;j++)
		{
			for (i=0,note=36; i<3; i++,note+=12)
			{
		  		SYNTHMidiNoteOn(0,note+j,127);
  				delay();
			}
			
			for (i=0,note=36; i<3; i++,note+=12)
			{
		  		SYNTHMidiNoteOff(0,note+j,0);
  				
  				delay();
			}
		}	
#endif
#if LOWLEVEL
// Doing the same thing using the Low Level API

		for (j=0;j<12;j++)
		{
			for (i=0,note=36; i<3; i++,note+=12)
			{
		  		voices[i]=SYNTHNoteOn(PATCHNUM,note+j,127);

  				delay();
			}
			
			for (i=0; i<3; i++)
			{
		  		SYNTHNoteOff(voices[i]);

  				delay();
			}	
		}
#endif
#if HIGHLEVEL		
// Again, but now using the High Level API
		event[0]=0xC0;
		event[1]=PATCHNUM;
		SYNTHSendMidiEvents(event,2);

		for (j=0;j<12;j++)
		{
			for (i=0,note=36; i<3; i++,note+=12)
			{
				event[0]=0x90;
				event[1]=(unsigned char)note+j;
				event[2]=127;
		  		SYNTHSendMidiEvents(event,3);
  				
  				delay();
			}
			
			for (i=0,note=36; i<3; i++,note+=12)
			{
				event[0]=0x80;
				event[1]=(unsigned char)note+j;
				event[2]=127;
		  		SYNTHSendMidiEvents(event,3);
  				
  				delay();
			}
		}
#endif
	}
}
