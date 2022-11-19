/*
 * Copyright © 2022 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

VALUE cMode7File;

void init_mode7_mapping_tables();

static VALUE mode7file_initialize(VALUE self, VALUE screendata)
{
    rb_iv_set(self, "@screendata", screendata);
    return self;
}

static VALUE parse(VALUE self, VALUE bbcfile)
{
    VALUE argv[] = {rb_funcall(bbcfile, rb_intern("content"), 0)};
    return rb_class_new_instance(ARRAY_LEN(argv), argv, cMode7File);
}

static VALUE to_html(VALUE self)
{
    VALUE screendata = rb_iv_get(self, "@screendata");
    return mode7_mem_to_html(screendata);
}

void init_mode7_file(VALUE mBBC)
{
    cMode7File = rb_define_class_under(mBBC, "Mode7File", rb_cObject);

    rb_define_attr(cMode7File, "screendata", 1, 0);

    rb_define_method(cMode7File, "initialize", mode7file_initialize, 1);
    rb_define_method(cMode7File, "to_html", to_html, 0);

    rb_define_singleton_method(cMode7File, "parse", parse, 1);

    init_mode7_mapping_tables();
}
