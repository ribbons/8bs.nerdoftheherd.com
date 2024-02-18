/*
 * Copyright © 2015-2024 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

// cppcheck-suppress unusedFunction
void Init_bbc_native()
{
    VALUE mBBC = rb_define_module("BBC");
    VALUE NativeFilters = rb_define_module_under(mBBC, "NativeFilters");

    rb_define_method(NativeFilters, "bbc_pic_to_img", method_bbc_pic_to_img, 3);

    rb_const_set(mBBC, rb_intern("MODE7_ROWS"), INT2FIX(MODE7_ROWS));
    rb_const_set(mBBC, rb_intern("MODE7_COLS"), INT2FIX(MODE7_COLS));

    init_abz_file(mBBC);
    init_arc_file(mBBC);
    init_basic_file(mBBC);
    init_dispmo7_file(mBBC);
    init_mode7_file(mBBC);
    init_mode7_screen_file(mBBC);
}
