/*
 * This file is part of the 8BS Online Conversion.
 * Copyright © 2015-2021 by the authors - see the AUTHORS file for details.
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

void Init_bbc_native()
{
    VALUE mBBC = rb_define_module("BBC");
    VALUE NativeFilters = rb_define_module_under(mBBC, "NativeFilters");

    rb_define_method(NativeFilters, "mode7_mem_to_html", method_mode7_mem_to_html, 1);
    rb_define_method(NativeFilters, "bbc_pic_to_img", method_bbc_pic_to_img, 3);

    init_arc_file(mBBC);
    init_basic_file(mBBC);
}
