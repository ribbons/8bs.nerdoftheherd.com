/*
 * Copyright © 2015-2022 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

// cppcheck-suppress unusedFunction
void Init_bbc_native()
{
    VALUE mBBC = rb_define_module("BBC");
    VALUE NativeFilters = rb_define_module_under(mBBC, "NativeFilters");

    rb_define_method(NativeFilters, "mode7_mem_to_html", method_mode7_mem_to_html, 1);
    rb_define_method(NativeFilters, "bbc_pic_to_img", method_bbc_pic_to_img, 3);

    init_abz_file(mBBC);
    init_arc_file(mBBC);
    init_basic_file(mBBC);
    init_dispmo7_file(mBBC);
}
