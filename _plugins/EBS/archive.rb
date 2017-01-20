# This file is part of the 8BS Online Conversion.
# Copyright © 2017 by the authors - see the AUTHORS file for details.
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

module EBS
  class Archive
    # Each file has a number written just before it for some reason, so we need
    # to skip 5 bytes (1 for 0x40 and 4 for the integer value) before each one
    BYTES_BEFORE_FILE = 5

    attr_reader :data

    def initialize(file)
      @file = file
      data = file.content.each_byte.to_a

      3.times do
        raise 'Archive doesn\'t start with three zero ints' if read_value(data) != 0
      end

      version = read_value(data)
      raise 'Unknown archive version ' + version if version != '3.0'

      file_count = read_value(data)

      raise 'Invalid archive, expected total' unless read_value(data).is_a?(Integer)
      raise 'Invalid archive, expected creator' unless read_value(data).is_a?(String)
      raise 'Invalid archive, expected date' unless read_value(data).is_a?(String)

      # Skip over all lines of the notes
      read_value(data).times do
        raise 'Invalid archive, expected note line' unless read_value(data).is_a?(String)
      end

      @files = {}
      offset = BYTES_BEFORE_FILE

      file_count.times do
        filename = read_value(data)
        load_addr = read_value(data)
        exec_addr = read_value(data)
        length = read_value(data)
        raise 'File entry should end with zero int' if read_value(data) != 0

        splitname = filename.split('.', 2)
        dir = splitname.count == 1 ? '$' : splitname.shift
        justname = splitname.shift

        @files[@file.disc.canonicalise_path(filename)] = ArchiveFile.new(self, dir, justname, offset, length, load_addr, exec_addr)
        offset += length + BYTES_BEFORE_FILE
      end

      @data = data
    end

    def files
      @files.values
    end

    def file(path)
      @files[@file.disc.canonicalise_path(path)].content
    end

    private def read_value(data)
      type = data.shift

      case type
      when 0x00
        read_str(data)
      when 0x40
        read_int(data)
      else
        raise 'Malformed archive: Unexpected type value ' + type.to_s
      end
    end

    private def read_int(data)
      (data.shift << 24) | (data.shift << 16) | (data.shift << 8) | data.shift
    end

    private def read_str(data)
      length = data.shift

      value = ''

      (1..length).each do
        value = data.shift.chr + value
      end

      value
    end
  end
end
