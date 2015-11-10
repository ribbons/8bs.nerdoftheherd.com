# This file is part of the 8BS Online Conversion.
# Copyright © 2015 by the authors - see the AUTHORS file for details.
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

module BBC
  module Mode7TextToMemFilter
    def mode7_text_to_mem(input)
      output = ''
      column = 0

      input.each_byte do |c|
        # Map to correct Teletext characters to replicate
        # the behaviour of OSWRCH on the BBC
        case c
        when 35 # '#'
          c = 95
        when 95 # '-'
          c = 96
        when 96 # '£'
          c = 35
        when 138 # 'Nothing', displays as a space
          c = 32
        end

        if c == 13
          while column < 40
            column += 1
            output << ' '
          end
        else
          output << c.chr
          column = (column + 1) % 40
        end
      end

      output
    end
  end

  Liquid::Template.register_filter(BBC::Mode7TextToMemFilter)
end
