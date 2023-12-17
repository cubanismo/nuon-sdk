/*
 * 
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 */
 
#include <nuon/gl.h>

extern GLTexture *tracks;
extern short tracksjpg_start[], tracksjpg_size[];
extern GLTexture *plank2;
extern short plank2jpg_start[], plank2jpg_size[];
extern GLTexture *wallpaperl;
extern short wallpaperljpg_start[], wallpaperljpg_size[];
extern GLTexture *wood32x32d;
extern short wood32x32djpg_start[], wood32x32djpg_size[];
extern GLTexture *plank1;
extern short plank1jpg_start[], plank1jpg_size[];
extern GLTexture *grncloth;
extern short grnclothjpg_start[], grnclothjpg_size[];
extern GLTexture *goldrod;
extern short goldrodjpg_start[], goldrodjpg_size[];
extern GLTexture *leather;
extern short leatherjpg_start[], leatherjpg_size[];
extern GLTexture *plank4;
extern short plank4jpg_start[], plank4jpg_size[];
extern GLTexture *tiles;
extern short tilesjpg_start[], tilesjpg_size[];
extern GLTexture *border1;
extern short border1jpg_start[], border1jpg_size[];
extern GLTexture *plank3;
extern short plank3jpg_start[], plank3jpg_size[];
extern GLTexture *pages;
extern short pagesjpg_start[], pagesjpg_size[];
extern GLTexture *bleather;
extern short bleatherjpg_start[], bleatherjpg_size[];
extern GLTexture *fanvents;
extern short fanventsjpg_start[], fanventsjpg_size[];
extern GLTexture *fangrid;
extern short fangridjpg_start[], fangridjpg_size[];
extern GLTexture *fanbody;
extern short fanbodyjpg_start[], fanbodyjpg_size[];
extern GLTexture *golden;
extern short goldenjpg_start[], goldenjpg_size[];
extern GLTexture *silvered;
extern short silveredjpg_start[], silveredjpg_size[];
extern GLTexture *moon;
extern short moonjpg_start[], moonjpg_size[];
extern GLTexture *trashsides;
extern short trashsidesjpg_start[], trashsidesjpg_size[];
extern GLTexture *trashbot;
extern short trashbotjpg_start[], trashbotjpg_size[];
extern GLTexture *lamptexture;
extern short lamptexturejpg_start[], lamptexturejpg_size[];
extern GLTexture *lampshade;
extern short lampshadejpg_start[], lampshadejpg_size[];
extern GLTexture *outlet;
extern short outletjpg_start[], outletjpg_size[];
extern GLTexture *switchplate;
extern short switchplatejpg_start[], switchplatejpg_size[];
extern GLTexture *wallpaperu;
extern short wallpaperujpg_start[], wallpaperujpg_size[];
extern GLTexture *yleather;
extern short yleatherjpg_start[], yleatherjpg_size[];
extern GLTexture *parquet;
extern short parquetjpg_start[], parquetjpg_size[];
extern GLTexture *throwrug;
extern short throwrugjpg_start[], throwrugjpg_size[];
extern GLTexture *claypot;
extern short claypotjpg_start[], claypotjpg_size[];
extern GLTexture *dirt;
extern short dirtjpg_start[], dirtjpg_size[];
extern GLTexture *leaves;
extern short leavesjpg_start[], leavesjpg_size[];

