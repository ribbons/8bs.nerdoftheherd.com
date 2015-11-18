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

#include "mode7_filters.h"

VALUE method_mode7_text_to_mem(VALUE self, VALUE input)
{
	char* data = RSTRING_PTR(input);
	int dataLen = RSTRING_LEN(input);

	int buffill = 0;
	int bufsize = dataLen * 2;
	char *buffer = malloc(bufsize);

	int column = 0;

	for(int i = 0; i < dataLen; i++)
	{
		char c = data[i];

		// Map to correct Teletext characters to replicate
		// the behaviour of OSWRCH on the BBC
		switch((unsigned char)c)
		{
			case 35: // '#'
				c = 95;
				break;
			case 95: // '-'
				c = 96;
				break;
			case 96: // '£'
				c = 35;
				break;
			case 138: // 'Nothing', displays as a space
				c = 32;
				break;
		}

		if(c == 13)
		{
			int fillcols = MODE7_COLS - column;

			if(buffill + fillcols >= bufsize)
			{
				bufsize *= 2;
				buffer = realloc(buffer, bufsize);
			}

			memset(&buffer[buffill], ' ', fillcols);
			buffill += fillcols;
			column = 0;
		}
		else
		{
			buffer[buffill++] = c;

			if(buffill == bufsize)
			{
				bufsize *= 2;
				buffer = realloc(buffer, bufsize);
			}

			column = (column + 1) % 40;
		}
	}

	VALUE output = rb_str_new(buffer, buffill);
	free(buffer);

	return output;
}
