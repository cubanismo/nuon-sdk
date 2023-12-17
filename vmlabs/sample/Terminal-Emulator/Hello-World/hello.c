/*
 * Hello World - Shows minimum screen setup & text output
 *
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <nuon/termemu.h>

int main()
{
     InitTerminal(0,0);
     Print("Hello World",kWhite,kBlack);
     for(;;);
}