extern long WINDOWTRACK_vertices[], WINDOWTRACK_size[], WINDOWTRACK_count[];
extern long Material_1_vertices[], Material_1_size[], Material_1_count[];
extern long Material_2_vertices[], Material_2_size[], Material_2_count[];
extern long TABLEWOOD_vertices[], TABLEWOOD_size[], TABLEWOOD_count[];
extern long Material_6_vertices[], Material_6_size[], Material_6_count[];
extern long SOFASMOOTH_vertices[], SOFASMOOTH_size[], SOFASMOOTH_count[];
extern long HINGES_vertices[], HINGES_size[], HINGES_count[];
extern long DRAFTMETAL_vertices[], DRAFTMETAL_size[], DRAFTMETAL_count[];
extern long CHAIRUPHOLSTERY_vertices[], CHAIRUPHOLSTERY_size[], CHAIRUPHOLSTERY_count[];
extern long CHAIRSMOOTH_vertices[], CHAIRSMOOTH_size[], CHAIRSMOOTH_count[];
extern long CHAIRFLAT_vertices[], CHAIRFLAT_size[], CHAIRFLAT_count[];
extern long Material_5_vertices[], Material_5_size[], Material_5_count[];
extern long Material_3_vertices[], Material_3_size[], Material_3_count[];
extern long woody_stuff_vertices[], woody_stuff_size[], woody_stuff_count[];
extern long Saved6_vertices[], Saved6_size[], Saved6_count[];
extern long Saved3_vertices[], Saved3_size[], Saved3_count[];
extern long Saved_vertices[], Saved_size[], Saved_count[];
extern long Saved2_vertices[], Saved2_size[], Saved2_count[];
extern long Saved7_vertices[], Saved7_size[], Saved7_count[];
extern long Saved_4_vertices[], Saved_4_size[], Saved_4_count[];
extern long pages_vertices[], pages_size[], pages_count[];
extern long Top_Book_Cover_vertices[], Top_Book_Cover_size_count[], Top_Book_Cover_count[];
extern long fanvents_vertices[], fanvents_size[], fanvents_count[];
extern long Material_4_vertices[], Material_4_size[], Material_4_count[];
extern long Fanbody_vertices[], Fanbody_size[], Fanbody_count[];
extern long Material_4_1_vertices[], Material_4_1_size[], Material_4_1_count[];
extern long Clock_back_vertices[], Clock_back_size[], Clock_back_count[];
extern long clockyface_vertices[], clockyface_size[], clockyface_count[];
extern long MoonImage_vertices[], MoonImage_size[], MoonImage_count[];
extern long KNOB_vertices[], KNOB_size[], KNOB_count[];
extern long TRASHSIDES_vertices[], TRASHSIDES_size[], TRASHSIDES_count[];
extern long TRASHENDS_vertices[], TRASHENDS_size[], TRASHENDS_count[];
extern long Lamp_Switch_Area_vertices[], Lamp_Switch_Area_size[], Lamp_Switch_Area_count[];
extern long Lamp_Neck_vertices[], Lamp_Neck_size[], Lamp_Neck_count[];
extern long Light_Bulb_Material_vertices[], Light_Bulb_Material_size[], Light_Bulb_Material_count[];
extern long Lamp_base_Sides_vertices[], Lamp_base_Sides_size[], Lamp_base_Sides_count[];
extern long Lampshade_Material_vertices[], Lampshade_Material_size[], Lampshade_Material_count[];
extern long Lamp_base_gold_vertices[], Lamp_base_gold_size[], Lamp_base_gold_count[];
extern long OUTLET_vertices[], OUTLET_size[], OUTLET_count[];
extern long SWITCHPLATE_vertices[], SWITCHPLATE_size[], SWITCHPLATE_count[];
extern long Upper_Wallpaper_vertices[], Upper_Wallpaper_size[], Upper_Wallpaper_count[];
extern long Bottom_Book_Cover_vertices[], Bottom_Book_Cover_size[], Bottom_Book_Cover_count[];
extern long Parquet_vertices[], Parquet_size[], Parquet_count[];
extern long Throwrug_vertices[], Throwrug_size[], Throwrug_count[];
extern long Pot_vertices[], Pot_size[], Pot_count[];
extern long Dirt_vertices[], Dirt_size[], Dirt_count[];
extern long Leaves_vertices[], Leaves_size[], Leaves_count[];

