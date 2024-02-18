/*
 * Copyright © 2024 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

#define MODE7_MEM_START 0x7C00
#define MODE7_MEM_END 0x7FFF
#define MIN_LINES 10

VALUE cMode7ScreenFile;

static VALUE parse(VALUE self, VALUE bbcfile)
{
    VALUE content = rb_funcall(bbcfile, rb_intern("content"), 0);
    unsigned int loadaddr =
        NUM2UINT(rb_funcall(bbcfile, rb_intern("loadaddr"), 0));

    char* input = RSTRING_PTR(content);
    long length = RSTRING_LEN(content);

    if(length > MODE7_MEM_END - MODE7_MEM_START + 1)
    {
        return Qnil;
    }

    long startaddr = MAX(loadaddr, MODE7_MEM_START);
    long endaddr = MIN(loadaddr + length,
                       MODE7_MEM_START + MODE7_ROWS * MODE7_COLS);
    long outlength = endaddr - startaddr;

    if(outlength <= MODE7_COLS * MIN_LINES)
    {
        return Qnil;
    }

    VALUE screendata = rb_str_new(input + startaddr - loadaddr, outlength);
    VALUE argv[] = {screendata};
    return rb_class_new_instance(ARRAY_LEN(argv), argv, cMode7ScreenFile);
}

void init_mode7_screen_file(VALUE mBBC)
{
    VALUE cMode7File = rb_define_class_under(mBBC, "Mode7File", rb_cObject);
    cMode7ScreenFile = rb_define_class_under(mBBC, "Mode7ScreenFile", cMode7File);

    rb_define_singleton_method(cMode7ScreenFile, "parse", parse, 1);
}
