/*
 * This file is part of the 8BS Online Conversion.
 * Copyright © 2017 by the authors - see the AUTHORS file for details.
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

#include <ruby.h>
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

// Output and state tracking
u_char *output;
int outpos, outlength;

VALUE method_decompress(VALUE self, VALUE input, VALUE rb_outlength)
{
    // Load arc's input buffer with the entire file contents and set the
    // buffer length variable used by getb_unp to the length
    pinbuf = (u_char*)RSTRING_PTR(input);
    stdlen = RSTRING_LEN(input);

    outlength = FIX2INT(rb_outlength);
    outpos = 0;

    if(!(outbuf = malloc(MYBUF)))
    {
        rb_fatal("Not enough memory for output buffer.");
    }

    if(!(pakbuf = malloc(2L*MYBUF)))
    {
        rb_fatal("Not enough memory for packing buffer.");
    }

    if(!(output = malloc(outlength)))
    {
        rb_fatal("Not enough memory for output buffer.");
    }

    // As we have replaced the getb_unp and putb_unp functions with ones that
    // do not read or write files, just pass NULLs as the file handles so that
    // we can keep the same prototype
    decomp(0, NULL, NULL);

    if(outpos < outlength)
    {
        rb_fatal("Extracted data shorter (%d) than defined in file header (%d)", outpos, outlength);
    }

    VALUE retVal = rb_str_new((char*)output, outlength);

    free(outbuf);
    free(pakbuf);
    free(output);

    return retVal;
}

/*
 * In arc this function gets more data from the file, but as we have loaded the
 * whole file into a buffer, we can just return the length of the buffer, or
 * zero if all of the buffer has been processed.
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
    if(outpos + len > outlength)
    {
        rb_fatal("Extracted data larger (%d) than defined in file header (%d)", outpos + len, outlength);
    }

    memcpy(output + outpos, buf, len);
    outpos += len;
}

void Init_arc2_c()
{
    VALUE Arc2 = rb_path2class("EBS::Arc2");
    rb_define_method(Arc2, "decompress", method_decompress, 2);
}
