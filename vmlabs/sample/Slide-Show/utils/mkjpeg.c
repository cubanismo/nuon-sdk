/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

// utility to generate a header file from a list of JPEGs.

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define SRCDIR "../jpegfiles/"
#define LEN 128         // maximum length of jpeg file name

int BlankLine(char *str)
{
    while (*str) {
        if (!isspace(*str++))
            return 0;
    }
    return 1;
}

void RemoveTrailingWhitespace(char *str)
{
    char *p;
    int n;

    n = strlen(str);
    p = str + n - 1;
    while (isspace(*p)) {
        *p = 0;
        p--;
    }
}
            

void main(int argc, char *argv[])
{
    FILE *in, *out;
    char str[128], *p;
    int i, j;
    
    if (argc < 2) {
        printf("usage: mkjpeg listfile\n");
        return;
    }
    in = fopen(argv[1], "r");
    if (!in) {
        printf("Cannot open listfile: %s\n", argv[1]);
        return;
    }
    out = fopen("jpegfiles.s", "w");

    fprintf(out, "\t.data\n");
    i = 0;
    while (fgets(str,LEN,in)) {
        p = strchr(str,';');
        if (p) *p = 0; 
        RemoveTrailingWhitespace(str);
        if (BlankLine(str))
            continue;
        i++;
        fprintf(out, "\n\t.align.v\nimage%d:\n", i);
        fprintf(out, "\t.binclude \"%s%s\"\n", SRCDIR, str);
        fprintf(out, "`end:\n");
        fprintf(out,"\timsize%d = `end - image%d\n", i, i);
    }
    fprintf(out, "\n\t.export _NumImages, _ImageArr, _ImageSize\n");
    fprintf(out, "\t.align.s\n");
    fprintf(out, "\n_NumImages:\n\t.dc.s %d\n", i);
    fprintf(out, "\n_ImageArr:\n");
    for (j = 1; j <= i; j++)
        fprintf(out, "\t.dc.s image%d\n", j);
    fprintf(out, "\n_ImageSize:\n");
    for (j = 1; j <= i; j++)
        fprintf(out, "\t.dc.s imsize%d\n", j);
    fclose(in);
    fclose(out);
}