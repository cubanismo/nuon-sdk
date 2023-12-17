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


struct HS_MX33_NAME {
	enum {
		kIdentityStream,
		kTranslateStream,
		kScaleStream,
		kLinearStream,
		kFullStream
	};
	HS_MX33_TYPE	fMap[3][3];

	HS_MX33_TYPE	TranslateX() const { return fMap[0][2]; }
	HS_MX33_TYPE	TranslateY() const { return fMap[1][2]; }

	hsMatrixType		GetType() const;
	hsBool			RectStaysRect() const { return hsMatrixType_RectStaysRect(this->GetType()); }

	HS_MX33_NAME*	Reset();

	HS_MX33_NAME*	SetScale(HS_MX33_TYPE sx, HS_MX33_TYPE sy, HS_MX33_TYPE px, HS_MX33_TYPE py);
	HS_MX33_NAME*	SetRotate(HS_MX33_TYPE degrees, HS_MX33_TYPE px, HS_MX33_TYPE py);
	HS_MX33_NAME*	SetRotate(HS_MX33_TYPE cosValue, HS_MX33_TYPE sinValue, HS_MX33_TYPE px, HS_MX33_TYPE py);
	HS_MX33_NAME*	SetSkew(HS_MX33_TYPE sx, HS_MX33_TYPE sy, HS_MX33_TYPE px, HS_MX33_TYPE py);
	HS_MX33_NAME*	SetTranslate(HS_MX33_TYPE x, HS_MX33_TYPE y);
	HS_MX33_NAME*	SetConcat(const HS_MX33_NAME* a, const HS_MX33_NAME* b);
	hsBool			SetPolyToPoly(int count, const HS_MX33_POINT src[], const HS_MX33_POINT dst[]);

	HS_MX33_NAME*	Scale(HS_MX33_TYPE sx, HS_MX33_TYPE sy, HS_MX33_TYPE px, HS_MX33_TYPE py);
	HS_MX33_NAME*	Rotate(HS_MX33_TYPE degrees, HS_MX33_TYPE px, HS_MX33_TYPE py);
	HS_MX33_NAME*	Rotate(HS_MX33_TYPE cosValue, HS_MX33_TYPE sinValue, HS_MX33_TYPE px, HS_MX33_TYPE py);
	HS_MX33_NAME*	Skew(HS_MX33_TYPE sx, HS_MX33_TYPE sy, HS_MX33_TYPE px, HS_MX33_TYPE py);
	HS_MX33_NAME*	Translate(HS_MX33_TYPE dx, HS_MX33_TYPE dy);

	hsBool			Invert(HS_MX33_NAME* inverse) const;

	HS_MX33_RECT*	MapRect(const HS_MX33_RECT* src, HS_MX33_RECT* dst, hsMatrixType matType = kUnknownMatrixType) const;
	HS_MX33_RECT*	MapRect(HS_MX33_RECT* rect, hsMatrixType matType = kUnknownMatrixType) const
					{
						return this->MapRect(rect, rect, matType);
					}
	HS_MX33_POINT*	MapPoints(UInt32 count, const HS_MX33_POINT src[], HS_MX33_POINT dst[], hsMatrixType matType = kUnknownMatrixType) const;
	HS_MX33_POINT*	MapPoints(UInt32 count, HS_MX33_POINT points[], hsMatrixType matType = kUnknownMatrixType) const
					{
						return this->MapPoints(count, points, points, matType);
					}
	HS_MX33_POINT*	MapVectors(UInt32 count, const HS_MX33_POINT src[], HS_MX33_POINT dst[], hsMatrixType matType = kUnknownMatrixType) const;
	HS_MX33_POINT*	MapVectors(UInt32 count, HS_MX33_POINT vectors[], hsMatrixType matType = kUnknownMatrixType) const
					{
						return this->MapVectors(count, vectors, vectors, matType);
					}

	friend int			operator==(const HS_MX33_NAME& a, const HS_MX33_NAME& b)
					{
						return	a.fMap[0][0] == b.fMap[0][0] && a.fMap[0][1] == b.fMap[0][1] && a.fMap[0][2] == b.fMap[0][2] &&
								a.fMap[1][0] == b.fMap[1][0] && a.fMap[1][1] == b.fMap[1][1] && a.fMap[1][2] == b.fMap[1][2] &&
								a.fMap[2][0] == b.fMap[2][0] && a.fMap[2][1] == b.fMap[2][1] && a.fMap[2][2] == b.fMap[2][2];
					}
	friend int			operator!=(const HS_MX33_NAME& a, const HS_MX33_NAME& b)
					{
						return !(a == b);
					}
	friend HS_MX33_NAME operator*(const HS_MX33_NAME& a, const HS_MX33_NAME& b);

	void			Read(hsInputStream* stream);
	void			Write(hsOutputStream* stream) const;
	UInt32			GetStreamSize() const;

#if !(HS_MX33_EXTEND)
};
#endif

#undef HS_MX33_NAME
#undef HS_MX33_RECT
#undef HS_MX33_POINT
#undef HS_MX33_TYPE
#undef HS_MX33_EXTEND

