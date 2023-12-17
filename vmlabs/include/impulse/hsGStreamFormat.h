/*
 * Copyright (C) 1999 all rights reserved by AlphaMask, Inc. Cambridge, MA USA
 *
 * This software is the property of AlphaMask, Inc. and it is furnished
 * under a license and may be used and copied only in accordance with the
 * terms of such license and with the inclusion of the above copyright notice.
 * This software or any other copies thereof may not be provided or otherwise
 * made available to any other person or entity except as allowed under license.
 * No title to and ownership of the software or intellectual property
 * therewithin is hereby transferred.
 *
 * ALPHAMASK MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY
 * OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. ALPHAMASK SHALL NOT BE LIABLE FOR
 * ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
 * DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 *
 * This information in this software is subject to change without notice
*/

#ifndef hsGStreamFormat_DEFINED
#define hsGStreamFormat_DEFINED

/*
	This file is intended to be used by both C and C++
*/

enum {
	kStart_hsGStreamOpCode,
	kStop_hsGStreamOpCode,

	kFlags_hsGStreamOpCode,
	kColor_hsGStreamOpCode,

	kFrameSize_hsGStreamOpCode,
	kMiterLimit_hsGStreamOpCode,
	kMinWidth_hsGStreamOpCode,
	kCapType_Butt_hsGStreamOpCode,
	kCapType_Round_hsGStreamOpCode,
	kCapType_Square_hsGStreamOpCode,
	kJoinType_Miter_hsGStreamOpCode,
	kJoinType_Round_hsGStreamOpCode,
	kJoinType_Blunt_hsGStreamOpCode,

	kSetMatrix_hsGStreamOpCode,			/* UInt8 flag + optional data */
	kClipPath_hsGStreamOpCode,

	kFontID_hsGStreamOpCode,
	kFontIndex_hsGStreamOpCode,			/* Int32(index) into FontDict */
	kFontName_hsGStreamOpCode,			/* Byte(length) + char[length] = fullName */
	kTextSize_hsGStreamOpCode,
	kTextEncoding_hsGStreamOpCode,

	kTextFace_hsGStreamOpCode,
	kNoTextFace_hsGStreamOpCode,

	kTextSpacing_hsGStreamOpCode,
	kNoTextSpacing_hsGStreamOpCode,

	kNoShader_hsGStreamOpCode,
	kNameShader_hsGStreamOpCode,
	kIndexShader_hsGStreamOpCode,

	kNoXferMode_hsGStreamOpCode,
	kNameXferMode_hsGStreamOpCode,
	kIndexXferMode_hsGStreamOpCode,

	kNoPathEffect_hsGStreamOpCode,
	kNamePathEffect_hsGStreamOpCode,
	kIndexPathEffect_hsGStreamOpCode,

	kNoRasterizer_hsGStreamOpCode,
	kNameRasterizer_hsGStreamOpCode,
	kIndexRasterizer_hsGStreamOpCode,

	kNoMaskFilter_hsGStreamOpCode,
	kNameMaskFilter_hsGStreamOpCode,
	kIndexMaskFilter_hsGStreamOpCode,

	kSave_hsGStreamOpCode,
	kSaveLayer_hsGStreamOpcode,
	kRestore_hsGStreamOpCode,

	kDrawFull_hsGStreamOpCode,
	kDrawLine_hsGStreamOpCode,
	kDrawRect_hsGStreamOpCode,
	kDrawPath_hsGStreamOpCode,
	kDrawBitmap_hsGStreamOpCode,
	kDrawText_hsGStreamOpCode,
	kDrawPosText_hsGStreamOpCode,
	
	kCOUNT_hsGStreamOpcode		/* just used to count the number of opcodes */
};

#endif
