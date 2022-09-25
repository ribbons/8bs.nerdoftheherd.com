/*
 * Copyright © 2022 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

#define PAGE_SIZE 1024
#define MIN_LINES 23

VALUE cAbzFile;
char blankLine[MODE7_COLS];

static bool allPrintable(char* data, size_t len)
{
    for(int i = 0; i < len; i++)
    {
        if((unsigned char)data[i] < ' ')
        {
            return false;
        }
    }

    return true;
}

static VALUE parse(VALUE self, VALUE bbcfile)
{
    VALUE content = rb_funcall(bbcfile, rb_intern("content"), 0);
    long length = RSTRING_LEN(content);

    if(length == 0 || length % PAGE_SIZE != 0)
    {
        return Qnil;
    }

    char* input = RSTRING_PTR(content);
    long pages = length / PAGE_SIZE;

    VALUE screendata = rb_str_buf_new(MODE7_COLS * MODE7_ROWS * pages);

    for(int page = 0; page < pages; page++)
    {
        char* pageData = input + (page * PAGE_SIZE);
        int lineCount = MODE7_ROWS;

        for(int line = 0; line < MODE7_ROWS; line++)
        {
            if(!allPrintable(pageData + line * MODE7_COLS, MODE7_COLS))
            {
                lineCount = line;
                break;
            }
        }

        if(lineCount < MIN_LINES)
        {
            return Qnil;
        }

        if(lineCount == MODE7_ROWS)
        {
            if(allPrintable(pageData + MODE7_COLS * MODE7_ROWS,
                            PAGE_SIZE - MODE7_COLS * MODE7_ROWS))
            {
                return Qnil;
            }
        }

        if(lineCount < MODE7_ROWS)
        {
            rb_str_cat(screendata, blankLine, sizeof(blankLine));
        }

        rb_str_cat(screendata, pageData, MODE7_COLS * lineCount);

        if(lineCount == MIN_LINES)
        {
            rb_str_cat(screendata, blankLine, sizeof(blankLine));
        }
    }

    VALUE argv[] = {screendata};
    return rb_class_new_instance(ARRAY_LEN(argv), argv, cAbzFile);
}

void init_abz_file(VALUE mBBC)
{
    memset(blankLine, ' ', sizeof(blankLine));

    VALUE cMode7File = rb_define_class_under(mBBC, "Mode7File", rb_cObject);
    cAbzFile = rb_define_class_under(mBBC, "AbzFile", cMode7File);

    rb_define_singleton_method(cAbzFile, "parse", parse, 1);
}
