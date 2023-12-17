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

#ifndef hsXMLWriter_DEFINED
#define hsXMLWriter_DEFINED

#include "hsScalar.h"
#include "hsPrintf.h"

class hsXMLWriter {
	hsPrintf*		fPF;
	int				fNestingLevel;
	hsBool			fDoFormat;		// indent to nesting level
	hsBool			fHasChildren;

	void			Tab();
public:
					hsXMLWriter(hsPrintf* pf, hsBool doFormat = false);
	virtual			~hsXMLWriter();
	
	hsPrintf*		GetPrintf() const { return fPF; }

	virtual	void	StartElement(const char tag[]);
	virtual	void	EndElement(const char tag[] = nil);
	virtual void	RawElement(UInt32 length, const void* data);

	virtual	void	AddAttribute(const char name[], const char value[]);
	virtual	void	AddAttribute32(const char name[], long value);
	virtual	void	AddAttributeU32(const char name[], unsigned long value);
	virtual	void	AddScalarAttribute(const char name[], hsScalar value);
	
	void			AddAttribute(const char name[], int value)
		{AddAttribute(name, (long) value);}
//	void			AddAttribute(const char name[], Int16 value)
//		{AddAttribute(name, (long) value);}
//	void			AddAttribute(const char name[], UInt8 value)
//		{AddAttribute(name, (unsigned long) value);}
//	void			AddAttribute(const char name[], UInt16 value)
//		{AddAttribute(name, (unsigned long) value);}

	virtual void	AddAttribute(const char name[], int count,
								 const hsScalar values[]);

	virtual void	WriteProcessingInstruction(const char value[]);
	virtual void	WriteDocumentType(const char docElemTag[], const char name[], const char url[]);
};


#endif
