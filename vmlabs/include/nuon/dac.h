/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

/*
 ************************************************************************
 * File Name:   dac.h
 * Author:      Andreas Binner
 * Purpose:     Low-Level DAC programming functions for Burr-Brown 1723 DAC
 */

void _DACReset(void);
void _DACMute(int state);
void _DACSetDeEmphasis(int state);
long _DACSetSampleRate(long rate);
long _DACSetSampleWidth(long width);
long _DACGetSupportedSampleRates(void);
