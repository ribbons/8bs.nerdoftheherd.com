/*
 * This file is part of the 8BS Online Conversion.
 * Copyright © 2015 by the authors - see the AUTHORS file for details.
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General
 * Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
 * License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

#include <stdbool.h>
#include <glib.h>
#include <ruby.h>

#define MODE7_COLS 40

#define STR_AND_LEN(s) s, sizeof(s) - 1

VALUE method_mode7_text_to_mem(VALUE self, VALUE input);
VALUE method_mode7_mem_to_html(VALUE self, VALUE input);
