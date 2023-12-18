#include <sys/stat.h>
#include <stdio.h>
#include <string.h>
#include <nuon/cdn50x.h>
#include <nuon/termemu.h>
#include <nuon/synth.h>
#include <nuon/joystick.h>


char buffer[128000];
char out[1024];
void *vol;
volatile int eof = 0;
long joystick, oldjoystick=0;
int files;

int WalkDir(char *path,iso_dir *dir)
{
	int ret,err,l;
	void *f;
	char name[256];
	char newpath[256];
	struct stat st;
	iso_dir ndir;
  	long edge;
	
	for(;;)
	{
		ret=iso_readdir(vol,dir,name,&st,&err);
		if (!ret || err)
			break;

		strcpy(newpath,path);
		strcat(newpath,name);
		if (st.st_mode&S_IFDIR)
		{
			strcat(newpath,"/");
			iso_opendir(vol,newpath,&ndir,&err);
			WalkDir(newpath,&ndir);
		}
		else
		{
			if (strstr(name,".mid"))
			{
				files++;
				sprintf(out,"Loading %s",name);
				Print(out,kWhite,kBlack);

				f=iso_open(vol,newpath,0,0,&err);
				if (!err)
				{
					l=iso_read(vol,f,buffer,128000,&err);
					iso_close(vol,f,&err);
					
					eof=0;
					SYNTHStartMidiParserFeedback(buffer,3,0,0);
					for(;;)
					{
				   		joystick = _Controller[1].buttons | _Controller[0].buttons;
						edge = (joystick ^ oldjoystick) & joystick;
						if (eof)
							break;
						if (edge & JOY_A)
						{
							SYNTHStopMidiParser();
							break;
						}
						oldjoystick = joystick;
					}
				}
				else
					Print("Error loading file!",kRed,kBlack);
			}
		}
	}

	return 0;
}


void SynthFeedback (long p0,long p1,long p2,long p3)
{
	
	if (((p3>>24)&0xff) == END_OF_TRACK_ID)
	{
		eof = 1;
	}
}

AUDIO_RESOURCES res = {
			2,	/* Use MPE 2 for synth, because MPE 1 is used for CD reading! */
			0L,	/* Use malloc for synth tables */
			0L,	/* use default 0x407fc000 */
			0L	/* use default 0x80e80000 */
			};

int main()
{
	int err;
	iso_dir root;

	AUDIOInitX(&res);
	AUDIOMixer(0x20000000,0x20000000);
	SYNTHInstallCB(SynthFeedback);

	InitTerminal(0,1);
	Print("MIDI Player",kGreen,kBlack);

	CDInit();
	vol=iso_init(0,&err);
	if (err)
	{
		Print("iso_init failed!",kRed,kBlack);
		for(;;);
	}

	for(;;)
	{
		files=0;
		Print("Scanning CD...",kGreen,kBlack);
		/* Walk the entire CD and play each .MID file */	 
		iso_opendir(vol,"/",&root,&err);
		WalkDir("/",&root);
		if (!files)
		{
			Print("No MIDI files!",kRed,kBlack);
			for(;;);
		}
	}
}
