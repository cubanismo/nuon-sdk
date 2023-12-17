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

#ifndef hsCubic_DEFINED
#define hsCubic_DEFINED

#include "hsPoint2.h"

class hsCubic {
public:
	static int	DivideAtMax(hsScalar a, hsScalar b, hsScalar c, hsScalar d, hsScalar tValues[]);
	static void	Subdivide(const hsPoint src[4], hsPoint dst[7], hsScalar t);
	static int	DivideXMax(const hsPoint src[4], hsPoint dst[8]);
	static int	DivideYMax(const hsPoint src[4], hsPoint dst[8]);

};

class hsQuad {
public:
	static hsBool DivideAtMax(hsScalar a, hsScalar b, hsScalar c, hsScalar* t);
	static hsBool DivideXMax(const hsPoint src[3], hsPoint dst[3]);
	static hsBool DivideYMax(const hsPoint src[3], hsPoint dst[3]);
	static void	  Subdivide(const hsPoint src[3], hsPoint dst[5], hsScalar t);

	static void	  ToCubic(const hsPoint src[3], hsPoint dst[4]);
};

#endif
