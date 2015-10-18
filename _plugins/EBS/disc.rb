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
  class Disc < Liquid::Drop
    def initialize(issue, image)
      @imagepath = '/' + image
      @issue = issue
      @path = image[%r{/(8BS[0-9-]+)\.dsd$}, 1]
      @number = @path[/[0-9]-([0-9])/, 1] || '1'

      @menus = []
      @linkpaths = {}
    end

    attr_reader :imagepath, :issue, :path, :number, :date, :menus

    private def read_data_lines(data)
      lines = {}
      pos = 0

      loop do
        fail 'Malformed BBC BASIC file' if data.getbyte(pos) != 0x0d
        pos += 1

        # End of file marker is 0xff
        break if (byte1 = data.getbyte(pos)) == 0xff
        pos += 1

        line_num = (byte1 << 8) | data.getbyte(pos)
        pos += 1

        # Entire length of line, so subtract bytes already read
        linelen = data.getbyte(pos) - 4
        pos += 1

        # Only a valid data line if first byte is the DATA token
        is_data_line = data.getbyte(pos) == 0xdc
        pos += 1

        if is_data_line
          line = data[pos..(pos + linelen - 1)]
          lines[line_num] = line.strip.split(',')
        end

        pos += linelen - 1
      end

      lines
    end

    private def read_str_var(varname, data)
      pos = 0

      loop do
        fail 'Malformed BBC BASIC file' if data.getbyte(pos) != 0x0d
        pos += 1

        # End of file marker
        if data.getbyte(pos) == 0xff
          throw 'String variable ' + varname + '$ not found'
        end

        # Skip second byte of line number
        pos += 2

        # Entire length of line, so subtract bytes already read
        linelen = data.getbyte(pos) - 4
        pos += 1

        if data[pos..(pos + varname.length + 2)] == varname + '$="'
          pos += varname.length + 3
          value = ''

          # Read value until the matching quote is found
          while data.getbyte(pos) != 0x22
            value << data.getbyte(pos).chr
            pos += 1
          end

          return value
        end

        pos += linelen
      end
    end
  end
end
