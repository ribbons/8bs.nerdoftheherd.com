/*
 * Copyright © 2022 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

#define MODE7_ROWS 25
#define HEADER_SIZE 4
#define MIN_PAGE 0x0E00

VALUE cDispmo7File;

static VALUE parse(VALUE self, VALUE bbcfile)
{
    VALUE content = rb_funcall(bbcfile, rb_intern("content"), 0);
    unsigned int loadaddr =
        NUM2UINT(rb_funcall(bbcfile, rb_intern("loadaddr"), 0));
    unsigned int execaddr =
        NUM2UINT(rb_funcall(bbcfile, rb_intern("execaddr"), 0));

    if(loadaddr < MIN_PAGE)
    {
        return Qnil;
    }

    char* input = RSTRING_PTR(content);
    long length = RSTRING_LEN(content);

    if(length < HEADER_SIZE)
    {
        return Qnil;
    }

    uint16_t startaddr = (uint16_t)((uint8_t)input[1] << 8 | (uint8_t)input[0]);
    uint16_t endaddr = (uint16_t)((uint8_t)input[3] << 8 | (uint8_t)input[2]);

    if(execaddr < loadaddr + HEADER_SIZE || startaddr <= loadaddr ||
       endaddr <= startaddr)
    {
        return Qnil;
    }

    unsigned int start = startaddr - loadaddr;
    unsigned int end = endaddr - loadaddr + MODE7_ROWS * MODE7_COLS;

    if(end > length)
    {
        if(end == length + MODE7_COLS)
        {
            // Very early versions of the loader calculate the end of the data
            // one line earlier
            end -= MODE7_COLS;
        }
        else
        {
            return Qnil;
        }
    }

    VALUE screendata = rb_str_new(input + start, end - start);

    VALUE argv[] = {screendata};
    return rb_class_new_instance(ARRAY_LEN(argv), argv, cDispmo7File);
}

void init_dispmo7_file(VALUE mBBC)
{
    VALUE cMode7File = rb_define_class_under(mBBC, "Mode7File", rb_cObject);
    cDispmo7File = rb_define_class_under(mBBC, "Dispmo7File", cMode7File);

    rb_define_singleton_method(cDispmo7File, "parse", parse, 1);
}
