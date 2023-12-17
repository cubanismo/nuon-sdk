/*
 * Title	 			MDRAND.H
 * Desciption		M3DL Random Function
 * Version			1.0
 * Start Date		09/02/1999
 * Last Update	09/02/1999
 * By						Phil
 * Of						Miracle Designs
 * Comments
 *  						Minimal Standard Random Generator by Park & Miller
*/

#ifndef __mdRAND_
#define __mdRAND_

#include <m3dl/mdtypes.h>

//Structure, as future implementations may need more seed data to be stored.
typedef struct {
	mdUINT32	seed;								//Seed
} mdRANDSEED;

//Note: Since the random generator is multiplicative, use this seed
//			setter to avoid illegal seed values
void mdSetRandSeed(mdRANDSEED *randseed, mdUINT32 seed);

//Note: Minimum is INclusive, Maximum is EXclusive!
//Note: Result is undefined if (Min-Max range > 0x7FFFFFFF)
mdINT32	mdRand(mdRANDSEED *randseed, mdINT32 min, mdINT32 max);
#endif
