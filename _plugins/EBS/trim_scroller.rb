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

module EBS
  module TrimScroller
    # The scrolling text is loaded at 0x1900 and run from 0x1904
    LOAD_ADDRESS = 0x1900
    SCREEN_SIZE = 25 * 40

    def trim_scroller(input)
      # The first four bytes are the start and end locations of the text data
      textstart = (input.getbyte(1) << 8 | input.getbyte(0)) - LOAD_ADDRESS
      textend = (input.getbyte(3) << 8 | input.getbyte(2)) - LOAD_ADDRESS + SCREEN_SIZE

      # Chop off scroller code
      input[textstart..textend]
    end
  end

  Liquid::Template.register_filter(EBS::TrimScroller)
end
