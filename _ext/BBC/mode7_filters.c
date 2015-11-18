﻿/*
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

#include "mode7_filters.h"

void Init_mode7_filters_c()
{
	VALUE BBC = rb_define_module("BBC");
	VALUE Mode7Filters = rb_define_module_under(BBC, "Mode7Filters");

	rb_define_method(Mode7Filters, "mode7_text_to_mem", method_mode7_text_to_mem, 1);
	rb_define_method(Mode7Filters, "mode7_mem_to_html", method_mode7_mem_to_html, 1);
}
