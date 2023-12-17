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

#ifndef hsMatrix33_DEFINED
#define hsMatrix33_DEFINED

#include "hsRect.h"

class hsInputStream;
class hsOutputStream;

#if HS_BUILD_FOR_MAC
	//	This guy disables MetroWerks' desire to only include a file once, which obviously gets
	//	in the way of our little HS_MATRIX33.inc trick
	#pragma once off
#endif

enum {
	kIdentityMatrixType		= 0,
	kTranslateMatrixType	= 0x01,
	kScaleMatrixType		= 0x02,
	kRotateMatrixType		= 0x04,
	kPerspectiveMatrixType	= 0x08,
	kUnknownMatrixType		= 0x80
};
typedef UInt32 hsMatrixType;

inline hsBool hsMatrixType_RectStaysRect(hsMatrixType matType)
{
	return (matType & ~(kTranslateMatrixType | kScaleMatrixType)) == 0;
}

#if HS_SCALAR_IS_FIXED
	#define HS_MX33_NAME		hsFixedMatrix
	#define HS_MX33_RECT		hsFixedRect
	#define HS_MX33_POINT		hsFixedPoint
	#define HS_MX33_TYPE		hsFixed
	#define HS_MX33_EXTEND	0
	#include "HS_MATRIX33.inc"
#endif

#if HS_SCALAR_IS_FLOAT
	#define HS_MX33_NAME		hsFloatMatrix
	#define HS_MX33_RECT		hsFloatRect
	#define HS_MX33_POINT		hsFloatPoint
	#define HS_MX33_TYPE		float
	#define HS_MX33_EXTEND	0
	#include "HS_MATRIX33.inc"
#endif

#if HS_SCALAR_IS_FIXED
	typedef hsFixedMatrix		hsMatrix;
	#define kMatrixElem22One	hsFract1
#else
	typedef hsFloatMatrix		hsMatrix;
	#define kMatrixElem22One	hsScalar1
#endif

//	For compatibility with the past
//
typedef hsMatrix			hsMatrix33;
#define kMatrix33Elem22One	kMatrixElem22One