void InitNewroom29()
{
	tracks = mglInitJPEGTexture((JOCTET *)tracksjpg_start, (long)tracksjpg_size, e655, 1, 0);
	plank2 = mglInitJPEGTexture((JOCTET *)plank2jpg_start, (long)plank2jpg_size, e655, 1, 0);
	wallpaperl = mglInitJPEGTexture((JOCTET *)wallpaperljpg_start, (long)wallpaperljpg_size, e655, 1, 0);
	wood32x32d = mglInitJPEGTexture((JOCTET *)wood32x32djpg_start, (long)wood32x32djpg_size, e655, 1, 0);
	plank1 = mglInitJPEGTexture((JOCTET *)plank1jpg_start, (long)plank1jpg_size, e655, 1, 0);
	grncloth = mglInitJPEGTexture((JOCTET *)grnclothjpg_start, (long)grnclothjpg_size, e655, 1, 0);
	goldrod = mglInitJPEGTexture((JOCTET *)goldrodjpg_start, (long)goldrodjpg_size, e655, 1, 0);
	leather = mglInitJPEGTexture((JOCTET *)leatherjpg_start, (long)leatherjpg_size, e655, 1, 0);
	plank4 = mglInitJPEGTexture((JOCTET *)plank4jpg_start, (long)plank4jpg_size, e655, 1, 0);
	tiles = mglInitJPEGTexture((JOCTET *)tilesjpg_start, (long)tilesjpg_size, e655, 1, 0);
	border1 = mglInitJPEGTexture((JOCTET *)border1jpg_start, (long)border1jpg_size, e655, 1, 0);
	plank3 = mglInitJPEGTexture((JOCTET *)plank3jpg_start, (long)plank3jpg_size, e655, 1, 0);
	pages = mglInitJPEGTexture((JOCTET *)pagesjpg_start, (long)pagesjpg_size, e655, 1, 0);
	bleather = mglInitJPEGTexture((JOCTET *)bleatherjpg_start, (long)bleatherjpg_size, e655, 1, 0);
	fanvents = mglInitJPEGTexture((JOCTET *)fanventsjpg_start, (long)fanventsjpg_size, e655, 1, 0);
	fangrid = mglInitJPEGTexture((JOCTET *)fangridjpg_start, (long)fangridjpg_size, e655, 1, 0);
	fanbody = mglInitJPEGTexture((JOCTET *)fanbodyjpg_start, (long)fanbodyjpg_size, e655, 1, 0);
	golden = mglInitJPEGTexture((JOCTET *)goldenjpg_start, (long)goldenjpg_size, e655, 1, 0);
	silvered = mglInitJPEGTexture((JOCTET *)silveredjpg_start, (long)silveredjpg_size, e655, 1, 0);
	moon = mglInitJPEGTexture((JOCTET *)moonjpg_start, (long)moonjpg_size, e655, 1, 0);
	trashsides = mglInitJPEGTexture((JOCTET *)trashsidesjpg_start, (long)trashsidesjpg_size, e655, 1, 0);
	trashbot = mglInitJPEGTexture((JOCTET *)trashbotjpg_start, (long)trashbotjpg_size, e655, 1, 0);
	lamptexture = mglInitJPEGTexture((JOCTET *)lamptexturejpg_start, (long)lamptexturejpg_size, e655, 1, 0);
	lampshade = mglInitJPEGTexture((JOCTET *)lampshadejpg_start, (long)lampshadejpg_size, e655, 1, 0);
	outlet = mglInitJPEGTexture((JOCTET *)outletjpg_start, (long)outletjpg_size, e655, 1, 0);
	switchplate = mglInitJPEGTexture((JOCTET *)switchplatejpg_start, (long)switchplatejpg_size, e655, 1, 0);
	wallpaperu = mglInitJPEGTexture((JOCTET *)wallpaperujpg_start, (long)wallpaperujpg_size, e655, 1, 0);
	yleather = mglInitJPEGTexture((JOCTET *)yleatherjpg_start, (long)yleatherjpg_size, e655, 1, 0);
	parquet = mglInitJPEGTexture((JOCTET *)parquetjpg_start, (long)parquetjpg_size, e655, 1, 0);
	throwrug = mglInitJPEGTexture((JOCTET *)throwrugjpg_start, (long)throwrugjpg_size, e655, 1, 0);
	claypot = mglInitJPEGTexture((JOCTET *)claypotjpg_start, (long)claypotjpg_size, e655, 1, 0);
	dirt = mglInitJPEGTexture((JOCTET *)dirtjpg_start, (long)dirtjpg_size, e655, 1, 0);
	leaves = mglInitJPEGTexture((JOCTET *)leavesjpg_start, (long)leavesjpg_size, e655, 1, 0);
}

