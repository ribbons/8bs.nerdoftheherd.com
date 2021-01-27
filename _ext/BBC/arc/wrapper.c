/*
 * This file is part of the 8BS Online Conversion.
 * Copyright © 2017-2021 by the authors - see the AUTHORS file for details.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "arc.h"

// Main decompression function prototype
void decomp(int squash, FILE *f, FILE *t);

// Global arc variables we need to access
extern long    stdlen;
extern u_char *outbuf;

// Define declared extern variables
int nerrs = 0;
int lastc, dosquash, curin;
u_char *pinbuf, *pakbuf;
u_char  state;

// Output buffer positions
u_char *outp, *outendp;

void arcdie(const char *format, ...)
{
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);

    printf("\n");
    exit(1);
}

void arc_decompress(char* input, uint32_t inlen, char* output, uint32_t outlen)
{
    // Set arc's input buffer to the entire compressed file content and set the
    // buffer length variable used by getb_unp to the full length
    pinbuf = (u_char*)input;
    stdlen = inlen;

    if(!(outbuf = malloc(MYBUF)))
    {
        arcdie("Not enough memory for output buffer.");
    }

    if(!(pakbuf = malloc(2L*MYBUF)))
    {
        arcdie("Not enough memory for packing buffer.");
    }

    outp = (u_char*)output;
    outendp = outp + outlen;

    // As we have replaced the getb_unp and putb_unp functions with ones that
    // do not read or write files, just pass NULLs as the file handles so that
    // we can keep the original prototype
    decomp(0, NULL, NULL);

    if(outp < outendp)
    {
        arcdie("Extracted data shorter (%zd) than defined in file header (%d)",
               outendp - outp, outlen);
    }

    free(outbuf);
    free(pakbuf);
}

/*
 * In arc this function gets more data from the file, but as we have all of the
 * data in a buffer, we can just return the length of the buffer or zero if all
 * of the buffer has been processed.
 */

u_int getb_unp(FILE *f)
{
    u_int len;

    len = stdlen;
    stdlen = 0;

    return len;
}

/*
 * In arc this function writes to the output file but as we want to keep the
 * file data in memory, just copy it to our output buffer (making sure not to
 * overflow if there is more data than expected)
 */

void putb_unp(u_char *buf, u_int len, FILE *t)
{
    if(outp + len > outendp)
    {
        arcdie("Extracted data larger than defined in file header");
    }

    memcpy(outp, buf, len);
    outp += len;
}
