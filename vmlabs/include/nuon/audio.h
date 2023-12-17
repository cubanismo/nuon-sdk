/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

#ifndef _AUDIO_H
#define _AUDIO_H

#define RATE_44_1_KHZ_B	 0
#define RATE_88_2_KHZ_B	 1
#define RATE_22_05_KHZ_B 2

#define RATE_48_KHZ_B	 4
#define RATE_96_KHZ_B	 5
#define RATE_24_KHZ_B	 6

#define RATE_32_KHZ_B	 8
#define RATE_64_KHZ_B	 9
#define RATE_16_KHZ_B	 10

#define RATE_48_KHZ	 (1 << RATE_48_KHZ_B)
#define RATE_44_1_KHZ	 (1 << RATE_44_1_KHZ_B)
#define RATE_32_KHZ	 (1 << RATE_32_KHZ_B)

#define RATE_96_KHZ	 (1 << RATE_96_KHZ_B)
#define RATE_88_2_KHZ	 (1 << RATE_88_2_KHZ_B)
#define RATE_64_KHZ	 (1 << RATE_64_KHZ_B)

#define RATE_24_KHZ	 (1 << RATE_24_KHZ_B)
#define RATE_22_05_KHZ	 (1 << RATE_22_05_KHZ_B)
#define RATE_16_KHZ	 (1 << RATE_16_KHZ_B)

#define STREAM_TWO_16_BIT 	 (0<<3)
#define STREAM_FOUR_16_BIT 	 (1<<3)
#define STREAM_TWO_32_BIT 	 (2<<3)
#define STREAM_EIGHT_16_BIT 	 (3<<3)
#define STREAM_EIGHT_32_BIT 	 (2<<3)+(1<<13)
#define STREAM_FOUR_32_BIT 	 (3<<3)+(1<<13)

#define BUFFER_SIZE_1K 	 	 (1<<5)
#define BUFFER_SIZE_2K 	 	 (2<<5)
#define BUFFER_SIZE_4K 	 	 (3<<5)
#define BUFFER_SIZE_8K 	 	 (4<<5)
#define BUFFER_SIZE_16K 	 (5<<5)
#define BUFFER_SIZE_32K 	 (6<<5)
#define BUFFER_SIZE_64K 	 (7<<5)

#define ENABLE_AUDIO_DMA	(1<<0)
#define ENABLE_WRAP_INT		(1<<8)
#define ENABLE_HALF_INT		(1<<9)
#define ENABLE_SAMP_INT		(1<<10)
#define ENABLE_DMA_SKIP		(1<<11)
#define ENABLE_DMA_STALL	(1<<12)

#ifdef __cplusplus
extern "C" {
#endif

long _AudioMute(int state);
long _AudioReset(void);
long _AudioQuerySampleRates(void);
long _AudioSetSampleRate(long rateField);
long _AudioQueryChannelMode(void);
void _AudioSetChannelMode(long mode);
void _AudioSetDMABuffer(void *dmaBaseAddr);
#ifdef __cplusplus
	   }
#endif

#endif
