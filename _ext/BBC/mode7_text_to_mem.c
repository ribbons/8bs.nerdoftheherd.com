/*
 * Copyright © 2015-2019 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

VALUE mode7_text_to_mem(VALUE input)
{
    char* data = RSTRING_PTR(input);
    long dataLen = RSTRING_LEN(input);

    GString *output = g_string_sized_new((gsize)dataLen);

    unsigned int column = 0;

    for(long i = 0; i < dataLen; i++)
    {
        char c = data[i];

        // Map to correct in-memory bytes to replicate
        // the behaviour of OSWRCH on the BBC if appropriate
        switch((unsigned char)c)
        {
            case 0x07: // Beep - ignore
                continue;
            case 0x08: // Back
                // Probably hiding line numbers or code - ignore
                continue;
            case 0x0c: // Clear screen - ignore
                continue;
            case 0x0e: // Paged mode - ignore
                continue;
            case 0x15: // Disable VDU - ignore
                continue;
            case 0x16: // Set Mode
                // Also uses the value of the next byte
                i++;
                continue;
            case 0x23: // '#'
                c = 0x5f;
                break;
            case 0x5f: // '-'
                c = 0x60;
                break;
            case 0x60: // '£'
                c = 0x23;
                break;
            case 0x8A: // 'Nothing', displays as a space
                c = ' ';
                break;
        }

        if(c == 13)
        {
            unsigned int fillcols = MODE7_COLS - column;
            size_t prevLen = output->len;

            g_string_set_size(output, prevLen + fillcols);
            memset(&output->str[prevLen], ' ', fillcols);

            column = 0;
        }
        else
        {
            g_string_append_c(output, c);
            column = (column + 1) % 40;
        }
    }

    VALUE outputR = rb_str_new(output->str, (long)output->len);
    g_string_free(output, true);

    return outputR;
}
