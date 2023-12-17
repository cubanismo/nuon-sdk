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

struct HS_POINT2_NAME {
	HS_POINT2_TYPE	fX, fY;

	void	Set(HS_POINT2_TYPE x, HS_POINT2_TYPE y)
	{
		fX = x;
		fY = y;
	}
	HS_POINT2_NAME& operator+=(const HS_POINT2_NAME& s)
	{
		this->fX += s.fX;
		this->fY += s.fY;
		return *this;
	}
	HS_POINT2_NAME& operator-=(const HS_POINT2_NAME& s)
	{
		this->fX -= s.fX;
		this->fY -= s.fY;
		return *this;
	}

	friend int operator==(const HS_POINT2_NAME& s, const HS_POINT2_NAME& t)
	{
		return (s.fX == t.fX && s.fY == t.fY);
	}
	friend int operator!=(const HS_POINT2_NAME& s, const HS_POINT2_NAME& t)
	{
		return !(s == t);
	}
	friend HS_POINT2_NAME operator+(const HS_POINT2_NAME& s, const HS_POINT2_NAME& t)
	{
		HS_POINT2_NAME	result;
		result.Set(s.fX + t.fX, s.fY + t.fY);
		return result;
	}
	friend HS_POINT2_NAME operator-(const HS_POINT2_NAME& s, const HS_POINT2_NAME& t)
	{
		HS_POINT2_NAME	result;
		result.Set(s.fX - t.fX, s.fY - t.fY);
		return result;
	}
	friend HS_POINT2_NAME operator-(const HS_POINT2_NAME& s)
	{
		HS_POINT2_NAME	result;
		result.Set(-s.fX, -s.fY);
		return result;
	}

#undef HS_POINT2_NAME
#undef HS_POINT2_TYPE
