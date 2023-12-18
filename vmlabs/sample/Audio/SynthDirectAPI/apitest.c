#include <nuon/mutil.h>
#include <nuon/synth.h>
#include <stdio.h>


#define PATCHNUM 51

#define BANK0_WAVETABLE 0

extern long stopTransfer;
#if	BANK0_WAVETABLE
extern short Bank0[];
#endif

#define TIMER 0

AUDIO_RESOURCES res = {
			1,	/* Use MPE 1 for synth */
			0L,	/* Use malloc for synth tables */
			0L,	/* use default 0x407fc000 */
			0L	/* use default 0x80e80000 */
			};

 
void delay(void)
{
#if TIMER
	long time,sec,usec:
	time=GetTimer(&sec,&usec);
	while (GetTimer(&sec,&usec)<time+100);	
#else
	long l;
	for(l=0;l<1000000;l++);
#endif
}

int main()
{
	short note,i,j,id;
	long voices[16],info[4],packet[4],bend;
	unsigned char event[4];

	printf ( "SynthDirectAPI test built %s %s\n", __DATE__, __TIME__ );
#if	BANK0_WAVETABLE
	printf ( "Using alternate wavetable.\n" );
#endif
#if	TIMER
	printf ( "Running timer.\n" );
#endif
#if	MIDIDIRECT
	printf ( "Compiled with MIDIDIRECT.\n" );
#endif
#if	LOWLEVEL
	printf ( "Compiled with LOWLEVEL.\n" );
#endif
#if	HIGHLEVEL
	printf ( "Compiled with HIGHLEVEL.\n" );
#endif
#if	LOADTEST
	printf ( "Compiled with LOADTEST.\n" );
#endif
	fflush ( stdout );
	
#if TIMER
	InitTimer();
#endif
	        	
#if	BANK0_WAVETABLE
	res.ramWavetableStart = Bank0;
	AUDIOInitX(&res);
#else
	res.ramWavetableStart = 0;
	AUDIOInitX( &res );
#endif
	delay();

	for(;;)
	{

#if LOADTEST	
// Try to overload the synth with too many calls at once
// Tests if flow control works

	SYNTHMidiProgramChange(0,PATCHNUM);

	for (i=0,note=36; i<6; i++,note+=12)
	{
		SYNTHMidiNoteOn(0,note,127);
//		delay();
	}
	
	
#if 1
	for (bend=0x2000; bend<0x4000; bend+=0x10)
	{
		SYNTHMidiPitchBend(0,bend);
//		delay();
	}
#endif	
//	for(;;);
	
	for (i=0;i<50;i++)
		delay();
		
#if 1
	for (bend=0x2000; bend>=0; bend-=0x10)
	{
		SYNTHMidiPitchBend(0,bend);
	}
	
#endif	
	for (i=0,note=36; i<6; i++,note+=12)
	{
		SYNTHMidiNoteOff(0,note,0);
//		delay();
	}
	
//	for(;;);

	for (i=0;i<50;i++)
		delay();
		
#endif

#if MIDIDIRECT	
		printf ( "Midi Direct API test...\n" );
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
		printf ( "Low level API test...\n" );
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
		printf ( "High level API test...\n" );
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
		printf ( "Done.\n" ); fflush ( stdout );
	}
}

