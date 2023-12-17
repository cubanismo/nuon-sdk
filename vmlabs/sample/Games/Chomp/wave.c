/*
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdio.h>
#include <nuon/bios.h>
#include <nuon/nise.h>

extern short Sample1[];
extern short Sample2[];
extern short Sample3[];
extern short Sample4[];

typedef struct
{
	short			compression;
	short			channels;
	long			samplerate;
	long			bytes_per_second;
	short			block_alignment;
	short   		bits_per_sample;

} __attribute__ ((packed)) WAVE_Format;


typedef struct
{
	short			exponent;
	long			mantissa[2];

} __attribute__ ((packed)) ieeeDoubleFP80;


typedef struct
{
	short			channels;
	long			sample_frames;	
	short   		bits_per_sample;
	ieeeDoubleFP80	samplerate;
	long			compression;

} __attribute__ ((packed)) COMM_Chunk;

////////////////////////////////////////////////////////////////////////////
// Get a longword from an unaligned pointer
////////////////////////////////////////////////////////////////////////////

static inline long GetLong( void *l )
{
unsigned short *s;

	s = (unsigned short *)l;

	return (s[0] << 16) | s[1];
}

////////////////////////////////////////////////////////////////////////////
// Convert an unaligned 32-bit value between little endian & big endian
////////////////////////////////////////////////////////////////////////////

static inline void SwapEndian32(long *l)
{
unsigned char *c, c0, c1;

	c = (unsigned char *)l;
	c0 = c[0];
	
	c[0] = c[3];
	c1 = c[1];
	c[1] = c[2];
	c[2] = c1;
	c[3] = c0;
}

////////////////////////////////////////////////////////////////////////////
// Convert an unaligned 16-bit value between little endian & big endian
////////////////////////////////////////////////////////////////////////////

static inline void SwapEndian16(short *l)
{
unsigned char *c, c0, c1;

	c = (unsigned char *)l;
	c0 = c[0];
	c1 = c[1];

	c[0] = c1;
	c[1] = c0;
}

////////////////////////////////////////////////////////////////////////////
// Byte-swap a WAV file header & data.
//
// This routine is largely similar to PlayWav since it has to parse the
// data in much the same way to figure out which parts to byte-swap
// and which parts to leave alone.  The byte-swapping is not integrated
// into PlayWav() because we really only want to have to do it once.
////////////////////////////////////////////////////////////////////////////

int WaveToNWave(void *wavaddr)
{
WAVE_Format *wav;
long *l;
short *pcm;
long pcm_length;
char *x;
int frequency, i, num_samples;
long *endfile;

	// We assume that "wavaddr" is long aligned here...
	l = (long *)wavaddr;

	// We don't bother verifying that this is a RIFF/WAVE file
	// since that should have been the test that sent us here.

	// Convert overall filesize & save it for loop testing
	SwapEndian32(&l[1]);
	endfile = (long *)((long)wavaddr + l[1]);
	
	// We could step past chunks looking for "fmt " but let's not.
	if( l[3] != 0x666d7420 )			// If the "fmt " chunk doesn't happen
		return(-1);						// here, we're screwed.


	// WAVE header would ordinarily start at the 5th longword
	wav = (WAVE_Format *)&l[5];

	// Convert all header fields from Little Endian to Big Endian
	SwapEndian16(&wav->compression);
	SwapEndian16(&wav->channels);
	SwapEndian32(&wav->samplerate);
	SwapEndian32(&wav->bytes_per_second);
	SwapEndian16(&wav->block_alignment);
	SwapEndian16(&wav->bits_per_sample);

// Once we've done that, then test the header information to make sure
// we don't have a sample format we can't handle anyway.  Note that if 
// the WAVE is rejected by this test, the header is partially
// converted already.  We could undo that, but it doesn't seem necessary.

	if( wav->compression != 1 )			// PCM compression all we can do
		return(-2);

	if( wav->bits_per_sample != 16 )	// We can only do 16-bit samples
		return(-3);

	if( wav->channels > 1 )				// We can only do MONO samples
		return(-4);	

// Calculate NUON sample rate value.  0x1000 = 24000

	frequency = (wav->samplerate * 0x1000) / 24000;

	if( frequency > 0x10000 )			// Make sure sample rate isn't too high.
		return(-5);						// We only can go to about 1 million samples/sec.
										// Yes, that was a joke.

	// Set RIFF header to indicate that we've already converted everything
	// Do this AFTER verifying that the WAVE format is acceptible.
	
	l[2] = 0x4E574156;					// Change "WAVE" to "NWAV"

// OK, now we've gotten the header figured out, let's
// locate and convert the actual sample data.
	
	x = (char *)wavaddr + 20;			// Skip to just past "fmt " chunkname
    
	SwapEndian32(&l[4]);				// Convert chunksize value
    x += l[4];							// Add size of "fmt " chunk
    l = (long *)x;						// Reset pointer to what should be "data" chunk
	
	// OK, now we should be be pointing at the "data" chunk.
	// If the chunk at "x" is not "data" then it might be one of
	// the extended information chunks we mentioned earlier, as
	// those frequently happen before the data chunk.
	// So skip past each chunk until we find "data"
	
	while( GetLong(l) != 0x64617461 && (l < endfile) )	// Is it the "data" chunk?
	{
		SwapEndian32(&l[1]);			// byte-swap chunk size
		
		x = (char *)l;					// Not data chunk so
		x += 4;							// step past chunk name,
        x += GetLong(&l[1]);			// add size of chunk,
		l = (long *)x;					// And reset pointer to next chunk.
	} 
	
	// Make sure we found "data" and didn't walk off the end
	if( *l != 0x64617461 )				// If not "data"
		return(-1);						// then unsupported format

	SwapEndian32(&l[1]);				// Convert size of data chunk

	pcm_length = l[1];					// Get size of "data" chunk
	pcm = (short *)&l[2];				// Get address of data
	num_samples = pcm_length / 2;		// Get number of samples

// Let us now convert the actual sample data

	for( i = 0; i < num_samples; i++ )
		SwapEndian16(pcm++);

	return(0);
}

////////////////////////////////////////////////////////////////////////////
// Decipher a WAV file and play the sound
// 
// Returns negative error number if sound cannot be played:
// 	-1 = Not valid WAV file, or has extra information we don't recognize
//  -2 = Not acceptible sound format or compression mode
//  -3 = Sample size is not recognized (uses 16-bit only)
//  -4 = Sample is not monophonic
//  -5 = Sample rate is out of range
////////////////////////////////////////////////////////////////////////////

int PlayWAV(void *wavaddr, int loop, PCMPOS *Pan, int volume, int echo)
{
long *l, *pcm, pcm_length;
char *x;
int frequency;
WAVE_Format *wav;
PCMHEAD WaveDefine;
int result;
long *endfile;

	l = (long *)wavaddr;

	// Verify data as a WAV file
	if( l[0] != 0x52494646 )			// "RIFF"
		return(-1);

	// Get overall filesize & save it for loop testing
	endfile = (long *)((long)wavaddr + l[1]);
	
	if( l[2] != 0x57415645 && l[2] != 0x4E574156 )	// "WAVE" or "NWAV"
		return(-1);
	
// See if the sample has already been converted from little-endian
// to big endian format, and if not, then go convert it right now!

	if( l[2] != 0x4E574156 )			// If not "NWAV"
	{
		result = WaveToNWave(wavaddr);	// Go byte-swap from INTEL format
		
		if( result )					// Conversion will return non-zero 
			return(-2);					// if it's a format we don't like

		// Note that if the WAVE is rejected, the header may be partially
		// converted already.
	}

	
	// We presume that the "fmt " chunk starts at l[3] and that this
	// has been previously verified by WaveToNWave().
	// We could step past chunks looking for "fmt " but let's not.

	
	// Get sample rate out of WAVE header.
	// We've already determined in WaveToNWave() that the WAVE format
	// is OK, so we don't need to check most WAVE header info again.

	wav = (WAVE_Format *)&l[5];
	frequency = (wav->samplerate * 0x1000) / 24000;


	x = (char *)wavaddr + 20;			// Skip to "fmt " chunk
	x += l[4];							// Add size of "fmt " chunk
	l = (long *)x;						// Reset pointer to what should be "data" chunk
	
	// If the chunk at "x" is not "data" then it might be one of
	// the extended information chunks we mentioned earlier, as
	// those frequently happen before the data chunk.
	
	while( GetLong(l) != 0x64617461 && (l < endfile) )	// Is it the "data" chunk?
	{
		x = (char *)l;					// Not data chunk so
		x += 4;							// step past chunk name,
		x += GetLong(&l[1]);			// add size of chunk,
		l = (long *)x;					// And reset pointer to next chunk.
	} 
    
	if( GetLong(l) != 0x64617461 )		// If not "data"
		return(-2);						// then unsupported format

	pcm_length = l[1];					// Get size of "data" chunk
	pcm = &l[2];						// Get address of data
    
	// OK, everything we did earlier was simply to get to the right location
	// for the data, and to figure out what the sample rate value should be.
    
	WaveDefine.PCMWaveBegin = (unsigned long)pcm;
    WaveDefine.PCMLength    = pcm_length / 2;
    WaveDefine.PCMLoopBegin = 0;
    WaveDefine.PCMLoopEnd   = pcm_length / 2;
    WaveDefine.PCMBaseFreq  = frequency;
    WaveDefine.PCMControl   = loop!=-1?1:0;
//	return 0;
	return PCMPlaySample(-1, &WaveDefine, Pan, volume, echo );
}

////////////////////////////////////////////////////////////////////////////
// Decipher an AIFF file and play the sound
// 
// Returns negative error number if sound cannot be played:
// 	-1 = Not valid AIFF file, or has extra information
//  -2 = Not acceptible sound format or compression mode
//  -3 = Sample size is not recognized (uses 16-bit only)
//  -4 = Sample is not monophonic
//  -5 = Sample rate is out of range
////////////////////////////////////////////////////////////////////////////

int PlayAIFF(void *wavaddr, int voice, PCMPOS *Pan, int volume, int echo )
{
long *l, *pcm, pcm_length;
char *x;
int frequency;
COMM_Chunk *comm;
PCMHEAD WaveDefine;
int		comm_size;
int		ieeeExponent, ieeeMantissa;
int		samplerate;
int		shiftamt;

//int		result;
//int		i1, i2;
//short	*s, *ip1, *ip2;
//int		*i;
long	*endfile;

	l = (long *)wavaddr;

	// Verify data as an AIFF file
	if( l[0] != 0x464F524D )			// "FORM"
		return(-1);

	// Get overall size of file for loop testing
	endfile = (long *)((long)wavaddr + l[1]);

	if( l[2] != 0x41494646 )			// "AIFF"
		return(-1);

	if( l[3] != 0x434F4D4D )			// "COMM"
		return(-1);

	comm_size = l[4];
    comm = (COMM_Chunk *)&l[5];
    
	if( comm_size >= 22 )				// Compression field doesn't exist if have small COMM chunk
	{
		if( comm->compression != 0x4E4F4E45 )	// compression = "NONE"
		{
			return(-2);
		}
	}

	if( comm->bits_per_sample != 16 )	// We can only do 16-bit samples
	{
		return(-3);
	}

	if( comm->channels > 1 )			// We can only do MONO samples
	{
		return(-4);	
	}
	
	ieeeExponent = comm->samplerate.exponent;
	ieeeMantissa = comm->samplerate.mantissa[0];

	shiftamt = (16414 - ieeeExponent);
	samplerate = ieeeMantissa >> 1;			// Do first shift
    samplerate &= 0x7FFFFFFF;				// Then make sure sign bit is clear
	samplerate >>= --shiftamt;				// Then do remaining shift

	frequency = (samplerate * 0x1000) / 24000;

	if( frequency > 0x10000 )			// Make sure sample rate isn't too high.
		return(-5);						// We only can go to about 1 million samples/sec.
										// Yes, that was a joke.

	x = (char *)wavaddr + 20;			// Skip to just past "COMM" chunk
	x += l[4];							// Add size of "COMM" chunk
	l = (long *)x;						// Reset pointer to what should be "SSND" chunk
		
	// Now we should be at SSND chunk.
#if 1		
	// Note that an AIFF file might have chunks of data
	// with information like author info, or copyright info,
	// etc.  The loop below will attempt to step past 
	// anything like that until it finds the SSND chunk 
	// where the sound sample data is stored.
	
	while( GetLong(l) != 0x53534e44 && (l < endfile) )	// Is it the "SSND" chunk?
	{
		x = (char *)l;					// Not SSND chunk so
		x += 4;							// step past chunk name,
		x += GetLong(&l[1]);			// add size of chunk,
		l = (long *)x;					// And reset pointer to next chunk.
	} 
#endif
	
	// Verify that the loop above didn't run off the end of the file

	if( GetLong(l) != 0x53534E44 )		// If not "SSND"
		return(-2);						// then unsupported format  

	pcm_length = GetLong(&l[1]);		// Get size of "SSND" chunk

	pcm_length -= 8;					// Subtract 8 extra bytes at beginning
	pcm = &l[4];						// Get address of data chunk + 8 extra bytes

    // OK, everything we did earlier was simply to get to the right location
	// for the data, and to figure out what the sample rate value should be.

    WaveDefine.PCMWaveBegin = (unsigned long)pcm;
    WaveDefine.PCMLength    = pcm_length / 2;
    WaveDefine.PCMLoopBegin = 0;
    WaveDefine.PCMLoopEnd   = pcm_length / 2;
    WaveDefine.PCMBaseFreq  = frequency;
    WaveDefine.PCMControl   = 0;

	return PCMPlaySample(voice, &WaveDefine, Pan, volume, echo );
}

