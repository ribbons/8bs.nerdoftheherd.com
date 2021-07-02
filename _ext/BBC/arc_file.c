/*
 * Copyright © 2021 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

#define ARC_HEADER_START    '\x1a'
#define ARC_TYPE_EOF        '\x00'
#define ARC_TYPE_CRUNCH_LZW '\x08'

#define ARC_HDR_SIZE  29
#define ARC_EOF_SIZE   2
#define ARC_NAME_SIZE 13

VALUE cArcFile, cBBCFile;

void arc_decompress(char* input, uint32_t inlen, char* output, uint32_t outlen);

static uint32_t read_length(uint8_t* p)
{
    return (uint32_t)(*p + (*(p + 1) << 8) + (*(p + 2) << 16) + (*(p + 3) << 24));
}

static VALUE parse(VALUE self, VALUE bbcfile)
{
    VALUE content = rb_funcall(bbcfile, rb_intern("content"), 0);

    char* input = RSTRING_PTR(content);
    char* endinput = input + RSTRING_LEN(content);

    VALUE tweaks = rb_funcall(bbcfile, rb_intern("tweaks"), 0);

    if(tweaks != Qnil)
    {
        tweaks = rb_hash_aref(tweaks, ID2SYM(rb_intern("files")));
    }

    VALUE files = rb_ary_new();

    char* p = input;

    for(;;)
    {
        if(p + ARC_EOF_SIZE > endinput)
        {
            // Not enough bytes remaining for valid EOF
            return Qnil;
        }

        if(*p++ != ARC_HEADER_START)
        {
            return Qnil;
        }

        char type = *p++;

        if(type == ARC_TYPE_EOF)
        {
            if(p != endinput && RARRAY_LEN(files) == 0)
            {
                // File started with an EOF marker and contains further data,
                // unlikely to be an archive
                return Qnil;
            }

            break;
        }
        else if(type != ARC_TYPE_CRUNCH_LZW)
        {
            // Unimplemented or invalid type
            return Qnil;
        }

        if(p + (ARC_HDR_SIZE - ARC_EOF_SIZE) > endinput)
        {
            // Not enough bytes left for rest of header
            return Qnil;
        }

        VALUE filename = rb_str_new2(p);
        p += ARC_NAME_SIZE;

        uint32_t compr_len = read_length((uint8_t*)p);
        p += 4;

        // Skip the file date, time & CRC
        p += 6;

        uint32_t uncomp_len = read_length((uint8_t*)p);
        p += 4;

        if(p + compr_len > endinput)
        {
            // Less data left than size in header - corrupt or not an archive
            return Qnil;
        }

        char* contentbuf;

        if(!(contentbuf = malloc(uncomp_len)))
        {
            rb_fatal("Not enough memory for output buffer.");
        }

        arc_decompress(p, compr_len, contentbuf, uncomp_len);
        VALUE filecontent = rb_str_new(contentbuf, uncomp_len);
        free(contentbuf);

        VALUE filetweaks = Qnil;

        if(tweaks != Qnil)
        {
            filetweaks = rb_hash_aref(tweaks, filename);
        }

        VALUE fargs[] = {INT2NUM(0), rb_str_new2("$"), filename,
                         UINT2NUM(0xFFFFFFFF), UINT2NUM(0xFFFFFFFF),
                         filecontent, filetweaks};

        VALUE file = rb_class_new_instance(ARRAY_LEN(fargs), fargs, cBBCFile);

        rb_ary_push(files, file);
        p += compr_len;
    }

    VALUE arcargs[] = {files};
    return rb_class_new_instance(ARRAY_LEN(arcargs), arcargs, cArcFile);
}

void init_arc_file(VALUE mBBC)
{
    VALUE cArchiveFile = rb_define_class_under(mBBC, "ArchiveFile", rb_cObject);
    cArcFile = rb_define_class_under(mBBC, "ArcFile", cArchiveFile);
    cBBCFile = rb_define_class_under(mBBC, "BBCFile", rb_cObject);

    rb_define_singleton_method(cArcFile, "parse", parse, 1);
}
