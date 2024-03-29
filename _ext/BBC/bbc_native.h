/*
 * Copyright © 2015-2024 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <stdbool.h>
#include <sys/param.h>
#include <ruby.h>

// Just enable conversion warnings for our code
#pragma GCC diagnostic error "-Wconversion"

#define MODE7_COLS 40
#define MODE7_ROWS 25

#define STR_AND_LEN(s) s, sizeof(s) - 1
#define ARRAY_LEN(a) (sizeof(a) / sizeof(a[0]))

VALUE mode7_text_to_mem(VALUE input);
VALUE mode7_mem_to_html(VALUE input);
VALUE method_bbc_pic_to_img(VALUE self, VALUE input, VALUE type, VALUE mode);

void init_abz_file(VALUE mBBC);
void init_arc_file(VALUE mBBC);
void init_basic_file(VALUE mBBC);
void init_dispmo7_file(VALUE mBBC);
void init_mode7_file(VALUE mBBC);
void init_mode7_screen_file(VALUE mBBC);
