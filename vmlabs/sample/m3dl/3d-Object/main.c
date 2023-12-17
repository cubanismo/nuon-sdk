
/*Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/*
 * Main Code
 *
 */
#include <nuon/bios.h>
#include <m3dl/m3dl.h>
#include <nuon/joystick.h>
#include <nuon/video.h>
#include <nuon/mutil.h>

int	main()
{
	/*Texture Info*/
	mdTEXTURE		*texture;
	mdBITMAP		*bitmap;
	mdUINT32		numtexs;				//#of Textures/MBM
	mdUINT32		numbms; 	      //#of Bitmaps/MBM

	/*Structures for testing different Screen Modes*/
	mdDRAWCONTEXT dcx[2];				//Draw Context Structures
	mdUINT32		sdramaddr;			//Help variable
	mdUINT32		sdramlen;				//Help variable

	/*Miscellaneous*/
	mdUINT32		loop;						//Loop Flag
	mdUINT32		frames;					//Number of Frames elapsed

	mdMATRIX		cameramatrix; 	//Camera Matrix
	mdV3				camangle;				//Camera Angle
	mdV3				campos;					//Camera Position

	/*Color*/
	mdCOLOR			dpq;						//Depth Cue Color

	//ClearTile
	mdTILE cleartile;
	mdCOLOR clearcolor;

	//Object
	extern mdBYTE object[];
	extern mdBYTE objtex[];


	//Setup screen
	sdramaddr = 0x40000000;
	sdramlen = mdSetBufGRB16B_WITHZ_YCC32B(dcx, (mdBYTE*)(sdramaddr), 360, 240, 20, 8, 320, 224);
	VidSetup((mdBYTE*)(dcx[1].buf[dcx[1].actbuf].sdramaddr),dcx[1].buf[dcx[1].actbuf].dmaflags, dcx[1].dispw, dcx[1].disph,2);
	sdramaddr += sdramlen;

	// Setup Test Texture
	mdGetMBMInfo(objtex,&numtexs,&numbms);
	if ((numtexs > 0) && (numbms > 0)) {
		texture = (mdTEXTURE*)(malloc(numtexs*sizeof(mdTEXTURE)));
		bitmap = (mdBITMAP*)(malloc(numbms*sizeof(mdBITMAP)));
//		mdTextureFromMBM(objtex,(mdBYTE*)(sdramaddr),texture,bitmap);
		mdTextureFromMBM(objtex,0,texture,bitmap);
	};

	// Set DPQ Color
	mdSetRGB(&dpq,0,100,200);

	//Set Viewing Frustrum
	mdSetFrustum((60<<16)/360, 320, 224, ((11<<16)/8), 16<<16, 5000<<16);
	mdSetFogNearFar((512<<16),(5000<<16));

	//Syncronize with VBlank
	frames = 1; loop = 1;
	_VidSync(1);

	//Setup MPR
	mdSetupMPRChain(1,2);

	//Clear ALL Draw areas of drawcontext (DO not execute on a per frame basis!)
	mdSetRGB(&clearcolor,0,0,0);
	mdClearDraw(dcx, &clearcolor);

	//Clear ALL Display areas of drawcontext (DO not execute on a per frame basis!)
	mdSetRGB(&clearcolor,0,0,0);
	mdClearDisp(dcx, &clearcolor);

	//Wait for MPR activity to finish
	mdDrawSync();								//Wait for ClearDraw & ClearDisp

	//Setup Clear Screen Sprite (Only Rendering Window)
	mdSetRGB(&cleartile.color,0,100,200);
	mdSetScrRECT(&cleartile.sr,dcx[0].rendx<<4,dcx[0].rendy<<4,mdGetFarZ(),dcx[0].rendw<<4,dcx[0].rendh<<4);

	//Setup Camera position
	campos.x = 0<<16;
	campos.y = -100<<16;
	campos.z = -350<<16;
	camangle.x = 0<<16;
	camangle.y = 0<<16;
	camangle.z = 0<<16;

	while (loop) {
		//Set MPR Screen Buffer
		mdActiveDrawContext(&dcx[0]);
		mdSetFogColor(&dpq);

		/*
		 mdSetFogColor() is another name for mdActiveBlendColor()
		 This MUST be set AFTER mdActiveDrawContext() to make sure the color
		 is converted to the correct pixel mode (16Bit/32Bit)
		*/

		//Clear Rendering Window
		mdDrawTile(mpTILE_FZ, &cleartile.sr, &cleartile.color);

		//Set Camera Orientation & Position
		mdIdentityMatrix(&cameramatrix);
		mdTransMatrix(&cameramatrix,-campos.x,-campos.y,-campos.z);
		mdRotMatrixY(-camangle.y,&cameramatrix);
		mdSetTransformMatrix(&cameramatrix);

		//Some Buttons
		if (ButtonRight(_Controller[1])) {
			camangle.y += ((1<<16)/360)*frames;
		} else if (ButtonLeft(_Controller[1])) {
			camangle.y -= ((1<<16)/360)*frames;
		};
		if (ButtonUp(_Controller[1])) {
			campos.y -= (8<<16)*frames;
		};
		if (ButtonDown(_Controller[1])) {
			campos.y += (8<<16)*frames;
		};
		if (ButtonA(_Controller[1])) {
			campos.x += frames*(MPT_TransformMatrix.m[2][0]>>(28-16-2));
			campos.y += frames*(MPT_TransformMatrix.m[2][1]>>(28-16-2));
			campos.z += frames*(MPT_TransformMatrix.m[2][2]>>(28-16-2));
		};
		if (ButtonB(_Controller[1])) {
			campos.x -= frames*(MPT_TransformMatrix.m[2][0]>>(28-16-2));
			campos.y -= frames*(MPT_TransformMatrix.m[2][1]>>(28-16-2));
			campos.z -= frames*(MPT_TransformMatrix.m[2][2]>>(28-16-2));
		};

		mdDrawSync();										//Wait for ClearScreen

		/*
			mdRenderObject() is the fastest function to render
		  a batch of polygons...
		*/
		//Render Object
		mdRenderObject(object,texture);

		mdDrawSync();										//Wait for Draw Execution

		// Swap Display Buffer
		frames = SwapDrawBufGRB(dcx);
	}; //while
	return 0;
}

