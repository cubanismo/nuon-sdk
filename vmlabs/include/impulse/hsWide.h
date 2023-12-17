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

#ifndef hsWideDefined
#define hsWideDefined

#include "hsTypes.h"

struct hsWide {
	Int32	fHi;
	UInt32	fLo;

	hsWide*	Set(Int32 lo) { fLo = lo; if (lo < 0) fHi = -1L; else fHi = 0; return this; }
	hsWide*	Set(Int32 hi, UInt32 lo) { fHi = hi; fLo = lo; return this; }

	inline int	IsNeg() const { return fHi < 0; }
	inline int	IsPos() const { return fHi > 0 || (fHi == 0 && fLo != 0); }
	inline int	IsZero() const { return fHi == 0 && fLo == 0; }
	inline int	IsWide() const;

	friend inline int	operator==(const hsWide& a, const hsWide& b) { return a.fHi == b.fHi && a.fLo == b.fLo; }
	friend inline int	operator<(const hsWide& a, const hsWide& b) { return a.fHi < b.fHi || a.fHi == b.fHi && a.fLo < b.fLo; }
	friend inline int	operator>(const hsWide& a, const hsWide& b) { return a.fHi > b.fHi || a.fHi == b.fHi && a.fLo > b.fLo; }
	friend inline int	operator!=(const hsWide& a, const hsWide& b) { return !(a == b); }
	friend inline int	operator<=(const hsWide& a, const hsWide& b) { return !(a > b); }
	friend inline int	operator>=(const hsWide& a, const hsWide& b) { return !(a < b); }

	inline hsWide*	Negate();
	inline hsWide*	Add(Int32 scaler);
	inline hsWide*	Add(const hsWide* a);
	inline hsWide*	Sub(const hsWide* a);
	inline hsWide*	ShiftLeft(unsigned shift);
	inline hsWide*	ShiftRight(unsigned shift);
	inline hsWide*	RoundRight(unsigned shift);

	inline Int32	AsLong() const;				// return bits 31-0, checking for over/under flow
	inline hsFixed	AsFixed() const;			// return bits 47-16, checking for over/under flow
	inline hsFract	AsFract() const;			// return bits 61-30, checking for over/under flow

	hsWide*	Mul(Int32 a);					// this updates the wide
	hsWide*	Mul(Int32 a, Int32 b);			// this sets the wide
	hsWide*	Div(Int32 denom);				// this updates the wide
	hsWide*	Div(const hsWide* denom);		// this updates the wide

	hsFixed	FixDiv(const hsWide* denom) const;
	hsFract	FracDiv(const hsWide* denom) const;

	Int32	Sqrt() const;
	Int32	CubeRoot() const;

#if HS_CAN_USE_FLOAT
	double	AsDouble() const { return fHi * double(65536) * double(65536) + fLo; }
#endif

};

const hsWide kPosInfinity64 = { kPosInfinity32, 0xffffffff };
const hsWide kNegInfinity64 = { kNegInfinity32, 0 };

//
// Inline implementations
//
#if HS_PIN_MATH_OVERFLOW && HS_DEBUG_MATH_OVERFLOW
	#define hsSignalMathOverflow()	hsDebugMessage("Math overflow", 0)
	#define hsSignalMathUnderflow()	hsDebugMessage("Math underflow", 0)
#else
	#define hsSignalMathOverflow()
	#define hsSignalMathUnderflow()
#endif

#define WIDE_ISNEG(hi, lo)						(Int32(hi) < 0)
#define WIDE_LESSTHAN(hi, lo, hi2, lo2)				((hi) < (hi2) || (hi) == (hi2) && (lo) < (lo2))
#define WIDE_SHIFTLEFT(outH, outL, inH, inL, shift)		do { (outH) = ((inH) << (shift)) | ((inL) >> (32 - (shift))); (outL) = (inL) << (shift); } while (0)
#define WIDE_NEGATE(hi, lo)						do { (hi) = ~(hi); if (((lo) = -Int32(lo)) == 0) (hi) += 1; } while (0) 
#define WIDE_ADDPOS(hi, lo, scaler)				do { UInt32 tmp = (lo) + (scaler); if (tmp < (lo)) (hi) += 1; (lo) = tmp; } while (0)
#define WIDE_SUBWIDE(hi, lo, subhi, sublo)			do { (hi) -= (subhi); if ((lo) < (sublo)) (hi) -= 1; (lo) -= (sublo); } while (0) 

//
// Inline implementations
//
#define	TOP2BITS(n)	(UInt32(n) >> 30)
#define	TOP3BITS(n)	(UInt32(n) >> 29)

inline hsWide* hsWide::Negate()
{
	WIDE_NEGATE(fHi, fLo);
	
	return this;
}

inline hsWide* hsWide::Add(Int32 scaler)
{
	if (scaler >= 0)
		WIDE_ADDPOS(fHi, fLo, scaler);
	else
	{	scaler = -scaler;
		if (fLo < UInt32(scaler))
			fHi--;
		fLo -= scaler;
	}

	return this;
}

inline hsWide* hsWide::Add(const hsWide* a)
{
	UInt32	newLo = fLo + a->fLo;

	fHi += a->fHi;
	if (newLo < (fLo | a->fLo))
		fHi++;
	fLo = newLo;

	return this;
}

inline hsWide* hsWide::Sub(const hsWide* a)
{
	WIDE_SUBWIDE(fHi, fLo, a->fHi, a->fLo);

	return this;
}

inline hsWide* hsWide::ShiftLeft(unsigned shift)
{
	WIDE_SHIFTLEFT(fHi, fLo, fHi, fLo, shift);

	return this;
}

inline hsWide* hsWide::ShiftRight(unsigned shift)
{
	fLo = (fLo >> shift) | (fHi << (32 - shift));
	fHi = fHi >> shift;		// fHi >>= shift;   Treated as logical shift on CW9-WIN32, which breaks for fHi < 0

	return this;
}

inline hsWide* hsWide::RoundRight(unsigned shift)
{
	return this->Add(1L << (shift - 1))->ShiftRight(shift);
}

inline Int32 hsWide::AsLong() const
{
#if HS_PIN_MATH_OVERFLOW
	if (fHi > 0 || fHi == 0 && (Int32)fLo < 0)
	{	hsSignalMathOverflow();
		return kPosInfinity32;
	}
	if (fHi < -1L || fHi == -1L && (Int32)fLo >= 0)
	{	hsSignalMathOverflow();
		return kNegInfinity32;
	}
#endif
	return (Int32)fLo;
}

inline int hsWide::IsWide() const
{
	return (fHi > 0 || fHi == 0 && (Int32)fLo < 0) || (fHi < -1L || fHi == -1L && (Int32)fLo >= 0);
}

inline hsFixed hsWide::AsFixed() const
{
	hsWide tmp = *this;

	return tmp.RoundRight(16)->AsLong();
}

inline hsFract hsWide::AsFract() const
{
	hsWide tmp = *this;

	return tmp.RoundRight(30)->AsLong();
}

#endif