void DrawNewroom29()
{
	static const GLint white[] = { 0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff };
	static const GLint black[] = { 0, 0, 0, 0x7fffffff };
	static const GLint DRAFTMETAL_ambient_and_diffuse[] = { 0x3c3c3c40, 0x3c3c3c40, 0x3c3c3c40, 0x7fffffff };

	glMaterialiv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, (const GLint *)white);
	glMaterialiv(GL_FRONT, GL_SPECULAR, (const GLint *)black);

	glEnable(GL_TEXTURE_2D);

	mglSetTexture(tracks);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, WINDOWTRACK_vertices, (long)WINDOWTRACK_count, 1);

	mglSetTexture(plank2);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Material_1_vertices, (long)Material_1_count, 1);

	mglSetTexture(wallpaperl);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Material_2_vertices, (long)Material_2_count, 1);

	mglSetTexture(wood32x32d);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, TABLEWOOD_vertices, (long)TABLEWOOD_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, woody_stuff_vertices, (long)woody_stuff_count, 1);

	mglSetTexture(plank1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Material_6_vertices, (long)Material_6_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Saved3_vertices, (long)Saved3_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Saved2_vertices, (long)Saved2_count, 1);

	mglSetTexture(grncloth);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, SOFASMOOTH_vertices, (long)SOFASMOOTH_count, 1);

	mglSetTexture(goldrod);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, HINGES_vertices, (long)HINGES_count, 1);

	mglSetTexture(leather);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, CHAIRUPHOLSTERY_vertices, (long)CHAIRUPHOLSTERY_count, 1);

	mglSetTexture(plank4);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, CHAIRSMOOTH_vertices, (long)CHAIRSMOOTH_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, CHAIRFLAT_vertices, (long)CHAIRFLAT_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Clock_back_vertices, (long)Clock_back_count, 1);

	mglSetTexture(tiles);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Material_5_vertices, (long)Material_5_count, 1);

	mglSetTexture(border1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Material_3_vertices, (long)Material_3_count, 1);

	mglSetTexture(plank3);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Saved6_vertices, (long)Saved6_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Saved_vertices, (long)Saved_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Saved7_vertices, (long)Saved7_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Saved_4_vertices, (long)Saved_4_count, 1);

	mglSetTexture(pages);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, pages_vertices, (long)pages_count, 1);

	mglSetTexture(bleather);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Top_Book_Cover_vertices, (long)Top_Book_Cover_count, 1);

	mglSetTexture(fanvents);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, fanvents_vertices, (long)fanvents_count, 1);

	mglSetTexture(fangrid);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Material_4_vertices, (long)Material_4_count, 1);

	mglSetTexture(fanbody);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Fanbody_vertices, (long)Fanbody_count, 1);

	mglSetTexture(golden);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Material_4_1_vertices, (long)Material_4_1_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, KNOB_vertices, (long)KNOB_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Lamp_Neck_vertices, (long)Lamp_Neck_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Lamp_base_gold_vertices, (long)Lamp_base_gold_count, 1);

	mglSetTexture(silvered);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, clockyface_vertices, (long)clockyface_count, 1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Lamp_Switch_Area_vertices, (long)Lamp_Switch_Area_count, 1);

	mglSetTexture(moon);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, MoonImage_vertices, (long)MoonImage_count, 1);

	mglSetTexture(trashsides);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, TRASHSIDES_vertices, (long)TRASHSIDES_count, 1);

	mglSetTexture(trashbot);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, TRASHENDS_vertices, (long)TRASHENDS_count, 1);

	mglSetTexture(lamptexture);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Lamp_base_Sides_vertices, (long)Lamp_base_Sides_count, 1);

	mglSetTexture(lampshade);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Lampshade_Material_vertices, (long)Lampshade_Material_count, 1);

	mglSetTexture(outlet);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, OUTLET_vertices, (long)OUTLET_count, 1);

	mglSetTexture(switchplate);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, SWITCHPLATE_vertices, (long)SWITCHPLATE_count, 1);

	mglSetTexture(wallpaperu);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Upper_Wallpaper_vertices, (long)Upper_Wallpaper_count, 1);

	mglSetTexture(yleather);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Bottom_Book_Cover_vertices, (long)Bottom_Book_Cover_count, 1);

	mglSetTexture(parquet);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Parquet_vertices, (long)Parquet_count, 1);

	mglSetTexture(throwrug);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Throwrug_vertices, (long)Throwrug_count, 1);

	mglSetTexture(claypot);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Pot_vertices, (long)Pot_count, 1);

	mglSetTexture(dirt);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Dirt_vertices, (long)Dirt_count, 1);

	mglSetTexture(leaves);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, Leaves_vertices, (long)Leaves_count, 1);

	glDisable(GL_TEXTURE_2D);

	glMaterialiv(GL_FRONT, GL_SPECULAR, (const GLint *)white);

	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZN, Light_Bulb_Material_vertices, (long)Light_Bulb_Material_count, 1);

	glMaterialiv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, (const GLint *)DRAFTMETAL_ambient_and_diffuse);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZN, DRAFTMETAL_vertices, (long)DRAFTMETAL_count, 1);
}
