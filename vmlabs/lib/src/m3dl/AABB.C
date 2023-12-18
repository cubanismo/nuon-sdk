/*
 * Title	 			AABB.C
 * Desciption		Merlin AABB Function
 * Version			1.0
 * Start Date		08/24/1999
 * Last Update	08/24/1999
 * By						Phil
 * Of						Miracle Designs
 * History:
 * Known bugs:
*/

#include <m3dl/m3dl.h>


mdINT32 mdCalculateAABB(M3Ddata,aabb)
mdBYTE	*M3Ddata;
mdAABB	*aabb;
{
	//Clear Bounding Box
	aabb->min.x = 0x7FFFFFFF;
	aabb->min.y = 0x7FFFFFFF;
	aabb->min.z = 0x7FFFFFFF;

	aabb->max.x = -0x7FFFFFFF;
	aabb->max.y = -0x7FFFFFFF;
	aabb->max.z = -0x7FFFFFFF;

	return mdUpdateAABB(M3Ddata,aabb);
}; //mdCalcAABB()


mdINT32 mdUpdateAABB(M3Ddata,aabb)
mdBYTE	*M3Ddata;
mdAABB	*aabb;
{
	mdINT32		extraoffset;
	mdINT32		i,j;
	mdUINT32	tag;
	mdUINT32	numpolys, numverts;
	mdUINT32	mprcode;
	mdV3			*vertex;
	mdUINT32	*object = (mdUINT32*)(M3Ddata);

	tag = (*(object));
	if (tag == 0x4D334411) {
		extraoffset = sizeof(mdAABB);
	} else if (tag == 0x4D334410) {
		extraoffset = 0;
	} else {
		//Not a valid M3DL tag
		return 0;
	};

	//Calc Bounding Box if M3D Tag
	object++;								//Skip Tag
	numpolys = (*object);
	object++;								//Skip #polys
	object+=(extraoffset>>2);	//Skip any additional information

	for (i=0; i<numpolys; i++) {
		mprcode = *object++;					//MPR Code & Texture#
		mprcode = (mprcode>>16);			//Extract MPRCode
		vertex = (mdV3*)(object);			//Cast 1st Vertex

		numverts = 0;
		switch (mprcode & 0xE7F) {
			case mpTRI_G:
				numverts = 3;
				object += (3*3)+(1*3);
				break;

			case mpTRI_T:
				numverts = 3;
				object += (3*3)+(1*3);
				break;

			case mpTRI_TG:
				numverts = 3;
				object += (3*3)+(2*3);
				break;

			case mpQUAD_G:
				numverts = 4;
				object += (3*4)+(1*4);
				break;

			case mpQUAD_T:
				numverts = 4;
				object += (3*4)+(1*4);
				break;

			case mpQUAD_TG:
				numverts = 4;
				object += (3*4)+(2*4);
				break;
			default:
				return 0;
				break;
		}; //switch (mprcode)

		//Update Bounding Box
		for (j=0;j<numverts;j++) {
			//Check Minima
			if (vertex->x < aabb->min.x)
				aabb->min.x = vertex->x;
			if (vertex->y < aabb->min.y)
				aabb->min.y = vertex->y;
			if (vertex->z < aabb->min.z)
				aabb->min.z = vertex->z;

			//Check Maxima
			if (vertex->x > aabb->max.x)
				aabb->max.x = vertex->x;
			if (vertex->y > aabb->max.y)
				aabb->max.y = vertex->y;
			if (vertex->z > aabb->max.z)
				aabb->max.z = vertex->z;

			vertex++;									//Next vertex
		}; //for j
	}; //for i
	return 1;
}; //mdUpdateAABB()



