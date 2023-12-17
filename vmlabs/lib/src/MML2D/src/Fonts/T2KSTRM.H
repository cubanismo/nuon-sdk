/*
 * T2KSTRM.H
 * Copyright (C) 1989-1998 all rights reserved by Type Solutions, Inc. Plaistow, NH, USA.
 * Author: Sampo Kaasila
 *
 * This software is the property of Type Solutions, Inc. and it is furnished
 * under a license and may be used and copied only in accordance with the
 * terms of such license and with the inclusion of the above copyright notice.
 * This software or any other copies thereof may not be provided or otherwise
 * made available to any other person or entity except as allowed under license.
 * No title to and ownership of the software or intellectual property
 * therewithin is hereby transferred.
 *
 * This information in this software is subject to change without notice
 */
#ifndef __T2K_STREAM__
#define __T2K_STREAM__

#ifdef ENABLE_NON_RAM_STREAM
typedef void (*PF_READ_TO_RAM) ( void *id, uint8 *dest_ram, long offset, long numBytes );
#endif

#ifdef JUST_AN_EXAMPLE_OF_PF_READ_TO_RAM
void ReadFileDataFunc( void *id, uint8 *dest_ram, long offset, long numBytes )
{
	int error;
	size_t count;
	FILE *fp = (FILE *)id;

	assert( fp != NULL );
	error	= fseek( fp, offset, SEEK_SET ); assert( error == 0 );
	count	= fread( dest_ram, sizeof( char ), numBytes, fp );
	assert( ferror(fp) == 0 && count == (size_t)numBytes );
}
#endif

typedef struct {
	/* private */
	unsigned char *privateBase;
#ifdef ENABLE_NON_RAM_STREAM
	PF_READ_TO_RAM 	ReadToRamFunc;
	void 			*nonRamID;
	uint8			tmp_ch;
#endif
	unsigned long pos;
	unsigned long maxPos; /* one past the last legal position */
	unsigned long posZero;
	char constructorType;
	tsiMemObject *mem;
	
	unsigned long bitBufferIn,  bitCountIn;  /* "left"  aligned. */
	/* public */

} InputStream;


/* ALL external clients (top level call to scaler) need to set errCode pointer,
   ALL INTERNAL clients neet to set the errCode pointer == NULL, so that
   we only do setjmp for the top-most external call
   This applies to the 4 constructors and the one destructor
*/
/* Does free data */
InputStream *New_InputStream( tsiMemObject *mem, unsigned char *data, unsigned long length, int *errCode );
InputStream *New_InputStream2( tsiMemObject *mem, InputStream *in, unsigned long offset, unsigned long length, int *errCode );
/* Does not free data */
InputStream *New_InputStream3( tsiMemObject *mem, unsigned char *data, unsigned long length, int *errCode );

#ifdef ENABLE_NON_RAM_STREAM
InputStream *New_NonRamInputStream( tsiMemObject *mem, void *nonRamID, PF_READ_TO_RAM readFunc, unsigned long length, int *errCode );
#endif

void Delete_InputStream( InputStream *t, int *errCode );

long SizeInStream( InputStream *stream );

int32 ReadInt32( InputStream *stream );
int16 ReadInt16( InputStream *stream );
uint8 ReadUnsignedByte( InputStream *stream );

#define EOF_STREAM -1

#ifdef ENABLE_NON_RAM_STREAM

#define ReadUnsignedByteMacro( stream ) ( (uint8) (stream->privateBase != NULL ? (stream->privateBase[(stream->pos)++]) : ( stream->ReadToRamFunc( stream->nonRamID, &(stream->tmp_ch), (stream->pos)++, 1 ), stream->tmp_ch))  ) 
#define ReadUnsignedByteMacro2( stream ) ( (int)(stream->pos >= stream->maxPos ? EOF_STREAM : (ReadUnsignedByteMacro(stream)) ) ) 

#else /* ENABLE_NON_RAM_STREAM */

#define ReadUnsignedByteMacro( stream ) ( (uint8)(stream->privateBase[(stream->pos)++]) ) 
#define ReadUnsignedByteMacro2( stream ) ( (int)(stream->pos >= stream->maxPos ? EOF_STREAM : stream->privateBase[(stream->pos)++]) ) 

#endif /* ENABLE_NON_RAM_STREAM */

unsigned char *GetEntireStreamIntoMemory( InputStream *stream  );
void Read( InputStream *stream, uint8 *dest, long numBytes );

void Rewind_InputStream( InputStream *t );
void Seek_InputStream( InputStream *t, uint32 offset );
uint32 Tell_InputStream( InputStream *t );


typedef struct {
	/* private */
	unsigned char *base;
	unsigned long maxPos;
	unsigned long pos;
	unsigned long maxLength;
	tsiMemObject *mem;

	unsigned long bitBufferOut, bitCountOut; /* "left"  aligned. */
	/* public */

} OutputStream;

#define GET_POINTER( out ) ( out->base )
OutputStream *New_OutputStream( tsiMemObject *mem, long initialSize );

void WriteBitsToStream( OutputStream *out, unsigned long bits, unsigned long count );
/* When done with all calls to WriteBitsToStream call this to flush remaining
  data to the stream  */
void FlushOutStream( OutputStream *out );

void WriteInt32( OutputStream *stream, int32 value );
void WriteInt16( OutputStream *stream, int16 value );
void WriteUnsignedByte( OutputStream *stream, uint8 value );
void Write( OutputStream *stream, uint8 *src, long numBytes );
long SizeOutStream( OutputStream *stream ); /* max size/position seen */
long OutStreamPos( OutputStream *stream );  /* current size/position */
void Rewind_OutputStream( OutputStream *t );

void Delete_OutputStream( OutputStream *t );

/* uses a variable number of bytes */
void WriteUnsignedNumber( OutputStream *out, unsigned long n );
unsigned long ReadUnsignedNumber( InputStream *in );

#endif /* __T2K_STREAM__ */