/*@
@page hsmatrix33.html

@struct hsMatrix
This class is used to define transformation in 2D with perspective.
NewPoint = Matrix * OriginalPoint
@field hsScalar fMap[3][3] The values in the matrix
@method Reset			Replace the matrix with the identiy matrix
@method SetScale		Replace the matrix with a scaling matrix
@method SetRotate		Replace the matrix with a rotation matrix
@method SetTranslate	Replace the matrix with a translation matrix
@method QuadToQuad	Replace the matrix with a perspective matrix defined by 2 quadrilaterals
@method Scale			Apply scaling to the matrix
@method Rotate		Apply a rotation to the matrix
@method Translate		Apply a translation to the matrix
@method Invert			Compute the inverse of the matrix
@method MapRect		Apply the matrix to a rectangle
@method MapPoints		Apply the matrix to an array of points
@method MapVectors	Apply the matrix to an array of vectors
@endstruct

@methoddef hsMatrix	SetScale
SetScale replaces the matrix with a scale matrix specified by the parameters. The "pivot" parameters
specify a coordinate that is left untouched by the matrix.
@return hsMatrix*	The matrix
@param hsScalar scaleX	The x-scale factor
@param hsScalar scaleY	The y-scale factor
@param hsScalar pivotX	The x-coordinate of the pivot
@param hsScalar pivotY	The y-coordinate of the pivot
@endmethod

@methoddef hsMatrix	SetRotate
SetRotate replaces the matrix with a rotation matrix specified by the parameters. The "pivot" parameters
specify a coordinate that is left untouched by the matrix.
@return hsMatrix*	The matrix
@param hsScalar degrees	The rotation angle, in degrees, for clock-wise rotation
@param hsScalar pivotX	The x-coordinate of the pivot
@param hsScalar pivotY	The y-coordinate of the pivot
@endmethod

@methoddef hsMatrix	SetSkew
SetSkew replaces the matrix with a skew matrix specified by the parameters. The "pivot" parameters
specify a coordinate that is left untouched by the matrix.
@return hsMatrix*	The matrix
@param hsScalar skewX	The amout to skew in X
@param hsScalar skewY	The amout to skew in Y
@param hsScalar pivotX	The x-coordinate of the pivot
@param hsScalar pivotY	The y-coordinate of the pivot
@endmethod

@methoddef hsMatrix	SetTranslate
SetScale replaces the matrix with a translation matrix specified by the parameters.
@return hsMatrix*	The matrix
@param hsScalar transX	The amout to translate in X
@param hsScalar transY	The amout to translate in Y
@endmethod

@methoddef hsMatrix	QuadToQuad
The first array of 4 points specifies the source, and the second array of points specifies the destination.
The matrix is constructed to map the interior of the source quad to the interior of the destination quad.
@return hsMatrix*	The matrix
@param const hsPoint* src	The source array of 4 points
@param const hsPoint* dst	The destination array of 4 points
@endmethod

@methoddef hsMatrix	Scale
Scale modifies an existing matrix by concatenating a scaling matrix on its left. Result = Scale * Original
@return hsMatrix*	The matrix
@param hsScalar scaleX	The x-scale factor
@param hsScalar scaleY	The y-scale factor
@param hsScalar pivotX	The x-coordinate of the pivot
@param hsScalar pivotY	The y-coordinate of the pivot
@endmethod

@methoddef hsMatrix	Rotate
Rotate modifies an existing matrix by concatenating a rotation matrix on its left. Result = Rotate * Original
@return hsMatrix*	The matrix
@param hsScalar degrees	The rotation angle, in degrees, for clock-wise rotation
@param hsScalar pivotX	The x-coordinate of the pivot
@param hsScalar pivotY	The y-coordinate of the pivot
@endmethod

@methoddef hsMatrix	Skew
Skew modifies an existing matrix by concatenating a skew matrix on its left. Result = Skew * Original
@return hsMatrix*	The matrix
@param hsScalar skewX	The amout to skew in X
@param hsScalar skewY	The amout to skew in Y
@param hsScalar pivotX	The x-coordinate of the pivot
@param hsScalar pivotY	The y-coordinate of the pivot
@endmethod

@methoddef hsMatrix	Translate
Translate modifies an existing matrix by concatenating a translation matrix on its left. Result = Translate * Original
@return hsMatrix*	The matrix
@param hsScalar transX	The amout to translate in X
@param hsScalar transY	The amout to translate in Y
@endmethod

@methoddef hsMatrix	const Invert
Invert computes the inverse of itself, and returns the result in the output parameter. If the matrix is non-invertible,
the function returns false.
@return hsBool		TRUE if the matrix is invertible
@param hsmatrix33* inverse	OUTPUT - the inverse of the matrix
@endmethod

@methoddef hsMatrix	const MapRect
MapRect applies the matrix to a rectangle, returning the result in another rectangle. If the matrix contains
rotation or perspective, then the 4 corners of the source rectangle are mapped by the matrix, and the result
rectangle is the bounds of those 4 points.
@return hsRect*			The result rectangle
@param const hsRect* src	The source rectangle
@param hsRect* dst			OUTPUT - the result rectangle
@param hsMatrixType mType	OPTIONAL - the type of matrix
@endmethod

@methoddef hsMatrix	const MapPoints
MapPoints applies the matrix to an array of source points, and returns the results in another array of points.
The source and result arrays may be the same.
@return hsPoint*			The result points
@param UInt32 count		The number of points in the source and destination arrays
@param const hsPoint* src	The array of source points
@param hsPoint* dst		OUTPUT - the array of result points
@param hsMatrixType mType	OPTIONAL - the type of matrix
@endmethod

@methoddef hsMatrix	const MapVectors
MapVectors applies the matrix to an array of source points, and returns the results in another array of points.
The source and result arrays may be the same. MapVectors differs from MapPoints in that any translation in
the matrix is ignored.
@return hsPoint*			The result points
@param UInt32 count		The number of points in the source and destination arrays
@param const hsPoint* src	The array of source points
@param hsPoint* dst		OUTPUT - the array of result points
@param hsMatrixType mType	OPTIONAL - the type of matrix
@endmethod

@endpage
*/
#endif
