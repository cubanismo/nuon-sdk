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

#ifndef hsFiles_DEFINED
#define hsFiles_DEFINED

#include "hsStream.h"

#if !(HS_BUILD_FOR_PALM)

#include <stdio.h>

#if HS_BUILD_FOR_NUON		/* VML_JS */
	#include <limits.h>
	#define kFolderIterator_MaxPath		FILENAME_MAX
#elif HS_BUILD_FOR_UNIX
	#include <limits.h>
	#ifdef PATH_MAX
		#define kFolderIterator_MaxPath		PATH_MAX
	#else
		#define kFolderIterator_MaxPath		_MAX_PATH
	#endif
#else
	#define kFolderIterator_MaxPath		_MAX_PATH
#endif

#if HS_BUILD_FOR_MAC
	#include <Files.h>
	#include <Script.h>
#endif



class hsFile {
protected:
	char*		fPathAndName;
	FILE*		fFILE;
public:
				hsFile();
				hsFile(const char pathAndName[]);
	virtual		~hsFile();

	hsFile&		operator=(const hsFile& src);

	const char*	GetName();
	virtual const char*	GetPathAndName();
	virtual void	SetPathAndName(const char pathAndName[]);

	virtual FILE*	OpenFILE(const char mode[], hsBool throwIfFailure = false);
	virtual hsIOStream* OpenStream(const char mode[], hsBool throwIfFailure = false);

	virtual void	Close();	// called automatically in the destructor
};
typedef hsFile	hsUnixFile;	// for compatibility

#if HS_BUILD_FOR_MAC
	class hsMacFile : public hsFile {
		enum {
			kRefNum_Valid,
			kResFile_Valid,
			kPathName_Dirty
		};
		FSSpec		fSpec;
		Int16		fRefNum;	// data fork
		Int16		fResFile;	// resource file
		UInt32		fFlags;

		void 			SetSpecFromName();
		void 			SetNameFromSpec();
	public:
					hsMacFile();
					hsMacFile(const FSSpec* spec);
					hsMacFile(const char pathAndName[]);
		virtual		~hsMacFile();

		hsMacFile&	operator=(const hsMacFile& src);

		const FSSpec*	GetSpec() const { return &fSpec; }
		void			SetSpec(const FSSpec* spec);
		hsBool		Create(OSType creator, OSType fileType, ScriptCode scriptCode = smSystemScript);
		hsBool		OpenDataFork(Int16* refnum) { return this->OpenDataFork(fsCurPerm, refnum); }
		hsBool		OpenDataFork(SInt8 permission, Int16* refnum);
		hsBool		OpenResFile(Int16* refnum) { return this->OpenResFile(fsCurPerm, refnum); }
		hsBool		OpenResFile(SInt8 permission, Int16* refnum);

		//	Overrides
		virtual const char*	GetPathAndName();
		virtual void	SetPathAndName(const char pathAndName[]);
		virtual hsIOStream* OpenStream(const char mode[], hsBool throwIfFailure = false);
		virtual void	Close();
	};
	typedef hsMacFile	hsOSFile;
#else
	typedef hsFile		hsOSFile;
#endif



class hsFolderIterator {
	char		fPath[kFolderIterator_MaxPath];
	struct hsFolderIterator_Data* fData;
public:
				hsFolderIterator(const char path[] = nil);
				hsFolderIterator(const struct FSSpec* spec);	// Alt constructor
				
	virtual		~hsFolderIterator();

	const char*	GetPath() const { return fPath; }
	void			SetPath(const char path[]);

	void			Reset();
	hsBool		NextFile();
	hsBool		NextFileSuffix(const char suffix[]);
	const char*	GetFileName();
	int			GetPathAndName(char pathandname[] = nil);

	FILE*		OpenFILE(const char mode[]);

#if HS_BUILD_FOR_MAC
	void			SetMacFolder(OSType folderType);
	void			SetMacFolder(Int16 vRefNum, Int32 dirID);
	hsBool		NextMacFile(OSType targetFileType, OSType targetCreator);
	const struct FSSpec* GetMacSpec() const;
	OSType		GetMacFileType() const;
	OSType		GetMacCreator() const;
#elif (HS_BUILD_FOR_WIN32 || HS_BUILD_FOR_NUON)
	void		SetWinSystemDir(const char subdir[]);	// e.g. "Fonts"
#endif
};

#endif

#endif
