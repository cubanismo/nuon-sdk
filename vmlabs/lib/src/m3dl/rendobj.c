/*
 * Title	 			RENDOBJ.C
 * Desciption		Merlin 3D Library Render Object Function
 * Version			1.0
 * Start Date		12/14/1998
 * Last Update	03/19/1999
 * By						Phil
 * Of						Miracle Designs
 * History:
 * Known bugs:
*/

#include <m3dl/m3dl.h>
#include <nuon/mutil.h>


//	Still C to allow for future extensions
void mdRenderObject(object, texbase)
mdBYTE		*object;
mdTEXTURE	*texbase;
{
	//Render Object if M3D Tag (0x11 is bounding box included)
	if ((*((mdUINT32*)(object))) == 0x4D334411) {
		_mdRenderObjData((object+((1+1+6)*4)),texbase,*((mdUINT32*)(object+4)),_MemLocalScratch(mdNULL));
	} else {
		if ((*((mdUINT32*)(object))) == 0x4D334410) {
			_mdRenderObjData((object+((1+1)*4)),texbase,*((mdUINT32*)(object+4)),_MemLocalScratch(mdNULL));
		}; //if tag
	}; //else
}; //mdRenderObject()


//	Still C to allow for future extensions
void mdRenderObjectAmbient(object, texbase)
mdBYTE		*object;
mdTEXTURE	*texbase;
{
	//Render Object if M3D Tag (0x11 is bounding box included)
	if ((*((mdUINT32*)(object))) == 0x4D334411) {
		if ((_GetLocalVar(MPT_Ambient)) == 0xFFFFFF00) {
			_mdRenderObjData((object+((1+1+6)*4)),texbase,*((mdUINT32*)(object+4)),_MemLocalScratch(mdNULL));
		} else {
			_mdRenderObjDataAmbient((object+((1+1+6)*4)),texbase,*((mdUINT32*)(object+4)),_MemLocalScratch(mdNULL));
		};
	} else {
		if ((*((mdUINT32*)(object))) == 0x4D334410) {
			if ((_GetLocalVar(MPT_Ambient)) == 0xFFFFFF00) {
				_mdRenderObjData((object+((1+1)*4)),texbase,*((mdUINT32*)(object+4)),_MemLocalScratch(mdNULL));
			} else {
				_mdRenderObjDataAmbient((object+((1+1)*4)),texbase,*((mdUINT32*)(object+4)),_MemLocalScratch(mdNULL));
			};
		}; //if tag
	}; //else
}; //mdRenderObjectAmbient()

