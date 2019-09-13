/*
 * This file is part of the 8BS Online Conversion.
 * Copyright © 2019 by the authors - see the AUTHORS file for details.
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

#include "bbc_native.h"

#define BASIC_LINE_START (char)0x0d
#define BASIC_T_DATA     (char)0xdc
#define BASIC_EOF        (char)0xff

VALUE cBasicFile;

VALUE basicfile_initialize(VALUE self, VALUE data)
{
    rb_iv_set(self, "@data", data);
    return self;
}

VALUE parse(VALUE self, VALUE bbcfile)
{
    VALUE content = rb_funcall(bbcfile, rb_intern("content"), 0);

    char* input = RSTRING_PTR(content);
    char* endinput = input + RSTRING_LEN(content);

    VALUE data = rb_hash_new();

    for(char* p = input; p <= endinput; )
    {
        char* linestart = p;

        if(*p++ != BASIC_LINE_START)
        {
            return Qnil;
        }

        if(*p == BASIC_EOF)
        {
            break;
        }

        int line_num = (uint8_t)*p++ << 8;
        line_num |= (uint8_t)*p++;

        char* nextline = linestart + (uint8_t)*p++;

        while(*p == ' ')
        {
            p++;
        }

        if(*p++ == BASIC_T_DATA)
        {
            VALUE linedata = rb_ary_new();

            do
            {
                char* start = p;

                while(p < nextline && *p != ',')
                {
                    p++;
                }

                char* end = p - 1;

                while(*start == ' ')
                {
                    start++;
                }

                rb_ary_push(linedata, rb_str_new(start, (end - start) + 1));
            }
            while(p++ < nextline);

            rb_hash_aset(data, INT2NUM(line_num), linedata);
        }

        p = nextline;
    }

    return rb_class_new_instance(1, &data, cBasicFile);
}

void init_basic_file(VALUE mBBC)
{
    cBasicFile = rb_define_class_under(mBBC, "BasicFile", rb_cObject);
    rb_define_attr(cBasicFile, "data", 1, 0);
    rb_define_method(cBasicFile, "initialize", basicfile_initialize, 1);
    rb_define_singleton_method(cBasicFile, "parse", parse, 1);
}
