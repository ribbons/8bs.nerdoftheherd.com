# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2007-2020 by the authors - see the AUTHORS file for details.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module BBC
  module Mode0Filter
    def mode0_to_html(input)
      output = String.new

      row = 0
      column = 0

      underline = false
      controlchar = false
      prevchar = -1

      input.each_byte do |c|
        if controlchar
          case c.chr
          when 'B'
            output << '<b>'
          when 'b'
            output << '</b>'
          when 'I'
            output << '<i>'
          when 'i'
            output << '</i>'
          when 'S'
            output << '<span class="super">'
          when 'W'
            output << '<span class="wide">'
          when 'Y'
            output << '<span class="subs">'
          when 's', 'w', 'y'
            output << '</span>'
          when '*'
            output << '<span class="inv">*</span>'
          else
            throw "Unknown control character: \"#{c.chr}\" (ascii #{c}) " \
                  "at line #{row} column #{column}"
          end

          controlchar = false
          next
        end

        case c
        when 0
          # EOF
          break
        when 9
          # Tab - conv to spaces in the same way as the 80 col scroller
          loop do
            if column > 79
              output << "\n"
              row += 1
              column.zero?
            end

            output << ' '
            break if ((column + 2) % 8).zero?

            column += 1
          end
        when 10
          # Line feed
          column = 79
        when 13
          # Carriage return
          # This displays as a line feed as well unless there has just
          # been one, in which when it has no effect
          next if prevchar == 10

          column = 79
        when 28
          if underline
            output << '</span>'
            underline = false
          else
            output << '<span class="uline">'
            underline = true
          end
        when 29
          controlchar = true
          next
        when 32..37
          # {space}!"#$%
          output << c.chr
        when 38
          output << '&amp;'
        when 39..59
          # '()*+,-./0-9:
          output << c.chr
        when 60
          output << '&lt;'
        when 61
          # =
          output << c.chr
        when 62
          output << '&gt;'
        when 63..95
          # ?@A-Z[\# ]^_
          output << c.chr
        when 96
          output << '£'
        when 97..126
          # a-z{|}~
          output << c.chr
        # Chars 128-255 display as spaces in the Micro, but are populated
        # with special characters by default in the Master.
        # As the Micro was more popular, display these as spaces.
        when 128..255
          output << ' '
        else
          output << '?'
          throw "Unknown character value #{c} at line #{row} column #{column}"
        end

        prevchar = c
        column += 1

        next unless column > 79

        output << "\n"
        row += 1
        column = 0
      end

      output
    end
  end

  Liquid::Template.register_filter(BBC::Mode0Filter)
end
